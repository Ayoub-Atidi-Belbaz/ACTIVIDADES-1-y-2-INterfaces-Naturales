# 🎙️ Actividad 1 · Lista Controlada por Voz (`lista_voz`)
**Módulo:** 0488 Desarrollo de Interfaces · 2º DAM · Curso 2026/2027  
**Unidad y RA:** UT2 Generación de interfaces naturales · RA2: Genera interfaces naturales de usuario utilizando herramientas visuales.  
- **RA2.b:** Se ha creado una interfaz natural de usuario utilizando las herramientas disponibles.  
- **RA2.c:** Se ha utilizado el reconocimiento de voz para implementar acciones en las interfaces naturales de usuario.  
**Alumno:** Ayoub Atidi Belbaz  

---

## 🎯 Descripción del Proyecto
En esta actividad se ha desarrollado una aplicación en Flutter con interfaz natural de usuario que permite gestionar una lista de elementos tanto mediante comandos de voz en lenguaje natural como a través de controles táctiles accesibles equivalentes, cumpliendo con las pautas WCAG 2.2 y las buenas prácticas de arquitectura de software.

---

## 📸 Captura de Funcionamiento en el Emulador / Móvil
![Captura de Funcionamiento de la Lista Controlada por Voz](captura_lista_voz.png)

---

## 🛠️ Tecnologías y Paquetes Utilizados
- **Flutter 3.x & Dart 3.x**
- **`speech_to_text: ^7.5.0`:** Para capturar el audio del micrófono y transcribirlo a texto en tiempo real.
- **`flutter_tts: ^4.2.5`:** Para sintetizar respuestas de voz auditivas (*Text-To-Speech*) en español (`es-ES`).
- **Permisos y Queries en AndroidManifest.xml:** Declaración de `RECORD_AUDIO`, `INTERNET` y consultas explícitas de intents para `RecognitionService` y `TTS_SERVICE`.

---

## 🧠 Arquitectura y Lógica Pura (`lib/comandos.dart`)
Se ha desacoplado la lógica de interpretación de órdenes en un archivo independiente de Dart puro para permitir pruebas unitarias exhaustivas sin dependencias de interfaz ni del motor nativo:
- **`enum Comando { anadir, borrar, leer, ayuda, desconocido }`**
- **Normalización de texto:** Convierte todo a minúsculas, suprime tildes y diéresis (`á->a`, `é->e`, etc.) y normaliza la letra `ñ->n` para que «Añade», «anade» y «AÑADIR» arrojen idéntico resultado.
- **Soporte de sinónimos:**
  - Añadir: *añadir, añade, nuevo, crear, agregar, agrega*.
  - Borrar: *borrar, borra, eliminar, elimina, quitar, quita*.
  - Leer: *leer, lee, cuántos, cuantas, lista*.
  - Ayuda: *ayuda, comandos, comando*.
- **Inclusión en frases naturales:** Detecta la intención incluso dentro de oraciones complejas como *«por favor añade uno»* o *«quiero borrar el elemento»*.
- **Manejo de entradas vacías o desconocidas:** Cadenas vacías o no relacionadas devuelven con total seguridad `Comando.desconocido`.

---

## 🧪 Pruebas Unitarias y de Widget (`test/`)
Se ha implementado una batería de pruebas automatizadas que cubren el 100% de los casos:
1. Normalización de mayúsculas y tildes para añadir.
2. Sinónimos del comando añadir (`nuevo`, `crear`, `agregar`).
3. Sinónimos del comando borrar (`borrar`, `borra`, `eliminar`, `quitar`).
4. Sinónimos del comando leer (`leer`, `lee`, `cuántos`, `cuantos`, `lista`).
5. Sinónimos del comando ayuda (`ayuda`, `comandos`).
6. Reconocimiento de orden dentro de una frase natural compleja.
7. Manejo seguro de texto vacío o con espacios en blanco (`Comando.desconocido`).
8. Clasificación de órdenes desconocidas o sin palabras clave.
9. Test de integración de widget (`widget_test.dart`) verificando botones táctiles, tooltips y adición en pantalla.

---

## 🌟 Ampliación Implementada
- **Selector Dinámico de Idiomas (`DropdownMenu`):** Consulta en tiempo de ejecución los idiomas soportados por el motor de voz mediante `_speech.locales()` y permite alternar tanto el idioma de escucha como el del sintetizador de voz (TTS).

---

## 📝 Reflexión Técnica y Respuestas Académicas (Paso 5)

*(Respuestas redactadas en primera persona)*

### 1. ¿El reconocimiento de voz funciona en el dispositivo o envía el audio a un servidor? (Prueba en Modo Avión)
He realizado la prueba activando el **Modo Avión** en el teléfono móvil:
- **Comportamiento observado:** En mi caso, he comprobado que si el dispositivo cuenta con el paquete de reconocimiento sin conexión descargado en el sistema operativo (Google Voice / Assistant en Android), el reconocimiento sigue funcionando localmente. Si no está descargado el paquete de voz offline, el motor arroja de inmediato un error de red (`error_network`), indicando que requiere conexión a los servidores de Google.
- **Mi análisis según los 4 criterios de la UT:**
  1. **Privacidad:** El procesamiento *on-device* garantiza que la señal vocal y los datos biométricos del usuario no abandonen el dispositivo móvil, cumpliendo con el RGPD y evitando brechas de seguridad. Por contra, el modelo en la nube envía muestras de audio a centros de datos externos.
  2. **Coste:** El reconocimiento local tiene coste cero recurrente y no consume datos móviles de la tarifa del usuario. El reconocimiento en servidor puede conllevar costes por petición API (en entornos empresariales) y consumo de datos.
  3. **Latencia:** El procesamiento local es instantáneo al eliminar el tiempo de ida y vuelta por la red (RTT). En el servidor, la latencia depende directamente de la cobertura (4G/5G/WiFi), introduciendo retardos perceptibles de entre 300 ms y más de un segundo.
  4. **Plataforma / Recursos:** El reconocimiento local exige mayor consumo de memoria, almacenamiento y cómputo de la NPU/CPU del telefono. El reconocimiento en la nube permite delegar la carga computacional a servidores de gran potencia, haciendo posible ejecutar modelos más complejos en dispositivos con recursos limitados.

---

### 2. Dos situaciones en las que un usuario no podría usar la voz y cómo las resuelve la app
- **Situación 1 (Entorno con ruido extremo o discapacidad motora/vocal):**
  * *Contexto:* Un usuario en el metro, en una calle con tráfico pesado, en una fábrica o una persona con disartria, afonía o problemas del aparato fonador no puede articular órdenes que el micrófono entienda con claridad.
  * *Cómo lo he resuelto en mi app:* He implementado una **alternativa táctil accesible** con botones de alto contraste («Añadir», «Borrar», «Leer», «Ayuda») dotados de iconos estándar y `tooltips` informativos, permitiendo ejecutar exactamente las mismas operaciones con un simple toque.
- **Situación 2 (Entorno con necesidad de silencio o privacidad de datos):**
  * *Contexto:* Un usuario en una sala de lectura de una biblioteca, en una reunión laboral o en una consulta médica no puede dictar en voz alta ni desea que la app hable en alto anunciando sus notas.
  * *Cómo lo he resuelto en mi app:* He diseñado la pantalla para que muestre un feedback visual inmediato mediante un `SnackBar` informativo y una tarjeta con la transcripción y última orden ejecutada, permitiendo al usuario prescindir completamente del audio y controlar todo de forma silenciosa y discreta.
