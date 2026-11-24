# 📱 Actividad 2 · Agitar para Deshacer (`notas_gestos`)
**Módulo:** 0488 Desarrollo de Interfaces · 2º DAM · Curso 2026/2027  
**Unidad y RA:** UT2 Generación de interfaces naturales · RA2: Genera interfaces naturales de usuario utilizando herramientas visuales.  
- **RA2.b:** He creado una interfaz natural de usuario utilizando las herramientas disponibles.  
- **RA2.d:** He incorporado la detección del movimiento del cuerpo para implementar acciones en interfaces naturales.  
**Alumno:** Ayoub Atidi Belbaz  

---

## 🎯 ¿Qué he desarrollado en esta actividad?
En esta actividad he desarrollado una aplicación de gestión de notas en Flutter que detecta sacudidas físicas del teléfono (*Shake to Undo*) para restaurar la última nota eliminada en su posición exacta original. He diseñado el gesto como una funcionalidad opcional y siempre respaldada por una alternativa táctil directa, cumpliendo escrupulosamente con el criterio **WCAG 2.2 · 2.5.4 (Activación mediante movimiento)**.

---

## 📸 Captura de Funcionamiento en el Emulador / Móvil
![Captura de Funcionamiento de Notas con Gestos](captura_notas_gestos.png)

---

## 🛠️ Tecnologías y Sensores Utilizados
- **Flutter 3.x & Dart 3.x**
- **`sensors_plus: ^7.1.1`:** Acceso a los flujos inerciales del hardware del dispositivo:
  - `userAccelerometerEventStream`: Para medir la aceleración lineal neta del usuario sin gravedad.
  - `accelerometerEventStream`: Para medir la inclinación lateral en el eje X (Ampliación).
- **Gestión rigurosa del ciclo de vida:** Cancelación sistemática de las suscripciones en `dispose()` y al apagar el interruptor de gestos para proteger la batería del terminal.

---

## 🧠 Mi Implementación Paso a Paso

### Paso 1. Proyecto y configuración de sensores
1. He creado el proyecto `notas_gestos` y añadido la dependencia `sensors_plus`.
2. En Android no he necesitado declarar permisos adicionales en el `AndroidManifest.xml` al utilizar frecuencias de muestreo inercial convencionales.

### Paso 2. Detectar la sacudida en Dart puro (`lib/detector_agitado.dart`)
He desacoplado la matemática del acelerómetro en una clase pura e independiente:
- **Clase `DetectorAgitado`:**
  - Constructor con umbral configurable por defecto a $15.0\text{ m/s}^2$ y ventana de pausa anti-rebote de $1\text{ segundo}$.
  - Método `bool procesar(double x, double y, double z, DateTime instante)`:
    - Calcula el módulo euclídeo de la aceleración: $\sqrt{x^2 + y^2 + z^2}$.
    - Si el módulo es mayor o igual que el umbral y ha transcurrido la pausa, confirma la sacudida y devuelve `true`.
    - Tras una sacudida detectada, ignora todas las lecturas durante la pausa para que un único movimiento físico no compute dos veces.
  - **Inyección de `instante`:** Recibe la fecha y hora por parámetro en lugar de llamar a `DateTime.now()` dentro, permitiéndome probar toda la lógica temporal en pruebas unitarias instantáneas sin retrasos artificiales.

### Paso 3. Interfaz y flujo de restauración
1. He creado una lista de notas con un campo de texto superior para redactar nuevas entradas.
2. Cada nota se elimina mediante deslizamiento horizontal accesible (`Dismissible`) o mediante un botón `IconButton` con tooltip.
3. Al borrar, guardo la nota eliminada y su índice de inserción original, mostrando un `SnackBar` informativo («Nota borrada») con la acción táctil «Deshacer».
4. Me suscribo a `userAccelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)` y paso cada lectura al detector. Si devuelve `true` y hay una nota en el búfer, la restauro en su posición exacta y muestro el mensaje *«Nota recuperada al agitar»*.
5. Si no hay notas pendientes de deshacer, la sacudida no realiza ninguna acción.

### Paso 4. Buenas prácticas y accesibilidad (WCAG 2.5.4)
1. **Desactivable:** He añadido un `SwitchListTile` («Agitar para deshacer») en la parte superior. Si el usuario lo desactiva, la app detiene por completo la escucha del sensor.
2. **Feedback visible:** He colocado un icono dinámico en la `AppBar` que informa si el gesto está activo o inactivo mediante un `tooltip` explicativo.
3. **Dispositivos sin acelerómetro:** Si el flujo inercial emite error (escritorio o emulador sin sensores virtuales), desactivo el interruptor y muestro el aviso *«Este dispositivo no tiene acelerómetro disponible»*.
4. **Liberación de recursos:** Cancelo de forma estricta las suscripciones a los flujos de sensores en el método `dispose()` y al apagar el interruptor.

