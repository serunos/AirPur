import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/app_drawer.dart';
import 'chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    Center(child: Text('Jeux', style: TextStyle(fontSize: 24))),
    Center(child: Text('Évènements', style: TextStyle(fontSize: 24))),
    Center(child: Text('Quiz', style: TextStyle(fontSize: 24))),
    ChatbotScreen(),
    Center(child: Text('Communauté', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arrêter de fumer'),
      ),
      drawer: AppDrawer(onTap: _onItemTapped, selectedIndex: _selectedIndex),
      body: _pages[_selectedIndex],
    );
  }
}

