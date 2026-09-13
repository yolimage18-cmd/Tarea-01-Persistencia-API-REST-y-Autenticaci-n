///  - Emulador de Android (Android Studio):      http://10.0.2.2:3000
///  - Celular físico conectado por USB (adb reverse): http://127.0.0.1:3000
///  - Celular físico en la misma red WiFi que tu PC:  http://TU_IP_LOCAL:3000
const String kApiBaseUrl = 'http://10.0.2.2:3000/api';

/// Nombre de la base de datos local SQLite.
const String kLocalDbName = 'notas_app.db';

/// Claves usadas en SharedPreferences.
const String kPrefTokenKey = 'auth_token';
const String kPrefUserIdKey = 'auth_user_id';
const String kPrefUserNameKey = 'auth_user_name';
const String kPrefUserEmailKey = 'auth_user_email';