### Paso 5. Ampliación implementada
- He incorporado una `NavigationBar` inferior con dos pestañas (**Notas** y **Papelera**).
- He creado la clase `DetectorInclinacion` (`lib/detector_inclinacion.dart`) con sus pruebas unitarias, permitiendo cambiar dinámicamente de pestaña al inclinar el móvil hacia la izquierda o hacia la derecha utilizando `accelerometerEventStream` y analizando el eje X.

---

## 🧪 Pruebas Automatizadas (100% Pasadas)
He implementado una batería completa de pruebas automatizadas:

```bash
cd notas_gestos
flutter test
```

1. **`test/detector_agitado_test.dart`:**
   - Test 1 (Reposo): Las lecturas bajas no superan el umbral y devuelven `false`.
   - Test 2 (Sacudida): Aceleración que supera los 15 m/s² devuelve `true`.
   - Test 3 (Segunda sacudida en pausa): Es ignorada para evitar rebotes múltiples (`false`).
   - Test 4 (Sacudida tras la pausa): Transcurrido el segundo de enfriamiento, vuelve a devolver `true`.
2. **`test/detector_inclinacion_test.dart`:**
   - 4 pruebas unitarias que verifican reposo vertical, inclinación a la derecha, inclinación a la izquierda y enfriamiento.
3. **`test/widget_test.dart`:**
   - Comprobación de renderizado completo, notas iniciales, SwitchListTile, campo de texto y navegación entre pestañas.

---

## 📝 Mis Reflexiones Técnicas (Paso 5)

### 1. Comparativa de umbrales (10, 15 y 25 m/s²) caminando con el móvil en la mano: ¿Cuál elijo y por qué?
He probado experimentalmente los tres valores caminando con el smartphone en la mano:
* **Umbral de 10 m/s²:** Es excesivamente sensible. Al caminar con el móvil en la mano o en el bolsillo, las oscilaciones naturales del paso y del braceo generan aceleraciones parásitas de entre 8 y 12 m/s², disparando **falsos positivos continuos** y restaurando notas de forma involuntaria.
* **Umbral de 25 m/s²:** Es excesivamente duro. Exige un movimiento brusco, violento y antinatural del brazo, lo que genera incomodidad, cansancio articular, riesgo de que el smartphone se resbale y sufra una caída, además de ser inaccesible para personas con menor fuerza o temblores.
* **Mi elección (15 m/s²):** **Es el valor óptimo.** Filtra con solvencia el ruido de la deambulación cotidiana y, al mismo tiempo, responde con precisión ante un movimiento voluntario, ágil y controlado de la muñeca.

### 2. ¿Por qué he usado `userAccelerometerEventStream` y no `accelerometerEventStream`? ¿Qué pasaría en reposo?
* **`accelerometerEventStream` (Acelerómetro Total):** Mide la aceleración física bruta sobre el hardware, incluyendo permanentemente la **aceleración de la gravedad terrestre** ($g \approx 9.8\text{ m/s}^2$). Si el móvil estuviera en reposo sobre una mesa, marcaría constantemente $9.8\text{ m/s}^2$ en el eje Z. Con una simple rotación o inclinación lenta, la componente de la gravedad se redistribuiría entre los ejes y superaría un umbral bajo sin que exista una sacudida real.
* **`userAccelerometerEventStream` (Acelerómetro de Usuario):** El sistema operativo sustrae el vector constante de la gravedad mediante filtros sensoriales de paso alto. Con el móvil en reposo absoluto, los tres ejes reportan prácticamente **$0.0\text{ m/s}^2$** $(x=0, y=0, z=0)$, midiendo exclusivamente la fuerza de aceleración lineal aplicada voluntariamente por el usuario.

### 3. Explicación de las dos condiciones de WCAG 2.2 · 2.5.4 cumplidas en mi app
1. **Alternativa táctil accesible equivalente (2.5.4.a):** La activación mediante movimiento nunca es exclusiva. Cada vez que se elimina una nota, mi app muestra de inmediato un botón táctil convencional **«Deshacer»** en el `SnackBar`, además de permitir acceder a la pestaña táctil de Papelera para recuperarla.
2. **Capacidad de desactivación (2.5.4.b):** Se proporciona un control accesible para apagar el sensor. En la cabecera se dispone de un interruptor `SwitchListTile` («Agitar para deshacer») que apaga de inmediato la escucha del sensor inercial para prevenir activaciones accidentales causadas por temblores involuntarios (ej. Parkinson) o vibraciones del transporte público.
