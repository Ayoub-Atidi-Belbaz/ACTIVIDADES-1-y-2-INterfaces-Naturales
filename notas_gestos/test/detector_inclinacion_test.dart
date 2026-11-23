import 'package:flutter_test/flutter_test.dart';
import 'package:notas_gestos/detector_inclinacion.dart';

void main() {
  group('Pruebas unitarias de DetectorInclinacion (Ampliación)', () {
    late DetectorInclinacion detector;
    final t0 = DateTime(2026, 11, 18, 12, 0, 0);

    setUp(() {
      // Inicializo el detector con umbral de 5.0 m/s² y pausa de 1 segundo
      detector = DetectorInclinacion(
        umbralInclinacion: 5.0,
        pausa: const Duration(seconds: 1),
      );
    });

    // En este test compruebo que si el móvil no está inclinado (eje X bajo), no cambia de pestaña
    test('1. Inclinación débil o vertical: no cambia de pestaña', () {
      final nuevaPestana = detector.procesar(1.2, t0, 0, 2);
      expect(nuevaPestana, isNull);
    });

    // En este test compruebo la inclinación hacia la derecha para pasar a la pestaña 1
    test('2. Inclinación a la derecha (X negativo): avanza de pestaña', () {
      final nuevaPestana = detector.procesar(-6.5, t0, 0, 2);
      expect(nuevaPestana, equals(1));
    });

    // En este test compruebo la inclinación hacia la izquierda para volver a la pestaña 0
    test('3. Inclinación a la izquierda (X positivo): retrocede de pestaña', () {
      final nuevaPestana = detector.procesar(7.0, t0, 1, 2);
      expect(nuevaPestana, equals(0));
    });

    // En este test compruebo que dentro de la ventana de pausa no se producen cambios indeseados
    test('4. Inclinación repetida dentro de la pausa: es ignorada', () {
      // Primer cambio válido en t0
      expect(detector.procesar(-6.0, t0, 0, 2), equals(1));

      // Segundo intento a los 400 ms
      final t400 = t0.add(const Duration(milliseconds: 400));
      final resultadoPausa = detector.procesar(-7.0, t400, 1, 2);
      expect(resultadoPausa, isNull);
    });
  });
}
