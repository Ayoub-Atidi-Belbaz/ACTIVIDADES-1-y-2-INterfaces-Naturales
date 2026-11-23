import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'detector_agitado.dart';
import 'detector_inclinacion.dart';

void main() {
  runApp(const NotasGestosApp());
}

/// En esta clase configuro la raíz de la aplicación con un tema Material 3 visualmente pulido.
class NotasGestosApp extends StatelessWidget {
  const NotasGestosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notas con Gestos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
      home: const PantallaNotas(),
    );
  }
}

/// Pantalla principal donde gestiono la lista de notas y la escucha de sensores inerciales.
class PantallaNotas extends StatefulWidget {
  const PantallaNotas({super.key});

  @override
  State<PantallaNotas> createState() => _PantallaNotasState();
}

/// Estructura de datos que uso para guardar una nota eliminada con su posición exacta.
class _NotaEliminada {
  final String texto;
  final int posicion;

  _NotaEliminada({required this.texto, required this.posicion});
}

class _PantallaNotasState extends State<PantallaNotas> {
  // Lista de notas activas
  final List<String> _notas = [
    'Comprar leche y fruta',
    'Preparar entrega de Interfaces Naturales (UT2)',
    'Revisar criterios de accesibilidad WCAG 2.5.4',
  ];

  // Papelera de notas para la ampliación de dos pestañas
  final List<String> _papelera = [];

  // Almaceno aquí la última nota borrada y su posición original para poder deshacer
  _NotaEliminada? _ultimaNotaBorrada;

  // Controlador del campo de texto para redactar notas nuevas
  final TextEditingController _controladorTexto = TextEditingController();

  // Instancias de mis detectores en Dart puro
  final DetectorAgitado _detectorAgitado = DetectorAgitado(
    umbral: 15.0,
    pausa: const Duration(seconds: 1),
  );
  final DetectorInclinacion _detectorInclinacion = DetectorInclinacion(
    umbralInclinacion: 5.0,
    pausa: const Duration(milliseconds: 1200),
  );

  // Suscripciones a los streams de los sensores físicos
  StreamSubscription<UserAccelerometerEvent>? _suscripcionAgitado;
  StreamSubscription<AccelerometerEvent>? _suscripcionInclinacion;

  // Estados de control de la interfaz y sensores
  bool _agitarActivo = true;
  final bool _inclinacionActiva = true;
  bool _tieneAcelerometro = true;
  String? _mensajeErrorSensor;

  // Índice de la pestaña actual en la NavigationBar (0: Notas, 1: Papelera)
  int _indicePestana = 0;

  @override
  void initState() {
    super.initState();
    // Al iniciar la pantalla, suscribo los sensores de aceleración
    _iniciarSuscripcionAgitado();
    _iniciarSuscripcionInclinacion();
  }

