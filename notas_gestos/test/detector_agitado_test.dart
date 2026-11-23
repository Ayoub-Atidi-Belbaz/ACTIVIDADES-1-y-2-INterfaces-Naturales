import 'package:flutter_test/flutter_test.dart';
import 'package:notas_gestos/detector_agitado.dart';

void main() {
  group('Pruebas unitarias de DetectorAgitado', () {
    late DetectorAgitado detector;
    final t0 = DateTime(2026, 11, 18, 10, 0, 0);

    setUp(() {
      // Antes de cada test creo una nueva instancia del detector con umbral 15.0 y pausa de 1 segundo
      detector = DetectorAgitado(umbral: 15.0, pausa: const Duration(seconds: 1));
    });

    // En este test compruebo que valores bajos de aceleración (móvil quieto o caminando suave) no activan el detector
    test('1. Reposo: lecturas normales no superan el umbral y devuelven false', () {
      // Valores típicos de reposo o movimiento ligero (aceleración lineal cercana a 0)
      final detectado = detector.procesar(0.5, 0.8, -0.4, t0);
      expect(detectado, isFalse);
    });

    // En este test compruebo que una aceleración fuerte que supera los 15 m/s² activa correctamente el agitado
    test('2. Sacudida: aceleración que supera el umbral devuelve true', () {
      // Módulo: sqrt(10² + 10² + 5²) = sqrt(225) = 15.0 m/s² (alcanza el umbral exacto)
      final detectado = detector.procesar(10.0, 10.0, 5.0, t0);
      expect(detectado, isTrue);
    });

    // En este test compruebo que una segunda sacudida inmediata producida durante la pausa es ignorada
    test('3. Segunda sacudida dentro de la pausa: es ignorada para evitar rebotes', () {
      // Primera sacudida en t0 (válida)
      expect(detector.procesar(12.0, 12.0, 0.0, t0), isTrue);

      // Segunda sacudida fuerte transcurridos solo 500 ms (menor que la pausa de 1 segundo)
      final tMedio = t0.add(const Duration(milliseconds: 500));
      final detectadoEnPausa = detector.procesar(15.0, 15.0, 10.0, tMedio);
      expect(detectadoEnPausa, isFalse);
    });

    // En este test compruebo que una sacudida tras cumplirse el tiempo de pausa vuelve a ser aceptada
    test('4. Sacudida pasada la pausa: transcurrido el tiempo, vuelve a devolver true', () {
      // Primera sacudida en t0
      expect(detector.procesar(16.0, 0.0, 0.0, t0), isTrue);

      // Siguiente sacudida tras 1.2 segundos (mayor que 1 segundo de pausa)
      final tDespues = t0.add(const Duration(milliseconds: 1200));
      final detectadoTrasPausa = detector.procesar(0.0, 18.0, 0.0, tDespues);
      expect(detectadoTrasPausa, isTrue);
    });
  });
}
