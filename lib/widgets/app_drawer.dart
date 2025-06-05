import 'package:flutter/material.dart';

import '../screens/quiz_selection_screen.dart';
import 'drawer_item.dart';

class AppDrawer extends StatelessWidget {
  final ValueChanged<int> onTap;
  final int selectedIndex;

  const AppDrawer({required this.onTap, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Logo / User avatar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                radius: 32,
                backgroundImage: AssetImage('assets/images/user.png'),
              ),
            ),
            // Menu Items
            DrawerItem(
              icon: Icons.videogame_asset,
              label: 'Jeux',
              index: 0,
              onTap: onTap,
              selected: selectedIndex == 0,
            ),
            ListTile(
              leading: Icon(Icons.quiz),
              title: Text('Mes Quizzes'),
              selected: selectedIndex == 1,
              onTap: () {
                Navigator.of(context).pop(); // ferme le drawer
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => QuizSelectionScreen()),
                );
              },
            ),
            DrawerItem(
              icon: Icons.bar_chart,
              label: 'Statistique',
              index: 2,
              onTap: onTap,
              selected: selectedIndex == 2,
            ),
            DrawerItem(
              icon: Icons.chat_bubble_outline,
              label: 'Chatbot IA',
              index: 3,
              onTap: onTap,
              selected: selectedIndex == 3,
            ),
            Spacer(),
            
            // User name
            ListTile(
              leading: CircleAvatar(
                radius: 24, // optionnel : pour ajuster la taille de l’avatar
                backgroundImage: AssetImage('assets/images/user.png'),
              ),
              title: Text('Sacha'),
            ),
          ],
        ),
      ),
    );
  }
}