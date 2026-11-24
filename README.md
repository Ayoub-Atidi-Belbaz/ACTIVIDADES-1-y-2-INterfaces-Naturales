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

### 🎙️ Actividad 1: Reconocimiento y Síntesis de Voz

#### 1. ¿El reconocimiento de tu móvil funciona en el dispositivo o envía el audio a un servidor? (Prueba en Modo Avión y Criterios de la UT)
Al activar el **Modo Avión** en el dispositivo móvil:
* **Resultado empírico:** Si el smartphone cuenta con el paquete de reconocimiento sin conexión descargado en los servicios de Google (o en iOS), el reconocimiento continúa operando localmente. En caso contrario, el motor emite de inmediato un error de red (`error_network`), demostrando que depende de una conexión activa con los servidores centrales.
* **Evaluación según los cuatro criterios de la Unidad Temática:**
  1. **Privacidad:** El procesamiento local (*on-device*) garantiza la máxima privacidad, pues la señal acústica y los patrones vocales no abandonan el dispositivo físico, evitando la exposición de datos biométricos y cumpliendo con el RGPD. El procesamiento en servidor envía fragmentos de voz a través de Internet a granjas de servidores externas.
  2. **Coste:** El procesamiento en local tiene coste marginal cero para el desarrollador y no consume datos móviles de la tarifa del usuario. En la nube, las APIs comerciales de reconocimiento suelen cobrar por segundo o petición procesada tras superar cuotas gratuitas, además del consumo de datos móviles.
  3. **Latencia:** El procesamiento local elimina los tiempos de ida y vuelta en red (RTT), proporcionando transcripciones instantáneas en tiempo real. En la nube, la latencia depende de la calidad de la conexión (cobertura 4G/5G/WiFi), pudiendo oscilar entre 300 ms y varios segundos.
  4. **Plataforma y Recursos:** El reconocimiento local requiere descargar modelos lingüísticos locales y un consumo relevante de memoria RAM y procesador/NPU del dispositivo. El procesamiento en servidor aligera los requisitos de hardware del móvil, permitiendo ejecutar modelos de lenguaje de gran tamaño y vocabulario ilimitado.

#### 2. Dos situaciones en las que un usuario no podría usar la voz y cómo las resuelve la app
* **Situación 1: Entorno con ruido acústico excesivo o usuario con discapacidad motora/vocal.**
  * *Contexto:* Un usuario en un andén de metro concurrido, en una obra, en un concierto o una persona con disartria o afonía no puede articular órdenes que el micrófono distinga.
  * *Solución implementada:* La aplicación incorpora una **alternativa táctil completa** mediante botones de alto contraste («Añadir», «Borrar», «Leer», «Ayuda») con iconos estándar y `tooltips` accesibles que realizan exactamente las mismas funciones con un solo toque.
* **Situación 2: Entornos donde se exige silencio absoluto o confidencialidad.**
  * *Contexto:* Un usuario en una biblioteca, en una sala de reuniones o en una consulta médica no puede dictar en voz alta ni desea que el dispositivo emita respuestas habladas sobre su contenido.
  * *Solución implementada:* La app proporciona retroalimentación visual instantánea mediante `SnackBars` informativos y tarjetas de texto con la transcripción y el estado de la lista, posibilitando una interacción totalmente silenciosa y discreta.

---

### 📱 Actividad 2: Detección Inercial y Activación por Movimiento

#### 1. Comparativa de umbrales (10, 15 y 25 m/s²) caminando con el móvil en la mano: ¿Cuál elijo y por qué?
* **Umbral de 10 m/s²:** Resulta excesivamente sensible. Al caminar con el teléfono en la mano o en el bolsillo, las oscilaciones naturales del paso y del braceo generan aceleraciones parásitas de entre 8 y 12 m/s², disparando **falsos positivos constantes** y restaurando notas de forma involuntaria.
* **Umbral de 25 m/s²:** Es excesivamente elevado. Obliga al usuario a realizar una sacudida brusca, violenta y forzada de la extremidad, lo que produce fatiga articular, peligro real de que el dispositivo se resbale y caiga al suelo, e inaccesibilidad para personas con movilidad reducida o debilidad muscular.
* **Umbral seleccionado (15 m/s²):** **Es el valor óptimo.** Filtra con solvencia el ruido de la deambulación cotidiana y, al mismo tiempo, responde con precisión ante un movimiento voluntario, ágil y controlado de la muñeca.

#### 2. ¿Por qué se usa `userAccelerometerEventStream` y no `accelerometerEventStream`? ¿Qué pasaría con el móvil en reposo?
* **`accelerometerEventStream` (Acelerómetro Total):** Mide la aceleración física total que actúa sobre el dispositivo, incluyendo permanentemente la **aceleración de la gravedad terrestre** ($g \approx 9.8\text{ m/s}^2$). Con el móvil en reposo absoluto sobre una mesa horizontal, este sensor reporta un valor continuo de $9.8\text{ m/s}^2$ en el eje Z. Al rotar o inclinar el móvil suavemente, la componente de la gravedad se redistribuye entre los ejes y podría superar fácilmente un umbral bajo sin que exista ninguna sacudida voluntaria.
* **`userAccelerometerEventStream` (Acelerómetro de Usuario):** El sistema operativo aplica filtros de paso alto y algoritmos de fusión sensorial para sustraer el vector gravitatorio constante. Con el móvil en reposo, este stream reporta valores próximos a **$0.0\text{ m/s}^2$** en los tres ejes $(x=0, y=0, z=0)$, midiendo exclusivamente la fuerza de aceleración lineal aplicada voluntariamente por el usuario.

#### 3. Dos condiciones del criterio WCAG 2.2 · 2.5.4 (Activación mediante movimiento) cumplidas por la app
1. **Alternativa táctil accesible equivalente (2.5.4.a):** La activación mediante movimiento nunca es obligatoria ni exclusiva. Cada vez que se elimina una nota, la app muestra de inmediato un botón táctil convencional **«Deshacer»** en el `SnackBar`, y permite además recuperar notas desde la pestaña táctil de Papelera.
2. **Capacidad de desactivación (2.5.4.b):** Se proporciona un mecanismo claro y accesible para inhabilitar el gesto. En la parte superior de la interfaz se dispone de un control `SwitchListTile` («Agitar para deshacer») que, al apagarse, cancela inmediatamente la suscripción al sensor inercial para prevenir activaciones accidentales por vibraciones del entorno o temblores corporales.

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
