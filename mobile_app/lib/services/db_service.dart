import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/calificacion.dart';
import '../utils/constants.dart';

/// Servicio de persistencia local con SQLite (paquete sqflite).
///
/// Esta es la pieza clave del requisito de "Persistencia": todas las
/// calificaciones se guardan primero en esta base de datos local, así
/// que la app funciona perfectamente sin conexión. Cuando hay internet,
/// el SyncService (CalificacionesProvider) refleja los cambios en el servidor.
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

  /// Devuelve todas las calificaciones visibles (no eliminadas), más recientes primero.
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

  /// Registros pendientes por enviar al servidor (creados/editados/borrados offline).
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

  /// Elimina físicamente un registro de la base local (se usa una vez que
  /// el servidor confirmó el borrado, o si nunca llegó a sincronizarse).
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

  /// Limpia toda la base local (se usa al cerrar sesión, para que los
  /// registros de un usuario no se mezclen con los de otro en el mismo dispositivo).
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('calificaciones');
  }
}
