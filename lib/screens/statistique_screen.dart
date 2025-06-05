// lib/screens/statistique_screen.dart

import 'package:flutter/material.dart';
import '../services/db_helper.dart';

class StatistiqueScreen extends StatefulWidget {
  const StatistiqueScreen({Key? key}) : super(key: key);

  @override
  _StatistiqueScreenState createState() => _StatistiqueScreenState();
}

class _StatistiqueScreenState extends State<StatistiqueScreen> {
  DateTime? _dateArret;
  int _cigsParJour = 0;
  double _prixParPaquet = 0.0;

  int _joursSobres = 0;
  double _argentEconomise = 0.0;

  @override
  void initState() {
    super.initState();
    _chargerDonneesTabac();
  }

  Future<void> _chargerDonneesTabac() async {
    final data = await DBHelper().getDerniereHabitudeTabac();
    if (data != null) {
      setState(() {
        _dateArret = DateTime.parse(data['date_arret'] as String);
        _cigsParJour = data['cigarettes_par_jour'] as int;
        _prixParPaquet = data['prix_par_paquet'] as double;
      });
      _calculerSobrieteEtEconomies();
    }
  }

  void _calculerSobrieteEtEconomies() {
    if (_dateArret == null || _cigsParJour == 0 || _prixParPaquet == 0.0) {
      setState(() {
        _joursSobres = 0;
        _argentEconomise = 0.0;
      });
      return;
    }

    final now = DateTime.now();
    final difference = now.difference(_dateArret!);
    final jours = difference.inDays;

    // Montant économisé (en supposant 20 cigs/paquet)
    final prixParCigarette = _prixParPaquet / 20.0;
    final montant = jours * _cigsParJour * prixParCigarette;

    setState(() {
      _joursSobres = jours;
      _argentEconomise = montant;
    });
  }

  Future<void> _resetDonneesTabac() async {
    // 1. Supprimer de la base
    await DBHelper().deleteHabitudeTabac();

    // 2. Réinitialiser : date d’arrêt = aujourd’hui, autres valeurs à zéro
    setState(() {
      _dateArret = DateTime.now();
      _cigsParJour = 0;
      _prixParPaquet = 0.0;
      // Recalculer sobriété & économies : ce sera 0 jour et 0 €
      _calculerSobrieteEtEconomies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _dateArret == null
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

            // Bouton pour mettre à jour/en refaire le quiz
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/quiz');
              },
              child: const Text('Mettre à jour mes habitudes'),
            ),

            const SizedBox(height: 12),

            // Nouveau bouton pour remise à zéro
            ElevatedButton.icon(
              onPressed: () async {
                // Confirmation avant remise à zéro
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Remise à zéro'),
                    content: const Text(
                        'Voulez-vous vraiment réinitialiser vos données ? '
                            'La date d’arrêt sera mise à aujourd’hui.'),
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
