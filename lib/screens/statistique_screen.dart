// lib/screens/statistique_screen.dart

import 'package:flutter/material.dart' hide Badge; // On cache Flutter's Badge
import 'package:airpur/services/quiz_manager.dart';
import 'package:intl/intl.dart';

import '../models/quiz_models.dart';
import '../services/db_helper.dart';
import '../services/material.dart' as quizMat; // On importe notre modèle Badge sous alias

class StatistiqueScreen extends StatefulWidget {
  const StatistiqueScreen({Key? key}) : super(key: key);

  @override
  _StatistiqueScreenState createState() => _StatistiqueScreenState();
}

class _StatistiqueScreenState extends State<StatistiqueScreen> {
  // Date d'arrêt (chargée depuis la BD ou forcée à aujourd'hui)
  DateTime? _dateArret;

  // Nombre de cigarettes/jour récupéré depuis SharedPreferences (quiz)
  int _cigsParJour = 0;

  // Prix du paquet (en dur)
  static const double _prixParPaquet = 13.0;

  int _joursSobres = 0;
  double _argentEconomise = 0.0;

  // Liste des badges acquis (ou disponibles) pour le quiz tabac
  List<quizMat.Badge> _badges = [];

  // QuizManager pour récupérer réponses & badges
  final QuizManager _quizManager = QuizManager();

  // Identifiant du quiz tabac (adaptez à votre ID réel)
  static const String _tabacQuizId = "quiz1";

  @override
  void initState() {
    super.initState();
    _chargerDonneesTabac();
  }

  Future<void> _chargerDonneesTabac() async {
    // 1) Tenter de récupérer la date d'arrêt dans la BD
    final data = await DBHelper().getDerniereHabitudeTabac();
    if (data != null) {
      _dateArret = DateTime.parse(data['date_arret'] as String);
    } else {
      // Si pas de donnée BD, on prend la date du jour comme date d'arrêt
      _dateArret = DateTime.now();
    }

    // 2) Charger la réponse "cigarettes/jour" depuis SharedPreferences
    final List<QuizAnswer?> savedAnswers =
    await _quizManager.getSavedAnswers(_tabacQuizId);

    int cigsParJourFromQuiz = 0;
    for (var ans in savedAnswers) {
      if (ans != null && ans.questionId == 'q2') {
        cigsParJourFromQuiz = int.tryParse(ans.valeur) ?? 0;
        break;
      }
    }
    _cigsParJour = cigsParJourFromQuiz;

    // 3) Calculer jours de sobriété & économies
    _calculerSobrieteEtEconomies();

    // 4) Récupérer la liste des badges pour ce quiz
    _badges = _quizManager.getBadges(_tabacQuizId)
        .whereType<quizMat.Badge>()
        .toList();

    // Enfin, notifier le framework que tout a changé
    setState(() {});
  }

  void _calculerSobrieteEtEconomies() {
    if (_dateArret == null || _cigsParJour == 0) {
      _joursSobres = 0;
      _argentEconomise = 0.0;
      return;
    }

    final now = DateTime.now();
    final difference = now.difference(_dateArret!);
    final jours = difference.inDays.clamp(0, difference.inDays);

    final double prixParCigarette = _prixParPaquet / 20.0;
    final double montant = jours * _cigsParJour * prixParCigarette;

    _joursSobres = jours;
    _argentEconomise = montant;
  }

  Future<void> _resetDonneesTabac() async {
    // 1) Supprimer de la BD
    await DBHelper().deleteHabitudeTabac();

    // 2) Remettre la date d'arrêt à aujourd'hui
    _dateArret = DateTime.now();
    _cigsParJour = 0;
    _calculerSobrieteEtEconomies();

    // 3) Effacer les réponses du quiz dans SharedPreferences
    await _quizManager.clearSavedAnswers(_tabacQuizId);

    // 4) Réinitialiser la liste des badges (ici, on vide complètement)
    _badges = [];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool aucuneDonnee = (_dateArret == null || _cigsParJour == 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: aucuneDonnee
            ? const Center(
          child: Text(
            'Aucune donnée de tabac disponible.\nVeuillez remplir le quiz.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Affichage des statistiques ---
            Text(
              'Date d’arrêt : '
                  '${_dateArret!.day.toString().padLeft(2, '0')}/'
                  '${_dateArret!.month.toString().padLeft(2, '0')}/'
                  '${_dateArret!.year}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              'Jours de sobriété : $_joursSobres',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Cigarettes/jour avant arrêt : $_cigsParJour',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Prix par paquet : ${_prixParPaquet.toStringAsFixed(2)} €',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Argent économisé',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_argentEconomise.toStringAsFixed(2)} €',
              style: const TextStyle(
                fontSize: 28,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // --- Section : Afficher les badges obtenus ---
            if (_badges.isNotEmpty) ...[
              Text(
                'Vos badges',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _badges.map((quizBadge) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // On affiche l'image du badge
                      Image.asset(
                        quizBadge.assetPath,
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quizBadge.title,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            const Spacer(),

            // Boutons en bas de l'écran
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [              

                // Remise à zéro
                ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Remise à zéro'),
                        content: const Text(
                          'Voulez-vous vraiment réinitialiser '
                              'vos données ? La date d’arrêt sera mise à aujourd’hui.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Oui, remettre à zéro'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await _resetDonneesTabac();
                    }
                  },
                  icon: const Icon(Icons.restore),
                  label: const Text('Remise à zéro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
