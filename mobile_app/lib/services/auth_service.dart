import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService api;
  AuthService(this.api);

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await api.register(name: name, email: email, password: password);
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<({String token, AppUser user})> login({
    required String email,
    required String password,
  }) async {
    final data = await api.login(email: email, password: password);
    final token = data['token'] as String;
    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);

    await _persistSession(token, user);
    api.setToken(token);

    return (token: token, user: user);
  }

  Future<({String token, AppUser user})?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(kPrefTokenKey);
    final userId = prefs.getString(kPrefUserIdKey);
    final userName = prefs.getString(kPrefUserNameKey);
    final userEmail = prefs.getString(kPrefUserEmailKey);

    if (token == null || userId == null || userName == null || userEmail == null) {
      return null;
    }

    api.setToken(token);
    return (token: token, user: AppUser(id: userId, name: userName, email: userEmail));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kPrefTokenKey);
    await prefs.remove(kPrefUserIdKey);
    await prefs.remove(kPrefUserNameKey);
    await prefs.remove(kPrefUserEmailKey);
    api.setToken(null);
  }

  Future<void> _persistSession(String token, AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kPrefTokenKey, token);
    await prefs.setString(kPrefUserIdKey, user.id);
    await prefs.setString(kPrefUserNameKey, user.name);
    await prefs.setString(kPrefUserEmailKey, user.email);
  }
}
