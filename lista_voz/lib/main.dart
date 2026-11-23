import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'comandos.dart';

void main() {
  runApp(const ListaVozApp());
}

/// En esta clase configuro la aplicación principal con el tema visual accesible y consistente.
class ListaVozApp extends StatelessWidget {
  const ListaVozApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista Controlada por Voz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      home: const PantallaListaVoz(),
    );
  }
}

/// Pantalla principal interactiva donde integro el reconocimiento y síntesis de voz.
class PantallaListaVoz extends StatefulWidget {
  const PantallaListaVoz({super.key});

  @override
  State<PantallaListaVoz> createState() => _PantallaListaVozState();
}

class _PantallaListaVozState extends State<PantallaListaVoz> {
  // Instancio aquí los motores de voz: reconocimiento (SpeechToText) y síntesis (FlutterTts)
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  // Variables de control de estado que gestiono
  bool _speechDisponible = false;
  bool _estaEscuchando = false;
  String _mensajeErrorServicio = '';

  // Transcripción en tiempo real y registro de la última orden ejecutada
  String _transcripcionActual = 'Presiona el micrófono y di una orden...';
  String _ultimaOrden = 'Ninguna todavía';

  // Lista de elementos manejada por el usuario (voz y táctil)
  final List<String> _elementos = ['Elemento 1', 'Elemento 2'];

  // Variables para la ampliación: selección dinámica de idiomas de reconocimiento y TTS
  List<stt.LocaleName> _idiomasDisponibles = [];
  String _idiomaSeleccionado = 'es_ES';

  @override
  void initState() {
    super.initState();
    // Nada más cargar la pantalla, inicializo ambos servicios de forma asíncrona
    _inicializarServiciosVoz();
  }

