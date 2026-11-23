import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notas_gestos/main.dart';

void main() {
  testWidgets('Comprobación de elementos de la interfaz en NotasGestosApp', (WidgetTester tester) async {
    // Renderizo la aplicación de notas
    await tester.pumpWidget(const NotasGestosApp());

    // Verifico el título de la AppBar
    expect(find.text('Notas con Gestos'), findsOneWidget);

    // Verifico el SwitchListTile de "Agitar para deshacer"
    expect(find.text('Agitar para deshacer'), findsOneWidget);

    // Verifico las notas iniciales en pantalla
    expect(find.text('Comprar leche y fruta'), findsOneWidget);

    // Verifico que existe el campo de texto y botón añadir
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Verifico la barra de navegación con Notas y Papelera
    expect(find.text('Notas (3)'), findsOneWidget);
    expect(find.text('Papelera (0)'), findsOneWidget);

    // Pulso la pestaña Papelera
    await tester.tap(find.text('Papelera (0)'));
    await tester.pumpAndSettle();

    // Verifico que se muestra la vista de Papelera vacía
    expect(find.text('La papelera está vacía'), findsOneWidget);
  });
}
