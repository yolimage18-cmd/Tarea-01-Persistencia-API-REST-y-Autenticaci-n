import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/calificacion.dart';
import '../utils/constants.dart';

class DbService {
  DbService._internal();
  static final DbService instance = DbService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), kLocalDbName);

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE calificaciones (
            localId TEXT PRIMARY KEY,
            serverId TEXT,
            studentName TEXT NOT NULL,
            subject TEXT NOT NULL,
            grade REAL NOT NULL,
            comment TEXT,
            updatedAt TEXT NOT NULL,
            isSynced INTEGER NOT NULL DEFAULT 0,
            isDeleted INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS calificaciones (
        localId TEXT PRIMARY KEY,
        serverId TEXT,
        studentName TEXT NOT NULL,
        subject TEXT NOT NULL,
        grade REAL NOT NULL,
        comment TEXT,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0,
        isDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
  },
    );
  }

  Future<List<Calificacion>> getAll() async {
    final db = await database;
    final rows = await db.query(
      'calificaciones',
      where: 'isDeleted = ?',
      whereArgs: [0],
      orderBy: 'updatedAt DESC',
    );
    return rows.map((row) => Calificacion.fromDbMap(row)).toList();
  }

  
  Future<List<Calificacion>> getPending() async {
    final db = await database;
    final rows = await db.query('calificaciones', where: 'isSynced = ?', whereArgs: [0]);
    return rows.map((row) => Calificacion.fromDbMap(row)).toList();
  }

  Future<void> upsert(Calificacion item) async {
    final db = await database;
    await db.insert(
      'calificaciones',
      item.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  
  Future<void> hardDelete(String localId) async {
    final db = await database;
    await db.delete('calificaciones', where: 'localId = ?', whereArgs: [localId]);
  }

  Future<Calificacion?> findByServerId(String serverId) async {
    final db = await database;
    final rows = await db.query('calificaciones', where: 'serverId = ?', whereArgs: [serverId]);
    if (rows.isEmpty) return null;
    return Calificacion.fromDbMap(rows.first);
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('calificaciones');
  }
}
