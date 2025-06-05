// lib/services/db_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Initialisation
    _database = await _initDB('airpur.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE habitudes_tabac (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date_arret TEXT NOT NULL,
            cigarettes_par_jour INTEGER NOT NULL,
            prix_par_paquet REAL NOT NULL
          )
        ''');
      },
    );
  }

  /// Insérer ou mettre à jour la ligne des habitudes de tabac.
  /// Si l’utilisateur remplit le quiz plusieurs fois, vous pouvez soit
  /// faire un INSERT (historique), soit un REPLACE selon votre logique.
  Future<int> insertHabitudeTabac({
    required DateTime dateArret,
    required int cigsParJour,
    required double prixParPaquet,
  }) async {
    final db = await database;
    return await db.insert(
      'habitudes_tabac',
      {
        'date_arret': dateArret.toIso8601String(),
        'cigarettes_par_jour': cigsParJour,
        'prix_par_paquet': prixParPaquet,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // remplace la ligne si même clé (ici auto-increment, à ajuster selon besoin)
    );
  }

  /// Récupérer la dernière ligne (ou unique) des habitudes de tabac
  Future<Map<String, dynamic>?> getDerniereHabitudeTabac() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'habitudes_tabac',
      orderBy: 'id DESC',
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<void> deleteHabitudeTabac() async {
    final db = await database;
    await db.delete(
      'habitudes_tabac',
      // Si vous ne conservez qu’un seul enregistrement, vous pouvez
      // tout simplement faire un DELETE sans WHERE :
      // where: null, whereArgs: null
    );
  }
  
}
