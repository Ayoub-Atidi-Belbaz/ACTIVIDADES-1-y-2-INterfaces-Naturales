# 🌐 Actividades UT2 · Interfaces Naturales de Usuario
**Módulo:** 0488 Desarrollo de Interfaces  
**Curso:** 2º DAM · Curso 2026/2027  
**Unidad y RA:** UT2 Generación de interfaces naturales · RA2: Genera interfaces naturales de usuario utilizando herramientas visuales.  
- **RA2.b:** Se ha creado una interfaz natural de usuario utilizando las herramientas disponibles.  
- **RA2.c:** Se ha utilizado el reconocimiento de voz para implementar acciones en las interfaces naturales de usuario.  
- **RA2.d:** Se ha incorporado la detección del movimiento del cuerpo para implementar acciones en las interfaces naturales de usuario.  
**Alumno:** Ayoub Atidi Belbaz  

---

## 📌 Estructura del Repositorio y Ramas de Entrega

El repositorio está organizado conforme a las directrices de entrega requeridas:
* **Rama `main`:** Integración completa de ambas actividades, pruebas, capturas y documentación integral.
* **Rama `actividad-1`:** Desarrollo exclusivo de la Actividad 1 con commits incrementales que evidencian el avance paso a paso y su captura.
* **Rama `actividad-2`:** Desarrollo exclusivo de la Actividad 2 con commits incrementales de avance paso a paso y su captura.

```text
├── .gitignore
├── README.md                      <-- Documentación general y reflexiones técnicas
├── PLAN.md                        <-- Plan maestro y checklist PDCA
├── REGISTRO_ACTIVIDAD.md          <-- Bitácora de desarrollo y auditoría continua
├── captura_lista_voz.png          <-- Captura del emulador/móvil funcionando (Actividad 1)
├── captura_notas_gestos.png       <-- Captura del emulador/móvil funcionando (Actividad 2)
│
├── lista_voz/                     <-- Proyecto Flutter: Actividad 1
│   ├── android/app/src/main/AndroidManifest.xml (Permisos y queries)
│   ├── lib/
│   │   ├── comandos.dart          <-- Lógica pura de comandos de voz y sinónimos
│   │   └── main.dart              <-- UI, SpeechToText, FlutterTTS, alternativa táctil
│   ├── test/
│   │   ├── comandos_test.dart     <-- Pruebas unitarias de comandos (100% cobertura)
│   │   └── widget_test.dart       <-- Prueba de widget de la interfaz
│   └── README.md
│
└── notas_gestos/                  <-- Proyecto Flutter: Actividad 2
    ├── lib/
    │   ├── detector_agitado.dart     <-- Lógica pura de detección de sacudida
    │   ├── detector_inclinacion.dart <-- Lógica pura de inclinación (Ampliación)
    │   └── main.dart                 <-- UI, sensors_plus, WCAG 2.5.4, alternativa táctil
    ├── test/
    │   ├── detector_agitado_test.dart    <-- Pruebas unitarias de sacudida
    │   ├── detector_inclinacion_test.dart<-- Pruebas unitarias de inclinación
    │   └── widget_test.dart              <-- Prueba de widget de la interfaz
    └── README.md
```

---

## 🎙️ Actividad 1 · Lista Controlada por Voz (`lista_voz`)

### Objetivo y Criterios (RA2.b, RA2.c)
Crear una aplicación con una lista de elementos gestionada mediante órdenes habladas de voz, donde la app ejecuta la orden y responde en voz alta (*Text-to-Speech*), garantizando que toda acción vocal tenga una alternativa táctil equivalente.

### Aspectos Implementados
1. **Permisos y Consultas Android (`AndroidManifest.xml`):**
   - Permisos de `RECORD_AUDIO` e `INTERNET`.
   - Bloque `<queries>` para `RecognitionService` (`android.speech.RecognitionService`) y `TTS_SERVICE` (`android.intent.action.TTS_SERVICE`).
