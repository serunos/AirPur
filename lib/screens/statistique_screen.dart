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
            // Vous pouvez ajouter un bouton pour remettre à zéro, ou refaire le quiz
            ElevatedButton(
              onPressed: () {
                // Possibilité : renvoyer au quiz ou réinitialiser la date d'arrêt
                // Navigator.of(context).pushNamed('/quiz');
              },
              child: const Text('Mettre à jour mes habitudes'),
            ),
          ],
        ),
      ),
    );
  }
}
