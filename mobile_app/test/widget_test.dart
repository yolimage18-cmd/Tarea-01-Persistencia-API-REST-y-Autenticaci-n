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