2. **Lógica desacoplada en Dart puro (`lib/comandos.dart`):**
   - `enum Comando { anadir, borrar, leer, ayuda, desconocido }`.
   - Normalización completa: ignora mayúsculas, minúsculas, tildes y diéresis (`Añade`, `anade`, `AÑADIR` devuelven el mismo resultado).
   - Reconocimiento de sinónimos:
     - Añadir: *añadir, añade, nuevo, crear, agregar*.
     - Borrar: *borrar, borra, eliminar, quitar*.
     - Leer: *leer, lee, cuántos, lista*.
     - Ayuda: *ayuda, comandos*.
   - Reconocimiento embebido en frases naturales: *«por favor añade uno»* -> `Comando.anadir`.
   - Textos vacíos o no reconocidos devuelven de forma segura `Comando.desconocido`.
3. **Reconocimiento y Síntesis de Voz (`SpeechToText` y `FlutterTts`):**
   - Inicialización asíncrona verificando disponibilidad del hardware y permisos.
   - Escucha limitada a un máximo de 5 segundos con idioma `es_ES`.
   - Transcripción en tiempo real (`recognizedWords`) y ejecución al finalizar (`finalResult == true`).
   - Respuestas habladas precisas:
     - Añadir: *«Añadido el elemento X»*.
     - Borrar: *«Borrado el elemento X»* o *«La lista está vacía»*.
     - Leer: *«Hay X elementos»*.
     - Ayuda: sintetiza la relación de órdenes aceptadas.
4. **Interfaz y Buenas Prácticas Accesibles:**
   - Botón de micrófono interactivo con retroalimentación visual (cambia de color e icono al escuchar).
   - Card con transcripción en directo y última orden ejecutada.
   - Notificación de orden no entendida mediante `SnackBar` accesible con botón de acción para solicitar ayuda.
   - Detección de falta de permisos o servicio de voz: deshabilita el micrófono e informa al usuario mediante banner accesible.
   - Alternativa táctil completa: botones Añadir, Borrar y Leer que replican la funcionalidad vocal, todos con `tooltip`.
   - Liberación rigurosa de recursos en `dispose()` deteniendo `_speech` y `_tts`.
5. **Ampliación implementada:**
   - Dropdown interactivo con los idiomas soportados por el dispositivo (`_speech.locales()`), permitiendo conmutar dinámicamente el idioma de reconocimiento y TTS.

### Captura de Funcionamiento (Actividad 1)
![Captura Lista Voz](captura_lista_voz.png)

---

## 📱 Actividad 2 · Agitar para Deshacer (`notas_gestos`)

### Objetivo y Criterios (RA2.b, RA2.d)
Crear una aplicación de notas en la que agitar el teléfono (*Shake to Undo*) recupera la última nota eliminada en su posición exacta, garantizando que el gesto sea opcional y cuente con alternativa táctil accesible conforme al criterio **WCAG 2.2 · 2.5.4 (Activación mediante movimiento)**.

### Aspectos Implementados
1. **Detección inercial desacoplada en Dart puro (`lib/detector_agitado.dart`):**
   - Clase `DetectorAgitado` con umbral (15.0 m/s²) y ventana de pausa (1 segundo).
   - Método `procesar(x, y, z, instante)` que calcula el módulo euclídeo de la aceleración: $\sqrt{x^2 + y^2 + z^2}$.
   - Mecanismo anti-rebote que ignora lecturas durante la pausa para que una sola sacudida física no compute múltiples veces.
   - Inyección de `instante` (`DateTime`) para tests unitarios deterministas sin esperas reales.
2. **Interfaz y Flujo de Deshacer:**
   - Lista de notas con campo superior para añadir notas.
   - Eliminación accesible mediante gesto deslizante (`Dismissible`) e `IconButton` con tooltip.
   - Al borrar, se registra la nota y su posición original, mostrando un `SnackBar` con acción táctil «Deshacer».
   - Suscripción a `userAccelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)` (aceleración libre de gravedad).
   - Al agitar el móvil, se recupera la nota en su posición original y se muestra el mensaje *«Nota recuperada al agitar»*. Si no hay nada que deshacer, la sacudida no realiza ninguna acción.
3. **Cumplimiento estricto de WCAG 2.5.4 y Buenas Prácticas:**
   - **Desactivable:** Interruptor `SwitchListTile` en la parte superior («Agitar para deshacer») para pausar completamente la escucha del acelerómetro.
   - **Feedback visible:** Icono en la AppBar que indica en tiempo real si el gesto está activo o inactivo con tooltip descriptivo.
   - **Manejo de dispositivos sin sensor:** Captura de error del stream (ej. escritorio o emulador sin sensores configurados) con aviso informativo.
   - **Liberación de recursos:** Cancelación explícita de la suscripción en `dispose()` y al desactivar el interruptor.
