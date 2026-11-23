import 'package:flutter_test/flutter_test.dart';
import 'package:lista_voz/main.dart';

void main() {
  testWidgets('Comprobación de elementos de la interfaz en ListaVozApp', (WidgetTester tester) async {
    // En este test renderizo la app completa para comprobar la presencia de la UI inicial
    await tester.pumpWidget(const ListaVozApp());

    // Verifico que el título en la AppBar existe
    expect(find.text('Lista Controlada por Voz'), findsOneWidget);

    // Verifico que existen los botones de la alternativa táctil
    expect(find.text('Añadir'), findsOneWidget);
    expect(find.text('Borrar'), findsOneWidget);
    expect(find.text('Leer'), findsOneWidget);

    // Verifico los elementos iniciales de la lista
    expect(find.text('Elemento 1'), findsOneWidget);
    expect(find.text('Elemento 2'), findsOneWidget);

    // Compruebo que puedo pulsar el botón Añadir táctil
    await tester.tap(find.text('Añadir'));
    await tester.pump();

    // Verifico que se ha añadido el Elemento 3 a la lista
    expect(find.text('Elemento 3'), findsOneWidget);
  });
}
