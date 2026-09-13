import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/calificacion.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../services/db_service.dart';

/// Corazón de la app: administra las calificaciones combinando
/// persistencia local (SQLite) con el API REST remoto, y sincroniza
/// automáticamente cuando la conexión se restablece.
///
/// Estrategia "offline-first":
///   1. Toda operación (crear/editar/eliminar) se aplica PRIMERO en
///      SQLite, así la interfaz nunca espera a la red.
///   2. Cada registro guarda una bandera `isSynced`. Si es falsa,
///      significa que el cambio todavía no se ha reflejado en el servidor.
///   3. `syncNow()` recorre los registros pendientes y los envía al API
///      (POST/PUT/DELETE) y luego trae los registros del servidor.
///   4. Se llama a `syncNow()` automáticamente al iniciar la app, al
///      recuperar la conexión, y además el usuario puede forzarla
///      deslizando la lista (pull to refresh).
class CalificacionesProvider extends ChangeNotifier {
  final ApiService apiService;
  final ConnectivityService connectivityService;
  final DbService db = DbService.instance;
  final _uuid = const Uuid();

  StreamSubscription<bool>? _connectivitySub;

  CalificacionesProvider({required this.apiService, required this.connectivityService}) {
    _init();
  }

  List<Calificacion> items = [];
  bool isLoading = false;
  bool isSyncing = false;
  bool isOnline = true;
  String? lastSyncError;

  double get average {
    if (items.isEmpty) return 0;
    final sum = items.fold<double>(0, (a, b) => a + b.grade);
    return sum / items.length;
  }

  Future<void> _init() async {
    isOnline = await connectivityService.isOnline;
    _connectivitySub = connectivityService.onStatusChange.listen((online) {
      final wasOffline = !isOnline;
      isOnline = online;
      notifyListeners();
      if (online && wasOffline) {
        // Se recuperó la conexión: sincronizamos automáticamente.
        syncNow();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  Future<void> loadInitial() async {
    isLoading = true;
    notifyListeners();

    items = await db.getAll();

    isLoading = false;
    notifyListeners();

    if (await connectivityService.isOnline) {
      await syncNow();
    }
  }

  Future<void> _refreshFromLocal() async {
    items = await db.getAll();
    notifyListeners();
  }

  // ----------------- Operaciones CRUD locales -----------------

  Future<void> create({
    required String studentName,
    required String subject,
    required double grade,
    required String comment,
  }) async {
    final item = Calificacion(
      localId: _uuid.v4(),
      studentName: studentName.trim(),
      subject: subject.trim(),
      grade: grade,
      comment: comment.trim(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    await db.upsert(item);
    await _refreshFromLocal();
    unawaited(syncNow());
  }

  Future<void> update(
    Calificacion item, {
    required String studentName,
    required String subject,
    required double grade,
    required String comment,
  }) async {
    final updated = item.copyWith(
      studentName: studentName.trim(),
      subject: subject.trim(),
      grade: grade,
      comment: comment.trim(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    await db.upsert(updated);
    await _refreshFromLocal();
    unawaited(syncNow());
  }

  Future<void> delete(Calificacion item) async {
    if (item.serverId == null) {
      // Nunca llegó a sincronizarse con el servidor: se puede borrar de una vez.
      await db.hardDelete(item.localId);
    } else {
      final marked = item.copyWith(isDeleted: true, isSynced: false, updatedAt: DateTime.now());
      await db.upsert(marked);
    }
    await _refreshFromLocal();
    unawaited(syncNow());
  }

  // ----------------- Sincronización con el API REST -----------------

  Future<void> syncNow() async {
    if (isSyncing) return;
    if (!await connectivityService.isOnline) {
      isOnline = false;
      notifyListeners();
      return;
    }

    isSyncing = true;
    lastSyncError = null;
    notifyListeners();

    try {
      await _pushPendingChanges();
      await _pullRemote();
      lastSyncError = null;
    } catch (e) {
      lastSyncError = e.toString().replaceFirst('ApiException: ', '');
    } finally {
      isSyncing = false;
      await _refreshFromLocal();
    }
  }

  Future<void> _pushPendingChanges() async {
    final pending = await db.getPending();

    for (final item in pending) {
      if (item.isDeleted) {
        if (item.serverId != null) {
          await apiService.deleteCalificacion(item.serverId!);
        }
        await db.hardDelete(item.localId);
        continue;
      }

      if (item.serverId == null) {
        final created = await apiService.createCalificacion(
          studentName: item.studentName,
          subject: item.subject,
          grade: item.grade,
          comment: item.comment,
        );
        final synced = item.copyWith(
          serverId: created['id'] as String,
          isSynced: true,
          updatedAt: DateTime.parse(created['updatedAt'] as String),
        );
        await db.upsert(synced);
      } else {
        final updated = await apiService.updateCalificacion(
          serverId: item.serverId!,
          studentName: item.studentName,
          subject: item.subject,
          grade: item.grade,
          comment: item.comment,
        );
        final synced = item.copyWith(
          isSynced: true,
          updatedAt: DateTime.parse(updated['updatedAt'] as String),
        );
        await db.upsert(synced);
      }
    }
  }

  Future<void> _pullRemote() async {
    final remote = await apiService.fetchCalificaciones();

    for (final raw in remote) {
      final json = raw as Map<String, dynamic>;
      final serverId = json['id'] as String;
      final existing = await db.findByServerId(serverId);

      final item = Calificacion.fromServerJson(json, localId: existing?.localId);
      await db.upsert(item);
    }
  }
}
