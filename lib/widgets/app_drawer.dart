import 'package:flutter/material.dart';

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
                backgroundImage: AssetImage('assets/logo.png'),
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
            DrawerItem(
              icon: Icons.book,
              label: 'Quizz',
              index: 1,
              onTap: onTap,
              selected: selectedIndex == 1,
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
            // Tips & Tricks card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tips & Tricks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Head on over to our website to get the latest tips & tricks!'),
                      SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: ouvrir lien externe
                        },
                        icon: Icon(Icons.open_in_new),
                        label: Text('Learn More'),
                      )
                    ],
                  ),
                ),
              ),
            ),
            // User name
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Utilisateur'),
            )
          ],
        ),
      ),
    );
  }
}