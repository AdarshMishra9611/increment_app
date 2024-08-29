import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            value INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertUser(String username) async {
    final db = await database;
    await db.insert(
      'users',
      {'username': username, 'value': 0},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> getUserValue(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first['value'] as int : 0;
  }

  Future<void> updateUserValue(String username, int value) async {
    final db = await database;
    await db.update(
      'users',
      {'value': value},
      where: 'username = ?',
      whereArgs: [username],
    );
  }
}
