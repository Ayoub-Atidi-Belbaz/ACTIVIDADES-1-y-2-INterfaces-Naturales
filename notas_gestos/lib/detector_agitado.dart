import 'dart:math' as math;

/// En esta clase implemento el algoritmo para detectar sacudidas del dispositivo.
/// Lo desacoplo completamente del framework de Flutter para que sea código Dart puro,
/// testeable y determinista.
class DetectorAgitado {
  /// Umbral de aceleración en m/s² a partir del cual considero que se ha producido una sacudida.
  /// Por defecto empleo 15.0 m/s², que filtra movimientos cotidianos al caminar.
  final double umbral;

  /// Tiempo de enfriamiento o pausa mínima tras detectar una sacudida.
  /// Evita disparos múltiples o falsos positivos encadenados en un mismo gesto físico.
  final Duration pausa;

  /// Guardo aquí el instante temporal exacto en el que detecté la última sacudida válida.
  DateTime? _ultimoInstanteAgitado;

  /// Constructor donde inicializo el umbral y la pausa deseada, asignando valores por defecto óptimos.
  DetectorAgitado({
    this.umbral = 15.0,
    this.pausa = const Duration(seconds: 1),
  });

  /// En este método analizo los tres ejes de aceleración lineal (x, y, z) en un instante dado.
  /// Recibo el parámetro [instante] externamente para poder probar la lógica en tests unitarios
  /// sin recurrir a esperas de tiempo real (delays).
  bool procesar(double x, double y, double z, DateTime instante) {
    // Si ya detecté una sacudida y aún no ha transcurrido la ventana de pausa, ignoro la lectura
    if (_ultimoInstanteAgitado != null) {
      final tiempoTranscurrido = instante.difference(_ultimoInstanteAgitado!);
      if (tiempoTranscurrido < pausa) {
        return false;
      }
    }

    // Calculo el módulo euclídeo de la aceleración: raíz cuadrada de (x² + y² + z²)
    final modulo = math.sqrt(x * x + y * y + z * z);

    // Si el módulo supera o iguala el umbral establecido, confirmo la sacudida y actualizo el instante
    if (modulo >= umbral) {
      _ultimoInstanteAgitado = instante;
      return true;
    }

    // Si no supera el umbral, devuelvo false
    return false;
  }

  /// Método de utilidad donde puedo restablecer el estado del detector si lo necesito.
  void reiniciar() {
    _ultimoInstanteAgitado = null;
  }
}
