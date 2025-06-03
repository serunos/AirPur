// lib/screens/home_screen.dart

import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';
//import 'jeu_screen.dart';
import 'quiz_screen.dart';
//import 'statistique_screen.dart'; // Nouvel écran pour "Statistiques"
import 'chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // On ajoute "Statistiques" à la liste des pages
  static final List<Widget> _pages = <Widget>[
    
    //const JeuScreen(),      index 0
    const Center(
      child: Text(
        'Placeholder - Jeu',
        style: TextStyle(fontSize: 24),
      ),
    ),
    
    QuizScreen(), // index 1
    
    //const StatistiqueScreen(), index 2
    const Center(
      child: Text(
        'Placeholder - Statistiques',
        style: TextStyle(fontSize: 24),
      ),
    ),
    
    const ChatbotScreen(),        // index 3
    
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Navigator.of(context).pop(); // Ferme le drawer avant d’afficher la page
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AirPur'),
      ),
      drawer: AppDrawer(
        onTap: _onItemTapped,
        selectedIndex: _selectedIndex,
        // Dans AppDrawer, assurez-vous d’afficher maintenant 4 items :
        // 0 → "Jeu"
        // 1 → "Quiz"
        // 2 → "Statistiques"
        // 3 → "Chatbot"
      ),
      body: _pages[_selectedIndex],
    );
  }
}
