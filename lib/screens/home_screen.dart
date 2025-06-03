import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';
import 'chatbot_screen.dart';
import 'quiz_screen.dart'; // Ajout de l’import du QuizScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const Center(child: Text('Jeux', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Évènements', style: TextStyle(fontSize: 24))),
    QuizScreen(), // Remplacement du placeholder par la page Quiz réelle
    const ChatbotScreen(),
    const Center(child: Text('Communauté', style: TextStyle(fontSize: 24))),
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
        title: const Text('Arrêter de fumer'),
      ),
      drawer: AppDrawer(onTap: _onItemTapped, selectedIndex: _selectedIndex),
      body: _pages[_selectedIndex],
    );
  }
}
