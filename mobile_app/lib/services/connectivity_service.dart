import 'package:connectivity_plus/connectivity_plus.dart';

/// Envuelve el paquete connectivity_plus para exponer un stream sencillo
/// de "true/false" (con internet / sin internet).
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return _hasConnection(result);
  }

  Stream<bool> get onStatusChange {
    return _connectivity.onConnectivityChanged.map(_hasConnection);
  }

  bool _hasConnection(List<ConnectivityResult> result) {
    return result.any((r) => r != ConnectivityResult.none);
  }
}
