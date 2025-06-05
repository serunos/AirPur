// lib/screens/statistique_screen.dart

import 'package:flutter/material.dart';
import 'package:airpur/services/quiz_manager.dart';
import 'package:intl/intl.dart';

import '../models/quiz_models.dart';
import '../services/db_helper.dart';

class StatistiqueScreen extends StatefulWidget {
  const StatistiqueScreen({Key? key}) : super(key: key);

  @override
  _StatistiqueScreenState createState() => _StatistiqueScreenState();
}

class _StatistiqueScreenState extends State<StatistiqueScreen> {
  // Si vous avez besoin d'autres informations (date d'arrêt), on peut continuer
  // à utiliser DBHelper().getDerniereHabitudeTabac() pour la date, ou la remplacer
  // par une valeur "aujourd'hui". Ici, on garde la date d'arrêt depuis la BD si existante.
  DateTime? _dateArret;

  // On récupère désormais cette valeur depuis les SharedPreferences (quiz)
  int _cigsParJour = 0;

  // On fixe en dur le prix du paquet
  static const double _prixParPaquet = 13.0;

  int _joursSobres = 0;
  double _argentEconomise = 0.0;

  // QuizManager pour charger les réponses
  final QuizManager _quizManager = QuizManager();

  @override
  void initState() {
    super.initState();
    _chargerDonneesTabac();
  }

  Future<void> _chargerDonneesTabac() async {
    // 1) Tenter de récupérer la date d'arrêt dans la BD (si elle existe)
    //    Si vous ne souhaitez plus utiliser la BD du tout, vous pouvez commenter cette partie
    //    et forcer _dateArret = DateTime.now().
    final data = await DBHelper().getDerniereHabitudeTabac();
    if (data != null) {
      setState(() {
        _dateArret = DateTime.parse(data['date_arret'] as String);
      });
    } else {
      // Si aucune donnée BD, on considère que l'utilisateur arrête "aujourd'hui"
      setState(() {
        _dateArret = DateTime.now();
      });
    }

    // 2) Récupérer la réponse "nombre de cigarettes/jour" depuis SharedPreferences
    //    (via QuizManager.getSavedAnswers). Remplacez "tabac_quiz" par l'ID
    //    exact de votre quiz tabac.
    const String tabacQuizId = "quiz1";
    final List<QuizAnswer?> savedAnswers =
    await _quizManager.getSavedAnswers(tabacQuizId);

    // On cherche la question q2 (cigarettes par jour)
    int cigsParJourFromQuiz = 0;
    for (var ans in savedAnswers) {
      if (ans != null && ans.questionId == 'q2') {
        cigsParJourFromQuiz = int.tryParse(ans.valeur) ?? 0;
        break;
      }
    }

    setState(() {
      _cigsParJour = cigsParJourFromQuiz;
    });

    // 3) Dès qu’on a _dateArret_ et _cigsParJour_, on calcule
    _calculerSobrieteEtEconomies();
  }

  void _calculerSobrieteEtEconomies() {
    if (_dateArret == null || _cigsParJour == 0) {
      setState(() {
        _joursSobres = 0;
        _argentEconomise = 0.0;
      });
      return;
    }

    final now = DateTime.now();
    final difference = now.difference(_dateArret!);
    final jours = difference.inDays.clamp(0, difference.inDays);

    // Montant économisé = (jours passés depuis l'arrêt) * (cigs/jour) * (prix cigs)
    // Prix par cigarette = _prixParPaquet / 20
    final double prixParCigarette = _prixParPaquet / 20.0;
    final double montant = jours * _cigsParJour * prixParCigarette;

    setState(() {
      _joursSobres = jours;
      _argentEconomise = montant;
    });
  }

  Future<void> _resetDonneesTabac() async {
    // 1) Si vous utilisiez la BD, on peut la nettoyer
    await DBHelper().deleteHabitudeTabac();

    // 2) Remettre la date d'arrêt à aujourd'hui
    setState(() {
      _dateArret = DateTime.now();
      _cigsParJour = 0;
      _calculerSobrieteEtEconomies();
    });

    // 3) Facultatif : effacer également les réponses du quiz dans SharedPreferences
    //    Pour cela, utilisez clearSavedAnswers() de QuizManager :
    const String tabacQuizId = "tabac_quiz";
    await _quizManager.clearSavedAnswers(tabacQuizId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: (_dateArret == null || _cigsParJour == 0)
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
            Text(
              'Date d’arrêt : ${_dateArret!.day.toString().padLeft(2, '0')}/'
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
            const Spacer(),

            const SizedBox(height: 12),

            // Bouton de remise à zéro
            ElevatedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Remise à zéro'),
                    content: const Text(
                      'Voulez-vous vraiment réinitialiser vos données ?\n'
                          'La date d’arrêt sera remise à aujourd’hui.',
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
      ),
    );
  }
}