  /// Aquí inicio la escucha del acelerómetro de usuario (sin gravedad) para detectar sacudidas.
  void _iniciarSuscripcionAgitado() {
    // Si ya existe una suscripción previa la cancelo para no duplicar listeners
    _cancelarSuscripcionAgitado();

    if (!_agitarActivo) return;

    try {
      _suscripcionAgitado = userAccelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        (UserAccelerometerEvent evento) {
          // Paso las coordenadas x, y, z al detector desacoplado junto al instante actual
          final huboSacudida = _detectorAgitado.procesar(
            evento.x,
            evento.y,
            evento.z,
            DateTime.now(),
          );

          // Si el detector confirma la sacudida, intento recuperar la última nota borrada
          if (huboSacudida) {
            _deshacerPorAgitado();
          }
        },
        onError: (dynamic error) {
          // Si el sensor no existe en este dispositivo (ej. escritorio o emulador sin sensor)
          if (mounted) {
            setState(() {
              _tieneAcelerometro = false;
              _agitarActivo = false;
              _mensajeErrorSensor = 'Este dispositivo no tiene acelerómetro disponible.';
            });
            _cancelarSuscripcionAgitado();
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _tieneAcelerometro = false;
          _agitarActivo = false;
          _mensajeErrorSensor = 'Este dispositivo no tiene acelerómetro.';
        });
      }
    }
  }

  /// En este método inicio la escucha del acelerómetro total para la ampliación de inclinación.
  void _iniciarSuscripcionInclinacion() {
    _cancelarSuscripcionInclinacion();

    if (!_inclinacionActiva) return;

    try {
      _suscripcionInclinacion = accelerometerEventStream(
        samplingPeriod: SensorInterval.uiInterval,
      ).listen(
        (AccelerometerEvent evento) {
          // Proceso la inclinación en el eje X para conmutar entre pestañas
          final nuevoIndice = _detectorInclinacion.procesar(
            evento.x,
            DateTime.now(),
            _indicePestana,
            2,
          );

          if (nuevoIndice != null && nuevoIndice != _indicePestana && mounted) {
            setState(() {
              _indicePestana = nuevoIndice;
            });
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  nuevoIndice == 0
                      ? 'Inclinación detectada: Cambiado a Notas'
                      : 'Inclinación detectada: Cambiado a Papelera',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        onError: (_) {
          _cancelarSuscripcionInclinacion();
        },
        cancelOnError: true,
      );
    } catch (_) {}
  }

  /// Cancelo la suscripción al acelerómetro de usuario para liberar recursos.
  void _cancelarSuscripcionAgitado() {
    _suscripcionAgitado?.cancel();
    _suscripcionAgitado = null;
  }

  /// Cancelo la suscripción al sensor de inclinación para liberar recursos.
  void _cancelarSuscripcionInclinacion() {
    _suscripcionInclinacion?.cancel();
    _suscripcionInclinacion = null;
  }

  /// En este método conmuto la preferencia del usuario sobre el gesto de agitar (WCAG 2.5.4).
  void _conmutarAgitado(bool activar) {
    setState(() {
      _agitarActivo = activar;
    });

    if (activar) {
      _iniciarSuscripcionAgitado();
    } else {
      _cancelarSuscripcionAgitado();
    }
  }

  /// En este método añado una nota a la lista tras validar el campo de texto.
  void _anadirNota() {
    final texto = _controladorTexto.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _notas.insert(0, texto);
      _controladorTexto.clear();
    });
  }

  /// En este método borro una nota, guardo su posición para deshacer y muestro la alternativa táctil.
  void _borrarNota(int indice) {
    final notaEliminada = _notas[indice];

    setState(() {
      _notas.removeAt(indice);
      _papelera.insert(0, notaEliminada);
      _ultimaNotaBorrada = _NotaEliminada(texto: notaEliminada, posicion: indice);
    });

    // Muestro el SnackBar con el botón táctil «Deshacer» (criterio WCAG 2.5.4)
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nota borrada: "$notaEliminada"'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: _restaurarNotaTaktil,
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// En este método restauro la nota usando la alternativa táctil.
  void _restaurarNotaTaktil() {
    _restaurarNota(motivo: 'Nota recuperada con botón Deshacer');
  }

  /// En este método restauro la nota al detectar una sacudida física del móvil.
  void _deshacerPorAgitado() {
    // Si no hay ninguna nota pendiente de deshacer, el gesto no realiza ninguna acción
    if (_ultimaNotaBorrada == null) return;

    _restaurarNota(motivo: 'Nota recuperada al agitar');
  }

  /// Método centralizado donde reinserto la nota eliminada en su posición exacta original.
  void _restaurarNota({required String motivo}) {
    if (_ultimaNotaBorrada == null) return;

    final nota = _ultimaNotaBorrada!;
    setState(() {
      // Reinserto la nota en su índice original de forma segura
      final indiceSeguro = nota.posicion <= _notas.length ? nota.posicion : _notas.length;
      _notas.insert(indiceSeguro, nota.texto);
      _papelera.remove(nota.texto);
      _ultimaNotaBorrada = null; // Limpio el búfer tras recuperar
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(motivo),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.teal.shade700,
      ),
    );
  }

  @override
  void dispose() {
    // Libero aquí rigurosamente los recursos y controladores al destruir la vista
    _cancelarSuscripcionAgitado();
    _cancelarSuscripcionInclinacion();
    _controladorTexto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas con Gestos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Feedback visible en la AppBar con icono y tooltip explicativo
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Tooltip(
              message: !_tieneAcelerometro
                  ? 'Sensor no disponible en este dispositivo'
                  : (_agitarActivo
                      ? 'Gesto "Agitar para deshacer" ACTIVO'
                      : 'Gesto "Agitar para deshacer" DESACTIVADO'),
              child: Icon(
                _tieneAcelerometro && _agitarActivo
                    ? Icons.vibration
                    : Icons.phone_android,
                color: _tieneAcelerometro && _agitarActivo
                    ? Colors.deepPurple.shade900
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Control SwitchListTile superior para activar o desactivar el gesto (WCAG 2.5.4)
            SwitchListTile(
              title: const Text(
                'Agitar para deshacer',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _tieneAcelerometro
                    ? (_agitarActivo
                        ? 'Agita el móvil tras borrar para recuperar la nota'
                        : 'El sensor de movimiento está pausado')
                    : 'Acelerómetro no disponible',
              ),
              secondary: Icon(
                Icons.screen_rotation_alt,
                color: _agitarActivo && _tieneAcelerometro ? Colors.deepPurple : Colors.grey,
              ),
              value: _agitarActivo && _tieneAcelerometro,
              onChanged: _tieneAcelerometro ? _conmutarAgitado : null,
            ),

            // Banner explicativo si el dispositivo carece de acelerómetro
            if (!_tieneAcelerometro || _mensajeErrorSensor != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade700),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade900),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _mensajeErrorSensor ?? 'Este dispositivo no tiene acelerómetro.',
                        style: TextStyle(color: Colors.amber.shade900, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            const Divider(height: 1),

            // Vista según la pestaña activa (0: Notas, 1: Papelera)
            Expanded(
              child: _indicePestana == 0 ? _construirVistaNotas() : _construirVistaPapelera(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indicePestana,
        onDestinationSelected: (indice) {
          setState(() {
            _indicePestana = indice;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.note_alt_outlined),
            selectedIcon: const Icon(Icons.note_alt),
            label: 'Notas (${_notas.length})',
          ),
          NavigationDestination(
            icon: const Icon(Icons.delete_outline),
            selectedIcon: const Icon(Icons.delete),
            label: 'Papelera (${_papelera.length})',
          ),
        ],
      ),
    );
  }

  /// Vista de gestión de notas principales
  Widget _construirVistaNotas() {
    return Column(
      children: [
        // Campo de entrada de texto para redactar una nueva nota
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controladorTexto,
                  decoration: const InputDecoration(
                    labelText: 'Escribe una nueva nota...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit_note),
                  ),
                  onSubmitted: (_) => _anadirNota(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.add),
                tooltip: 'Añadir nota a la lista',
                onPressed: _anadirNota,
              ),
            ],
          ),
        ),

        // Barra informativa de estado del búfer de deshacer
        if (_ultimaNotaBorrada != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.deepPurple.shade50,
            child: Row(
              children: [
                const Icon(Icons.restore, size: 18, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hay una nota lista para recuperar: "${_ultimaNotaBorrada!.texto}"',
                    style: TextStyle(
                      color: Colors.deepPurple.shade900,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: _restaurarNotaTaktil,
                  child: const Text('Recuperar'),
                ),
              ],
            ),
          ),

        // Lista de notas con soporte para Dismissible e IconButton
        Expanded(
          child: _notas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notes, size: 54, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'No tienes notas pendientes',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Escribe arriba y pulsa "+" para añadir',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _notas.length,
                  itemBuilder: (context, index) {
                    final nota = _notas[index];
                    return Dismissible(
                      // Clave única basada en la nota y su índice para evitar colisiones
                      key: ValueKey('$nota-$index'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red.shade700,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Borrar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.delete, color: Colors.white),
                          ],
                        ),
                      ),
                      onDismissed: (_) {
                        _borrarNota(index);
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple.shade100,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Colors.deepPurple.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(nota),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            tooltip: 'Borrar nota',
                            onPressed: () => _borrarNota(index),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Vista de Papelera (Ampliación)
  Widget _construirVistaPapelera() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Papelera de reciclaje (${_papelera.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (_papelera.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.delete_forever, size: 18),
                  label: const Text('Vaciar'),
                  onPressed: () {
                    setState(() {
                      _papelera.clear();
                      _ultimaNotaBorrada = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Papelera vaciada por completo'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _papelera.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline, size: 54, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'La papelera está vacía',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _papelera.length,
                  itemBuilder: (context, index) {
                    final textoPapelera = _papelera[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      color: Colors.grey.shade50,
                      child: ListTile(
                        leading: const Icon(Icons.restore_from_trash, color: Colors.deepPurple),
                        title: Text(
                          textoPapelera,
                          style: const TextStyle(decoration: TextDecoration.lineThrough),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.unarchive, color: Colors.teal),
                          tooltip: 'Restaurar a Notas',
                          onPressed: () {
                            setState(() {
                              _papelera.removeAt(index);
                              _notas.add(textoPapelera);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Nota "$textoPapelera" restaurada'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
