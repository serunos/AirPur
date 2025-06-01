import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool selected;
  final ValueChanged<int> onTap;

  const DrawerItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selected ? Colors.green : Colors.black),
      title: Text(label, style: TextStyle(color: selected ? Colors.green : Colors.black)),
      selected: selected,
      onTap: () => onTap(index),
    );
  }
}