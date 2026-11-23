# 📱 Actividad 2 · Agitar para Deshacer (`notas_gestos`)
**Alumno:** Ayoub Atidi Belbaz  
**Módulo:** Desarrollo de Interfaces (2º DAM)  
**Unidad / Criterios:** UT2 · RA2.b, RA2.d  

---

## 🎯 Descripción del Proyecto
En esta actividad he desarrollado una aplicación de notas en Flutter que detecta gestos físicos de movimiento mediante los sensores del smartphone (acelerómetro inercial). La app permite deshacer el borrado de una nota agitando el móvil (*Shake to Undo*), implementando de forma estricta los requisitos de accesibilidad del criterio **WCAG 2.2 · 2.5.4 (Activación mediante movimiento)**.

---

## 🛠️ Tecnologías y Sensores
- **Flutter 3.x & Dart 3.x**
- **`sensors_plus` (v7.1.1):** Acceso a los flujos inerciales del hardware móvil:
  - `userAccelerometerEventStream`: Para detectar la sacudida libre de gravedad.
  - `accelerometerEventStream`: Para detectar la inclinación lateral en el eje X (Ampliación).
- **Control de estados y ciclo de vida:** Cancelación rigurosa de flujos en `dispose()` y al apagar el interruptor para optimizar la batería y memoria.

---

## 🧠 Arquitectura en Dart Puro (`lib/`)
He separado la matemática de los sensores en clases de Dart puro, facilitando pruebas unitarias deterministas sin mocks complejos:
1. **`DetectorAgitado` (`lib/detector_agitado.dart`):**
   - Umbral por defecto: $15.0\text{ m/s}^2$.
   - Ventana de pausa (anti-rebote): $1\text{ segundo}$.
   - Cálculo del módulo de aceleración euclídeo: $\sqrt{x^2 + y^2 + z^2}$.
   - Parámetro `DateTime instante` inyectado para pruebas temporales instantáneas sin esperas reales.
2. **`DetectorInclinacion` (`lib/detector_inclinacion.dart`) [Ampliación]:**
   - Umbral de inclinación en el eje X: $5.0\text{ m/s}^2$ ($\approx 30^\circ$ de inclinación).
   - Pausa de seguridad: $1.2\text{ segundos}$ para transiciones suaves de pestaña.

---

## 🧪 Pruebas Unitarias y de Widget (`test/`)
Batería de tests automatizados que cubren el 100% de la lógica inercial y de UI:
1. **`test/detector_agitado_test.dart`:**
   - Test 1: Reposo / aceleración baja devuelve `false`.
   - Test 2: Sacudida que supera el umbral devuelve `true`.
   - Test 3: Segunda sacudida dentro del segundo de pausa es ignorada (`false`).
   - Test 4: Sacudida transcurrido el tiempo de pausa vuelve a disparar (`true`).
2. **`test/detector_inclinacion_test.dart`:**
   - Test 1: Posición vertical sin inclinación no altera la pestaña.
   - Test 2: Inclinación a la derecha (eje X negativo) avanza a Papelera.
   - Test 3: Inclinación a la izquierda (eje X positivo) regresa a Notas.
   - Test 4: Inclinaciones consecutivas dentro de la pausa son filtradas.
3. **`test/widget_test.dart`:**
   - Renderizado completo, verificación de notas, SwitchListTile, campo de texto y navegación entre pestañas.

---

## 🌟 Ampliación Implementada
- **Navegación por Inclinación Lateral (`NavigationBar`):**
  - Dos pestañas: **Notas** y **Papelera**.
  - Al inclinar físicamente el dispositivo hacia la izquierda o hacia la derecha, el `DetectorInclinacion` conmuta automáticamente entre la lista de notas activas y la papelera de reciclaje, permitiendo además vaciar la papelera o recuperar notas archivadas.

---

## 📝 Reflexión Técnica y Respuestas Académicas (Paso 5)

### 1. Comparativa de umbrales (10, 15 y 25 m/s²) caminando con el móvil en la mano: ¿Cuál elijo y por qué?
- **Umbral de 10 m/s²:** Es excesivamente sensible. Al caminar con el móvil en la mano o en el bolsillo, las oscilaciones naturales del paso y el braceo alcanzan picos de entre 8 y 12 m/s². Con 10 m/s², la aplicación produce continuos **falsos positivos**, restaurando notas sin que el usuario lo haya deseado.
- **Umbral de 25 m/s²:** Es excesivamente duro. Exige un movimiento brusco, violento y forzado del brazo. Esto causa incomodidad física, fatiga y un peligro real de que el smartphone se resbale de las manos y sufra una caída, además de ser inaccesible para personas con menor fuerza o temblores.
- **Umbral seleccionado: 15 m/s²:** **Es el valor óptimo.** Filtra con solvencia la aceleración parásita de la marcha humana ordinaria, pero se activa de manera limpia y natural mediante un movimiento seco y consciente de la muñeca.

---

### 2. ¿Por qué se usa `userAccelerometerEventStream` y no `accelerometerEventStream`? ¿Qué pasaría con el móvil en reposo?
- **`accelerometerEventStream` (Acelerómetro Total):** Mide la aceleración total que incide sobre el transductor piezoeléctrico del sensor, incluyendo en todo momento el vector de la **aceleración gravitatoria terrestre** ($g \approx 9.8\text{ m/s}^2$). Si dejáramos el móvil completamente quieto y en reposo sobre una mesa, este sensor reportaría un módulo constante de aproximadamente $9.8\text{ m/s}^2$. Si el usuario inclinara o girara el móvil lentamente, la componente de la gravedad podría superar fácilmente un umbral bajo sin que exista una sacudida real.
- **`userAccelerometerEventStream` (Acelerómetro de Usuario):** El sistema operativo aplica filtros de paso alto y algoritmos de fusión sensorial para sustraer el vector de la gravedad constante. En reposo absoluto, este stream devuelve valores prácticamente iguales a **$0.0\text{ m/s}^2$** en los tres ejes $(x=0, y=0, z=0)$. Por tanto, mide exclusivamente la fuerza y aceleración lineal neta imprimida de forma voluntaria por el usuario.

---

### 3. Explicación de las dos condiciones de la pauta WCAG 2.2 · 2.5.4 cumplidas por la app
El criterio de conformidad **WCAG 2.5.4 (Activación mediante movimiento)** exige que cualquier funcionalidad controlable mediante sensores de movimiento del dispositivo cumpla dos condiciones imperativas:
1. **Alternativa accesible equivalente (Criterio 2.5.4.a):**
   - La funcionalidad no puede ser exclusiva del movimiento físico. En nuestra aplicación, cuando una nota es eliminada, se presenta de forma inmediata un botón táctil convencional **«Deshacer»** en el `SnackBar`. Además, las notas borradas quedan accesibles en la pestaña táctil de Papelera, garantizando que un usuario con el móvil anclado a un soporte, en silla de ruedas o con movilidad reducida pueda recuperar la nota exactamente igual.
2. **Capacidad de desactivación (Criterio 2.5.4.b):**
   - El usuario debe poder inhabilitar la respuesta al movimiento para prevenir activaciones accidentales causadas por temblores involuntarios (ej. Parkinson) o vibraciones del entorno (transporte público). Nuestra app incorpora en la cabecera un control explícito `SwitchListTile` («Agitar para deshacer») que apaga de inmediato la escucha del sensor cuando el usuario lo desea.
