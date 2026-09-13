import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

/// Maneja el estado de autenticación de toda la app (patrón visto en el
/// módulo: ChangeNotifier + Provider).
class AuthProvider extends ChangeNotifier {
  final ApiService apiService;
  final AuthService authService;

  AuthProvider({required this.apiService}) : authService = AuthService(apiService);

  AuthStatus status = AuthStatus.checking;
  AppUser? currentUser;
  String? errorMessage;
  bool isLoading = false;

  /// Se ejecuta al abrir la app: intenta recuperar una sesión guardada.
  Future<void> restoreSession() async {
    final session = await authService.restoreSession();
    if (session != null) {
      currentUser = session.user;
      status = AuthStatus.authenticated;
    } else {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await authService.login(email: email, password: password);
      currentUser = result.user;
      status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('ApiException: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await authService.register(name: name, email: email, password: password);
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('ApiException: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await authService.logout();
    await DbService.instance.clearAll();
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
