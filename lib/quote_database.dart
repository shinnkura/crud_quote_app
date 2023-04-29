import 'dart:async';
import 'dart:io';

import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'quote.dart';

class QuoteDatabase {
  static final QuoteDatabase instance = QuoteDatabase._init();

  static Database? _database;

  QuoteDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('quotes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final authorType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE quotes (
        id $idType,
        text $textType,
        author $authorType
        )
      ''');
  }

  Future<Quote> create(Quote quote) async {
    final db = await instance.database;

    final id = await db.insert('quotes', quote.toMap());
    return quote.copyWith(id: id);
  }

  Future<Quote?> readQuote(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      'quotes',
      columns: ['id', 'text', 'author'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Quote.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Quote>> readAllQuotes() async {
    final db = await instance.database;

    final orderBy = 'author ASC';

    final result = await db.query('quotes', orderBy: orderBy);

    return result.map((json) => Quote.fromMap(json)).toList();
  }

  Future<int> update(Quote quote) async {
    final db = await instance.database;

    return db.update(
      'quotes',
      quote.toMap(),
      where: 'id = ?',
      whereArgs: [quote.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      'quotes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