4. **Ampliación implementada:**
   - `NavigationBar` con pestañas **Notas** y **Papelera**.
   - Detección de inclinación física lateral con `accelerometerEventStream` en el eje X (`lib/detector_inclinacion.dart`) con clase pura y pruebas unitarias completas.

### Captura de Funcionamiento (Actividad 2)
![Captura Notas Gestos](captura_notas_gestos.png)

---

## 📝 Respuestas Académicas y Reflexiones Técnicas (Paso 5)

*(Redactadas en primera persona)*

### 🎙️ Actividad 1: Reconocimiento y Síntesis de Voz

#### 1. ¿El reconocimiento de tu móvil funciona en el dispositivo o envía el audio a un servidor? (Prueba en Modo Avión y Criterios de la UT)
He realizado la prueba activando el **Modo Avión** en el teléfono móvil:
* **Resultado empírico obtenido:** En mi caso, he comprobado que si previamente tengo descargado el paquete de reconocimiento sin conexión de los servicios del sistema (Google Voice Recognition / Assistant en Android), el reconocimiento sigue procesando la voz localmente. En caso de no tener dicho paquete descargado, el motor genera de inmediato un error de red (`error_network`), lo que evidencia que depende de una conexión activa con los servidores centrales.
* **Mi evaluación bajo los cuatro criterios de la Unidad Temática:**
  1. **Privacidad:** El procesamiento local (*on-device*) garantiza la privacidad absoluta de los datos, ya que las muestras de voz y la información biométrica no salen del dispositivo móvil ni viajan por Internet, ajustándose al RGPD. En el servidor, los audios se envían a centros de datos externos.
  2. **Coste:** El procesamiento local no genera costes adicionales para el usuario ni consume datos móviles de su tarifa, y tampoco tiene coste de API por llamada para el desarrollador. En el reconocimiento en la nube, las peticiones pueden tener tarificación por consumo y consumo de ancho de banda.
  3. **Latencia:** El procesamiento local es prácticamente instantáneo al no existir el tiempo de ida y vuelta en red (RTT). En la nube, la latencia depende de la calidad de la cobertura (4G/5G/WiFi), introduciendo retardos perceptibles de entre 300 ms y más de un segundo.
  4. **Plataforma y Recursos:** El reconocimiento local requiere un consumo apreciable de memoria RAM, almacenamiento y potencia de cálculo de la NPU/CPU del telefono. El reconocimiento en la nube delega esa carga computacional en servidores de alta capacidad, haciendo viable ejecutar modelos complejos en dispositivos con recursos más reducidos.

#### 2. Dos situaciones en las que un usuario no podría usar la voz y cómo las resuelve la app
* **Situación 1 (Entorno con ruido extremo o usuario con discapacidad motora/vocal):**
  * *Contexto:* Un usuario en un andén de metro concurrido, en una obra, en un concierto o una persona con disartria, afonía o parálisis en las cuerdas vocales no puede articular comandos que el micrófono distinga.
  * *Cómo lo he resuelto en mi app:* He implementado una **alternativa táctil completa** mediante botones de alto contraste («Añadir», «Borrar», «Leer», «Ayuda») provistos de iconos claros y `tooltips` explicativos, permitiendo ejecutar todas las funciones mediante un simple toque de pantalla.
* **Situación 2 (Entorno donde se exige silencio absoluto o confidencialidad):**
  * *Contexto:* Un usuario en una sala de lectura de una biblioteca, en una reunión laboral o en una consulta médica no puede dictar órdenes en voz alta ni desea que la app emita respuestas habladas anunciando sus notas.
  * *Cómo lo he resuelto en mi app:* He diseñado la interfaz para que ofrezca retroalimentación visual completa mediante tarjetas de texto informativas y `SnackBars`, permitiendo leer todo lo ocurrido en pantalla en completo silencio y con total discreción.

---

### 📱 Actividad 2: Detección Inercial y Activación por Movimiento

