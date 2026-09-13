import 'package:flutter_test/flutter_test.dart';
//prueba
import 'package:notas_app/main.dart';

void main() {
  testWidgets('La app inicia y muestra la pantalla de bienvenida', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Calificaciones'), findsOneWidget);
  });
}
