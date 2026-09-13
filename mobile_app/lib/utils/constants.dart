/// Configuración central de la app.
///
/// IMPORTANTE — URL del backend:
/// El celular/emulador NO puede usar "localhost" para hablar con tu
/// computador, porque "localhost" dentro del emulador/celular se
/// refiere a SÍ MISMO, no a tu PC. Por eso este valor cambia según
/// cómo estés probando la app (lee la sección correspondiente del
/// README.md del proyecto):
///
///  - Emulador de Android (Android Studio):      http://10.0.2.2:3000
///  - Celular físico conectado por USB (adb reverse): http://127.0.0.1:3000
///  - Celular físico en la misma red WiFi que tu PC:  http://TU_IP_LOCAL:3000
///    (por ejemplo http://192.168.1.35:3000 — obtén tu IP con
///    "ipconfig" en Windows o "ifconfig"/"ip a" en Mac/Linux)
///
/// Cambia SOLO la siguiente línea según tu caso:
const String kApiBaseUrl = 'http://10.0.2.2:3000/api';

/// Nombre de la base de datos local SQLite.
const String kLocalDbName = 'notas_app.db';

/// Claves usadas en SharedPreferences.
const String kPrefTokenKey = 'auth_token';
const String kPrefUserIdKey = 'auth_user_id';
const String kPrefUserNameKey = 'auth_user_name';
const String kPrefUserEmailKey = 'auth_user_email';
