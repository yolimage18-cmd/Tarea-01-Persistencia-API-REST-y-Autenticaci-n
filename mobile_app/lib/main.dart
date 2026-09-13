import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/calificaciones_provider.dart';
import 'screens/splash_screen.dart';
import 'services/api_service.dart';
import 'services/connectivity_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Una única instancia de ApiService y ConnectivityService se
    // comparte entre los providers para reutilizar el token y el
    // estado de conexión.
    final apiService = ApiService();
    final connectivityService = ConnectivityService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService: apiService)),
        ChangeNotifierProvider(
          create: (_) => CalificacionesProvider(
            apiService: apiService,
            connectivityService: connectivityService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Gestión de Calificaciones',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
