/// En esta clase implemento la lógica de detección de inclinación lateral (eje X)
/// para la ampliación de cambio de pestaña entre "Notas" y "Papelera" mediante gestos naturales.
class DetectorInclinacion {
  /// Umbral en m/s² en el eje X para considerar una inclinación intencionada.
  /// Un valor de 5.0 m/s² representa aproximadamente una inclinación de más de 30 grados.
  final double umbralInclinacion;

  /// Periodo de enfriamiento para no alternar pestañas continuamente mientras el móvil sigue inclinado.
  final Duration pausa;

  /// Registro del último instante en el que cambié de pestaña por inclinación.
  DateTime? _ultimoCambio;

  /// Constructor con valores por defecto equilibrados.
  DetectorInclinacion({
    this.umbralInclinacion = 5.0,
    this.pausa = const Duration(milliseconds: 1200),
  });

  /// En este método proceso la lectura del eje X.
  /// Si inclino el dispositivo a la derecha (x negativo por debajo de -umbral), paso a la pestaña siguiente.
  /// Si lo inclino a la izquierda (x positivo por encima de +umbral), paso a la pestaña anterior.
  /// Devuelvo el nuevo índice de pestaña o null si no procede ningún cambio.
  int? procesar(double x, DateTime instante, int pestanaActual, int totalPestanas) {
    if (totalPestanas <= 1) return null;

    // Verifico si estoy dentro de la ventana de pausa para evitar rebotes
    if (_ultimoCambio != null) {
      if (instante.difference(_ultimoCambio!) < pausa) {
        return null;
      }
    }

    // Inclinación hacia la derecha (valores negativos pronunciados en X)
    if (x <= -umbralInclinacion) {
      final nuevoIndice = (pestanaActual + 1) % totalPestanas;
      if (nuevoIndice != pestanaActual) {
        _ultimoCambio = instante;
        return nuevoIndice;
      }
    }

    // Inclinación hacia la izquierda (valores positivos pronunciados en X)
    if (x >= umbralInclinacion) {
      final nuevoIndice = (pestanaActual - 1 + totalPestanas) % totalPestanas;
      if (nuevoIndice != pestanaActual) {
        _ultimoCambio = instante;
        return nuevoIndice;
      }
    }

    return null;
  }

  /// Restablezco el historial para pruebas o cambios de pantalla.
  void reiniciar() {
    _ultimoCambio = null;
  }
}
