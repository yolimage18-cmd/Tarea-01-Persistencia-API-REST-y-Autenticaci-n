// Prueba de widget básica (ver Unidad 2, Ejercicio 10 del módulo).
//
// Verifica que la pantalla inicial (Splash) se construye sin errores
// y muestra el nombre de la app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:notas_app/main.dart';

void main() {
  testWidgets('La app inicia y muestra la pantalla de bienvenida', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // La pantalla Splash muestra el texto "Calificaciones" mientras se
    // comprueba si hay una sesión guardada.
    expect(find.text('Calificaciones'), findsOneWidget);
  });
}