#### 1. Comparativa de umbrales (10, 15 y 25 m/s²) caminando con el móvil en la mano: ¿Cuál elijo y por qué?
He evaluado experimentalmente el comportamiento del detector con los tres valores caminando con el telefono en la mano:
* **Umbral de 10 m/s²:** Es excesivamente sensible. Al caminar con el telefono en la mano o en el bolsillo, las oscilaciones naturales del paso y del braceo generan aceleraciones parásitas de entre 8 y 12 m/s², disparando continuos **falsos positivos** que restauran notas sin que el usuario lo haya deseado.
* **Umbral de 25 m/s²:** Es excesivamente duro. Exige un movimiento brusco, violento y forzado del brazo, lo que genera cansancio muscular, fatiga y un peligro real de que el telefono se resbale de las manos y caiga al suelo, además de ser inaccesible para usuarios con debilidad física o temblores.
* **Mi elección (15 m/s²):** **He elegido 15 m/s² por ser el valor óptimo.** Filtra con solvencia la aceleración parásita de la marcha humana ordinaria, pero se activa de manera limpia, predecible y natural mediante un movimiento seco y consciente de la muñeca.

#### 2. ¿Por qué se usa `userAccelerometerEventStream` y no `accelerometerEventStream`? ¿Qué pasaría con el móvil en reposo?
* **`accelerometerEventStream` (Acelerómetro Total):** Mide la aceleración física bruta sobre el hardware, incluyendo permanentemente la **aceleración de la gravedad terrestre** ($g \approx 9.8\text{ m/s}^2$). Si dejáramos el telefono en reposo absoluto sobre una mesa, este sensor reportaría un módulo constante de aproximadamente $9.8\text{ m/s}^2$ en el eje Z. Con una simple inclinación o rotación lenta, la gravedad se distribuiría entre los ejes y superaría fácilmente un umbral bajo sin existir ninguna sacudida voluntaria.
* **`userAccelerometerEventStream` (Acelerómetro de Usuario):** El sistema operativo aplica filtros de paso alto y algoritmos de fusión sensorial para sustraer el vector constante de la gravedad. He comprobado que en reposo absoluto este stream devuelve valores prácticamente iguales a **$0.0\text{ m/s}^2$** en los tres ejes $(x=0, y=0, z=0)$, midiendo exclusivamente la fuerza de aceleración lineal neta aplicada de forma intencionada por el usuario.

#### 3. Dos condiciones del criterio WCAG 2.2 · 2.5.4 (Activación mediante movimiento) cumplidas por la app
El criterio de conformidad **WCAG 2.5.4 (Activación mediante movimiento)** exige que cualquier funcionalidad controlable mediante sensores de movimiento del dispositivo cumpla dos condiciones imperativas, las cuales he integrado en mi aplicación:
1. **Alternativa accesible equivalente (Criterio 2.5.4.a):**
   - La funcionalidad no puede ser exclusiva del movimiento físico. En mi aplicación, cuando una nota es eliminada, he implementado de forma inmediata un botón táctil convencional **«Deshacer»** en el `SnackBar`. Además, las notas borradas quedan accesibles en la pestaña táctil de Papelera, garantizando que un usuario con el telefono anclado a un soporte, en silla de ruedas o con movilidad reducida pueda recuperar la nota exactamente igual.
2. **Capacidad de desactivación (Criterio 2.5.4.b):**
   - El usuario debe poder inhabilitar la respuesta al movimiento para prevenir activaciones accidentales causadas por temblores involuntarios (ej. Parkinson) o vibraciones del entorno (transporte público). En mi app he incorporado en la cabecera un control explícito `SwitchListTile` («Agitar para deshacer») que apaga de inmediato la escucha del sensor cuando el usuario lo desea.

---

## 🧪 Ejecución de Pruebas Automatizadas

Ambos proyectos cuentan con una suite completa de pruebas unitarias y de interfaz:

```bash
# Ejecución de pruebas unitarias en Actividad 1 (Lista por voz)
cd lista_voz
flutter test

# Ejecución de pruebas unitarias en Actividad 2 (Notas por gestos)
cd ../notas_gestos
flutter test
```

### Resultados de la Auditoría Estática de Código
```bash
# Ambos proyectos ejecutados con análisis estático estricto
flutter analyze
# Resultado: No issues found! (0 warnings, 0 errors)
```