  /// En este método inicializo el motor de reconocimiento y configuro el sintetizador de voz.
  Future<void> _inicializarServiciosVoz() async {
    try {
      // Configuro la síntesis de voz inicial en español de España
      await _tts.setLanguage('es-ES');
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5);

      // Inicializo el reconocimiento de voz verificando permisos y disponibilidad del servicio
      final disponible = await _speech.initialize(
        onStatus: (status) {
          // Actualizo el estado visual cuando el motor cambia entre escuchando, detenido, etc.
          if (mounted) {
            setState(() {
              _estaEscuchando = (status == 'listening');
            });
          }
        },
        onError: (errorNotification) {
          // Manejo errores del servicio de voz (por ejemplo, desconexión o falta de audio)
          if (mounted) {
            setState(() {
              _estaEscuchando = false;
              _mensajeErrorServicio = 'Aviso de voz: ${errorNotification.errorMsg}';
            });
          }
        },
      );

      // Si el motor está disponible, cargo los idiomas instalados para la ampliación
      List<stt.LocaleName> locales = [];
      if (disponible) {
        locales = await _speech.locales();
      }

      if (mounted) {
        setState(() {
          _speechDisponible = disponible;
          _idiomasDisponibles = locales;
          if (!disponible) {
            _mensajeErrorServicio =
                'El reconocimiento de voz no está disponible o faltan permisos en el dispositivo.';
          }
        });
      }
    } catch (e) {
      // Capturo excepciones en plataformas sin soporte nativo o sin permisos
      if (mounted) {
        setState(() {
          _speechDisponible = false;
          _mensajeErrorServicio = 'No se ha podido inicializar la voz: $e';
        });
      }
    }
  }

  /// Método en el que sintetizo voz hacia el usuario para darle feedback auditivo.
  Future<void> _hablar(String texto) async {
    try {
      await _tts.stop(); // Detengo cualquier frase anterior para no solapar audios
      await _tts.speak(texto);
    } catch (_) {
      // En caso de que falle la síntesis no bloqueamos la experiencia de usuario
    }
  }

  /// Aquí inicio o detengo la escucha activa de hasta 5 segundos según el documento.
  Future<void> _conmutarEscucha() async {
    // Si no está disponible el reconocimiento, informo mediante un aviso visual
    if (!_speechDisponible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El micrófono no está habilitado o no hay permisos.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Si ya estoy escuchando, detengo la sesión
    if (_estaEscuchando) {
      await _speech.stop();
      setState(() {
        _estaEscuchando = false;
      });
      return;
    }

    // Comienzo a escuchar durante un máximo de 5 segundos
    setState(() {
      _transcripcionActual = 'Escuchando... habla ahora';
      _estaEscuchando = true;
    });

    await _speech.listen(
      onResult: (result) {
        // En onResult actualizo en tiempo real lo que el usuario va diciendo
        setState(() {
          _transcripcionActual = result.recognizedWords;
        });

        // Cuando el reconocimiento es definitivo (finalResult == true), ejecuto la orden
        if (result.finalResult) {
          _procesarEntradaVoz(result.recognizedWords);
        }
      },
            listenOptions: stt.SpeechListenOptions(
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
        partialResults: true,
        localeId: _idiomaSeleccionado,
      ),
    );
  }

  /// En este método paso el texto capturado a mi módulo de comandos y ejecuto la acción correspondiente.
  void _procesarEntradaVoz(String frase) {
    final comando = interpretarComando(frase);

    switch (comando) {
      case Comando.anadir:
        _anadirElemento(origenVoz: true);
        break;
      case Comando.borrar:
        _borrarElemento(origenVoz: true);
        break;
      case Comando.leer:
        _leerElementos();
        break;
      case Comando.ayuda:
        _darAyuda();
        break;
      case Comando.desconocido:
        // Si no entendí la orden, muestro un SnackBar explicativo y doy feedback sonoro
        setState(() {
          _ultimaOrden = 'Orden no reconocida: "$frase"';
        });
        final aviso = 'No he entendido "$frase". Di "ayuda" para oír las órdenes.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(aviso),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Ayuda',
              onPressed: _darAyuda,
            ),
          ),
        );
        _hablar('No he entendido "$frase". Di ayuda para oír las órdenes');
        break;
    }
  }

  /// Acción de añadir elemento, invocable tanto por voz como por botón táctil.
  void _anadirElemento({bool origenVoz = false}) {
    setState(() {
      final nuevoIndice = _elementos.length + 1;
      _elementos.add('Elemento $nuevoIndice');
      _ultimaOrden = 'Añadir (Elemento $nuevoIndice)';
    });
    // Respuesta hablada requerida: «Añadido el elemento X»
    _hablar('Añadido el elemento ${_elementos.length}');
  }

  /// Acción de borrar el último elemento, invocable tanto por voz como por botón táctil.
  void _borrarElemento({bool origenVoz = false}) {
    if (_elementos.isEmpty) {
      setState(() {
        _ultimaOrden = 'Borrar (Lista ya vacía)';
      });
      // Respuesta hablada cuando la lista está vacía
      _hablar('La lista está vacía');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La lista está vacía, no se puede borrar nada.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final indiceBorrado = _elementos.length;
    setState(() {
      _elementos.removeLast();
      _ultimaOrden = 'Borrado el elemento $indiceBorrado';
    });
    // Respuesta hablada requerida: «Borrado el elemento X»
    _hablar('Borrado el elemento $indiceBorrado');
  }

  /// Acción de leer el estado de la lista, invocable por voz o por botón táctil.
  void _leerElementos() {
    final cantidad = _elementos.length;
    setState(() {
      _ultimaOrden = 'Leer lista ($cantidad elementos)';
    });
    // Respuesta hablada requerida: «Hay X elementos»
    _hablar('Hay $cantidad elementos');
  }

  /// Acción de ayuda hablada que enumera todas las órdenes aceptadas.
  void _darAyuda() {
    setState(() {
      _ultimaOrden = 'Ayuda solicitada';
    });
    const mensaje =
        'Órdenes disponibles: añadir para crear uno, borrar para quitar el último, leer para saber cuántos hay, y ayuda para repetir esto.';
    _hablar(mensaje);
  }

  /// En este método de la ampliación cambio el idioma de reconocimiento y ajusto el de síntesis.
  void _cambiarIdioma(String? nuevoIdioma) {
    if (nuevoIdioma == null) return;
    setState(() {
      _idiomaSeleccionado = nuevoIdioma;
    });

    // Ajusto también el idioma del TTS al correspondiente para mantener coherencia
    final localeTts = nuevoIdioma.replaceAll('_', '-');
    _tts.setLanguage(localeTts);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Idioma de voz cambiado a: $nuevoIdioma'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    // Libero aquí los recursos deteniendo la escucha y el sintetizador al salir
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Controlada por Voz'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Botón de ayuda táctil siempre visible con tooltip
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Escuchar ayuda de comandos de voz',
            onPressed: _darAyuda,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Panel de selector de idioma (Ampliación) si hay idiomas detectados
            if (_idiomasDisponibles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.language, size: 20),
                    const SizedBox(width: 8),
                    const Text('Idioma voz: '),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _idiomasDisponibles
                                .any((l) => l.localeId == _idiomaSeleccionado)
                            ? _idiomaSeleccionado
                            : _idiomasDisponibles.first.localeId,
                        items: _idiomasDisponibles.map((locale) {
                          return DropdownMenuItem<String>(
                            value: locale.localeId,
                            child: Text(
                              '${locale.name} (${locale.localeId})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: _cambiarIdioma,
                      ),
                    ),
                  ],
                ),
              ),

            // Banner informativo si no hay micrófono o servicio de voz
            if (!_speechDisponible)
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade800),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _mensajeErrorServicio.isNotEmpty
                            ? _mensajeErrorServicio
                            : 'Micrófono no disponible. Puedes usar los botones táctiles.',
                        style: TextStyle(color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),

            // Sección de estado del micrófono y feedback visual
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Botón central de micrófono con cambio interactivo de icono, color y tooltip
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: !_speechDisponible
                            ? Colors.grey.shade400
                            : (_estaEscuchando ? Colors.red.shade600 : Colors.indigo.shade600),
                        boxShadow: _estaEscuchando
                            ? [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.5),
                                  blurRadius: 16,
                                  spreadRadius: 4,
                                )
                              ]
                            : null,
                      ),
                      child: IconButton(
                        iconSize: 56,
                        icon: Icon(
                          !_speechDisponible
                              ? Icons.mic_off
                              : (_estaEscuchando ? Icons.mic : Icons.mic_none),
                          color: Colors.white,
                        ),
                        tooltip: !_speechDisponible
                            ? 'Reconocimiento de voz desactivado'
                            : (_estaEscuchando
                                ? 'Escuchando... pulsa para parar'
                                : 'Pulsa para dar una orden por voz'),
                        onPressed: _speechDisponible ? _conmutarEscucha : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _estaEscuchando
                          ? 'Escuchando orden... (máx 5 seg)'
                          : (_speechDisponible
                              ? 'Pulsa el micrófono para hablar'
                              : 'Reconocimiento no disponible'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _estaEscuchando ? Colors.red.shade700 : Colors.grey.shade700,
                      ),
                    ),
                    const Divider(height: 24),
                    // Transcripción en vivo
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.record_voice_over, size: 20, color: Colors.indigo),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Oído: "$_transcripcionActual"',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Última orden reconocida
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Última orden: $_ultimaOrden',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Alternativa táctil accesible con botones claros y tooltips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Añadir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade50,
                        foregroundColor: Colors.teal.shade800,
                      ),
                      // Tooltip accesible
                      onPressed: () => _anadirElemento(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Borrar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade800,
                      ),
                      onPressed: () => _borrarElemento(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.volume_up_outlined),
                      label: const Text('Leer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue.shade800,
                      ),
                      onPressed: _leerElementos,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Encabezado de la lista con conteo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Elementos en lista (${_elementos.length}):',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Voz: "añade", "borra", "leer"',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // Lista visual de elementos
            Expanded(
              child: _elementos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'La lista está vacía',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Di "añade" o pulsa el botón Añadir',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _elementos.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.shade100,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.indigo.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(_elementos[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.grey),
                              tooltip: 'Borrar ${_elementos[index]}',
                              onPressed: () {
                                setState(() {
                                  final eliminado = _elementos.removeAt(index);
                                  _ultimaOrden = 'Borrado $eliminado';
                                });
                                _hablar('Borrado el elemento ${index + 1}');
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
