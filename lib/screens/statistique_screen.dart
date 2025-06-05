// lib/screens/statistique_screen.dart

import 'package:flutter/material.dart' hide Badge;
import 'package:airpur/services/quiz_manager.dart';
import 'package:intl/intl.dart';

import '../models/quiz_models.dart';
import '../services/db_helper.dart';
import '../services/material.dart' as quizMat; // alias pour notre modèle Badge

class StatistiqueScreen extends StatefulWidget {
  const StatistiqueScreen({Key? key}) : super(key: key);

  @override
  _StatistiqueScreenState createState() => _StatistiqueScreenState();
}

class _StatistiqueScreenState extends State<StatistiqueScreen> {
  DateTime? _dateArret;
  int _cigsParJour = 0;
  static const double _prixParPaquet = 13.0;
  int _joursSobres = 0;
  double _argentEconomise = 0.0;

  // Liste qui contiendra les badges uniquement pour les quizzes terminés
  List<quizMat.Badge> _badges = [];

  final QuizManager _quizManager = QuizManager();

  // Les trois quiz IDs à tester
  static const List<String> _quizIds = ['quiz1', 'quiz2', 'quiz3'];

  @override
  void initState() {
    super.initState();
    _chargerDonneesTabac();
  }

  Future<void> _chargerDonneesTabac() async {
    // 1) Charger la date d'arrêt depuis la BD (ou forcer aujourd'hui)
    final data = await DBHelper().getDerniereHabitudeTabac();
    if (data != null) {
      _dateArret = DateTime.parse(data['date_arret'] as String);
    } else {
      _dateArret = DateTime.now();
    }

    // 2) Récupérer "cigarettes/jour" depuis SharedPreferences (premier quiz qui a q2)
    int cigsParJourFromQuiz = 0;
    for (String quizId in _quizIds) {
      final savedAnswers = await _quizManager.getSavedAnswers(quizId);
      for (var ans in savedAnswers) {
        if (ans != null && ans.questionId == 'q2') {
          cigsParJourFromQuiz = int.tryParse(ans.valeur) ?? 0;
          break;
        }
      }
      if (cigsParJourFromQuiz > 0) break;
    }
    _cigsParJour = cigsParJourFromQuiz;

    // 3) Calculer sobriété & économies
    _calculerSobrieteEtEconomies();

    // 4) Pour chaque quiz ID, ajouter ses badges si le quiz est terminé
    List<quizMat.Badge> tousLesBadges = [];
    for (String quizId in _quizIds) {
      final bool termine = await _quizManager.hasSavedAnswers(quizId);
      if (termine) {
        final badgesPourQuiz = _quizManager
            .getBadges(quizId)
            .whereType<quizMat.Badge>()
            .toList();
        tousLesBadges.addAll(badgesPourQuiz);
      }
    }
    _badges = tousLesBadges;

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
    await DBHelper().deleteHabitudeTabac();
    _dateArret = DateTime.now();
    _cigsParJour = 0;
    _calculerSobrieteEtEconomies();

    // Effacer les réponses pour chacun des trois quiz
    for (String quizId in _quizIds) {
      await _quizManager.clearSavedAnswers(quizId);
    }

    // Vider la liste des badges
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
      body: aucuneDonnee
          ? const Center(
        child: Text(
          'Aucune donnée de tabac disponible.\nVeuillez remplir au moins un quiz.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Statistiques ---
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
            const Text(
              'Argent économisé',
              style: TextStyle(
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

            // --- Section "Vos badges" (uniquement pour les quizzes terminés) ---
            if (_badges.isNotEmpty) ...[
              const Text(
                'Vos badges',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _badges.map((quizBadge) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
              ),
              const SizedBox(height: 24),
            ],

            // --- Boutons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Remise à zéro'),
                        content: const Text(
                          'Voulez-vous vraiment réinitialiser vos données ? '
                              'La date d’arrêt sera mise à aujourd’hui.',
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
