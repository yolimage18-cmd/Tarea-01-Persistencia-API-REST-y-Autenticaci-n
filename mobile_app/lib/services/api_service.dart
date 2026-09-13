import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path) => Uri.parse('$kApiBaseUrl$path');

  Future<Map<String, dynamic>> _handle(http.Response response) async {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body is Map<String, dynamic> ? body : {'data': body};
    }

    final message = (body is Map && body['error'] != null)
        ? body['error'] as String
        : 'Error de comunicación con el servidor (código ${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }

  // ----------------- Autenticación -----------------

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
          _uri('/auth/register'),
          headers: _headers,
          body: jsonEncode({'name': name, 'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 12));
    return _handle(response);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
          _uri('/auth/login'),
          headers: _headers,
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 12));
    return _handle(response);
  }

  // ----------------- Calificaciones (CRUD) -----------------

  Future<List<dynamic>> fetchCalificaciones() async {
    final response = await http.get(_uri('/calificaciones'), headers: _headers).timeout(
          const Duration(seconds: 12),
        );
    final data = await _handle(response);
    return data['calificaciones'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> createCalificacion({
    required String studentName,
    required String subject,
    required double grade,
    required String comment,
  }) async {
    final response = await http
        .post(
          _uri('/calificaciones'),
          headers: _headers,
          body: jsonEncode({
            'studentName': studentName,
            'subject': subject,
            'grade': grade,
            'comment': comment,
          }),
        )
        .timeout(const Duration(seconds: 12));
    final data = await _handle(response);
    return data['calificacion'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCalificacion({
    required String serverId,
    required String studentName,
    required String subject,
    required double grade,
    required String comment,
  }) async {
    final response = await http
        .put(
          _uri('/calificaciones/$serverId'),
          headers: _headers,
          body: jsonEncode({
            'studentName': studentName,
            'subject': subject,
            'grade': grade,
            'comment': comment,
          }),
        )
        .timeout(const Duration(seconds: 12));
    final data = await _handle(response);
    return data['calificacion'] as Map<String, dynamic>;
  }

  Future<void> deleteCalificacion(String serverId) async {
    final response = await http
        .delete(_uri('/calificaciones/$serverId'), headers: _headers)
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 204 && response.statusCode != 200) {
      await _handle(response);
    }
  }
}
