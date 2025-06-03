import 'package:airpur/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(StopSmokingApp());
}

class StopSmokingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AirPur',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}




