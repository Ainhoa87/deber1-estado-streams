# Respuestas del Deber 1 - Manejo de Estado y Streams

## Parte A: La misma app, tres veces

### Pregunta 1: Comportamiento en la versión setState

**1. ¿Qué pasó en el paso 3 y por qué? Ojo: el valor sí se guardó en disco. ¿Qué es exactamente lo que quedó desactualizado? Y para que el contador viajara entre las dos pantallas, ¿cuántos lugares del código tuvieron que ponerse de acuerdo?**

* **¿Qué quedó desactualizado?** Al salir mediante el botón atrás del sistema o navegador, no se ejecutó un paso de retorno explícito con valor (`Navigator.pop(context, nuevoValor)`). Aunque la capa de data sí guardó el valor en disco (`SharedPreferences`), la pantalla `PantallaVisor` nunca recibió el nuevo dato en su `await` ni se llamó a `setState` para forzar la reconstrucción. Lo único desactualizado fue el **estado visible de la interfaz de usuario (UI)**.
* **Lugares que tuvieron que ponerse de acuerdo:** Tuvieron que ponerse de acuerdo **4 lugares** en la capa de presentación:
  1. El constructor de `PantallaControl` para recibir el valor actual.
  2. El `Navigator.push` en `PantallaVisor` esperando el resultado asíncrono con `await`.
  3. El botón "Volver" (`Navigator.pop(context, contador)`) devolviendo el valor modificado.
  4. El método `setState` en `PantallaVisor` para actualizar la variable local y refrescar la pantalla.

---

### Pregunta 2: Comportamiento en la versión Riverpod

**2. ¿Por qué ahora el botón atrás del sistema no rompe nada? ¿Dónde vive el contador?**

* **¿Por qué no se rompe?** Ahora la comunicación no depende del paso de argumentos en las rutas de navegación (`Navigator.pop/push`). La `PantallaVisor` escucha (`ref.watch`) reactivamente el estado provisto globalmente por Riverpod, reaccionando y redibujándose de forma automática en cuanto el estado cambia, sin importar cómo el usuario salga de la pantalla.
* **¿Dónde vive el contador?** El contador vive fuera del árbol de widgets, dentro del estado administrado por el **Notifier / Provider** en el contenedor global de Riverpod (`ProviderScope`). En las soluciones con Riverpod y Cubit, la información del contador se administra mediante un proveedor global (`ProviderScope` o `BlocProvider`).
* **Persistencia en memoria vs. disco:**
  * **En memoria:** Tanto Riverpod como Cubit mantienen el valor del contador reactivo alojado en la **memoria RAM** mientras la aplicación permanece en ejecución. Esto permite que los cambios de estado se notifiquen inmediatamente entre pantallas (`PantallaControl` y `PantallaVisor`).
  * **En disco:** Si la aplicación se cierra por completo o se reinicia el proceso, el estado almacenado en memoria RAM se destruye. Para conservar el valor de forma permanente entre sesiones, la capa de datos utiliza `ContadorPrefsRepository` (mediante `SharedPreferences`), guardando el valor en el **almacenamiento en disco** del dispositivo y restaurándolo al iniciar la aplicación.

---

### Pregunta 3: Comportamiento en la versión BLoC (Cubit)

**3. ¿Qué te permite ver el `BlocObserver` que las otras dos versiones no te daban? ¿En qué situación real sería útil ese registro?**

* **Lo que permite ver:** El `BlocObserver` permite rastrear de forma centralizada y en tiempo real la secuencia completa de cambios de estado (`ContadorCubit: 12 -> 13`) y transiciones globales de la aplicación. A diferencia de `setState` y Riverpod, no hace falta colocar impresiones manuales (`print`) dentro de los widgets o callbacks para saber cuándo y cómo cambia el estado.
* **Utilidad en situaciones reales:**
  1. **Trazabilidad y monitoreo de errores (Logging & Crashlytics):** En aplicaciones en producción, permite enviar la secuencia exacta de estados a servicios como Sentry o Crashlytics cuando ocurre un fallo, facilitando reproducir el error exacto que experimentó el usuario.
  2. **Auditoría de analíticas:** Permite registrar las acciones e interacciones clave de los usuarios de manera limpia y centralizada sin acoplar código de rastreo dentro de la lógica visual de las pantallas.

---

### Pregunta 4: Verificación de Arquitectura Limpia

**4. Pega la salida de los tres comandos en `RESPUESTAS.md`. ¿Qué demuestra que los dos primeros salgan vacíos y el tercero no? Si mañana tuvieras que cambiar Riverpod por otro paquete, ¿qué parte del proyecto tendrías que volver a escribir?**

* **Salida real de los comandos:**

```powershell
  PS C:\Users\Eigenaar\flutter_manejo_estado> git diff version/setstate version/riverpod -- lib/domain lib/data

  PS C:\Users\Eigenaar\flutter_manejo_estado> git diff version/setstate version/bloc -- lib/domain lib/data

  PS C:\Users\Eigenaar\flutter_manejo_estado> git diff version/setstate version/bloc --stat -- lib/presentation
  lib/presentation/estado/contador_cubit.dart          | 32 ++++++++++++++++
  lib/presentation/pantallas/pantalla_control.dart     | 47 +++++++++++++++++++++++
  lib/presentation/pantallas/pantalla_visor.dart       | 40 +++++++++++++++++++
  3 files changed, 119 insertions(+)
```

* **¿Qué demuestra que los dos primeros salgan vacíos y el tercero no?**
  * **Los dos primeros vacíos:** Demuestran el cumplimiento de **Clean Architecture** y la regla de dependencia hacia adentro. Las capas de dominio (`lib/domain`) y datos (`lib/data`) están 100% desacopladas de la interfaz visual y del gestor de estado. La lógica del negocio y la persistencia son agnósticas a la herramienta usada.
  * **El tercero con cambios:** Demuestra que el gestor de estado pertenece de forma exclusiva a la capa de **presentación** (`lib/presentation`). Es totalmente natural que exista diferencia entre ramas en esta capa, ya que cada una implementa una estrategia distinta de renderizado y manejo de UI (`setState`, Riverpod y BLoC).

* **Si mañana tuvieras que cambiar Riverpod por otro paquete, ¿qué parte del proyecto tendrías que volver a escribir?** Se tendría que volver a escribir **únicamente la capa de presentación** (`lib/presentation`) y el archivo `main.dart` (para la configuración del `ProviderScope` o contenedor inicial). Las capas de `domain` y `data` se mantendrían intactas sin necesidad de modificar ni una sola línea de código.

---

### A.6 · La comparación

|  | setState | Riverpod | Cubit |
| :--- | :--- | :--- | :--- |
| **¿Dónde vive el contador?** | En la variable local del `StatefulWidget` (`PantallaVisor`). | En el Notifier/NotifierProvider fuera del árbol de widgets. | En el `ContadorCubit` administrado por `BlocProvider`. |
| **¿Las pantallas se pasan datos?** | Sí, a través de argumentos en `Navigator.push` y retornos en `Navigator.pop`. | No, ambas pantallas leen y escuchan el provider independientemente. | No, ambas leen y reaccionan al estado compartido por el Cubit. |
| **Archivos de `presentation/` que tocaste** | `pantalla_visor.dart` y `pantalla_control.dart`. | `pantalla_visor.dart`, `pantalla_control.dart` y `contador_provider.dart` (o `main.dart`). | `pantalla_visor.dart`, `pantalla_control.dart`, `contador_cubit.dart` y `main.dart`. |
| **¿Qué pasa con el botón atrás?** | Si se usa el botón atrás del sistema/navegador, la pantalla anterior no se actualiza (queda desactualizada). | El estado se actualiza automáticamente en la pantalla anterior sin importar cómo se navegue. | El estado reacciona y se refleja automáticamente en la pantalla anterior. |
| **¿Tuviste que tocar `domain/`?** | No. | No. | No. |

**Nota sobre `main.dart`:** La fila de archivos considera `main.dart` como punto de entrada que instancia los proveedores globales. Este archivo solo requiere modificarse cuando cambia la forma de inyectar el estado en la raíz (por ejemplo, envolviendo la app en `ProviderScope` para Riverpod o `BlocProvider` para Cubit). Una vez configurado el contenedor principal, los cambios de lógica de presentación y flujo entre vistas se concentran en las subcarpetas `presentation/estado/` y `presentation/pantallas/`, por eso `main.dart` no aparece en la salida de `git diff --stat` de la Pregunta 4.

---

### Pregunta 5: Elección de gestor de estado según la complejidad

**5. Si la app tuviera una sola pantalla, ¿cuál de las tres elegirías y por qué? ¿Y si tuviera ocho pantallas que comparten cinco datos distintos? `setState` no es "malo": cierra tu respuesta diciendo en dos líneas cuándo sí es la opción correcta.**

* **Para una sola pantalla:** Elegiría **`setState`**. Al no haber necesidad de compartir información entre rutas ni coordinar estados globales, `setState` es la solución más sencilla, rápida y sin boilerplate innecesario ni librerías adicionales.
* **Para ocho pantallas con cinco datos compartidos:** Elegiría **Riverpod**. Para un proyecto mediano compuesto por 8 pantallas interconectadas, ofrece un balance ideal entre simplicidad y escalabilidad sin la sobrecarga sintáctica de paquetes como Bloc/Cubit. Permite declarar proveedores globales de forma segura sin depender del `BuildContext`, simplificando la inyección de dependencias entre pantallas y facilitando la escritura de pruebas unitarias.
* **Cuándo `setState` sí es la opción correcta:**

  > `setState` es apto únicamente para administrar estados efímeros y locales de un solo widget. Al escalar a múltiples pantallas, acopla la UI con la lógica y obliga a pasar datos manualmente entre constructores, volviendo el código frágil y difícil de mantener.

---

## Parte B: Monitoreo de Conectividad mediante Connectivity Plus (`Future` vs `Stream`)

### Pregunta 6: Análisis del Comportamiento con Future

**6. ¿Por qué la pantalla siguió mostrando "Wi-Fi" si el Wi-Fi ya estaba apagado? ¿La app tenía un dato incorrecto, o tenía un dato correcto de un momento equivocado?**

La pantalla siguió mostrando "Wi-Fi" porque un `Future` solo entrega **una respuesta puntual en el tiempo** y se cierra. No mantiene una conexión activa ni escucha eventos posteriores en el sistema operativo.

* **Naturaleza del dato recibido:** La app **no tenía un dato incorrecto**, sino **un dato completamente correcto de un momento equivocado**. En el instante en que se presionó el botón "Consultar ahora", el dispositivo efectivamente contaba con conexión Wi-Fi. La aplicación tomó una "foto" del estado de la red en ese milisegundo exacto y la renderizó en la interfaz.
* **Los límites de un `Future`:**
  * **Operación de disparo único (one-shot):** Un `Future` no está diseñado para monitorear eventos continuos o dinámicos. Una vez que resuelve su valor (`completed`), su ciclo de vida finaliza.
  * **Casos de uso adecuados:** Es ideal para peticiones HTTP tipo REST (`GET`, `POST`), consultas puntuales a bases de datos o lecturas rápidas en disco (`SharedPreferences`), donde se solicita un dato, se recibe y la tarea concluye.
  * **Inadecuado para eventos en tiempo real:** Cuando el estado externo cambia de forma autónoma (como la conectividad, señales GPS o mensajes de WebSockets), un `Future` queda obsoleto rápidamente si no se invoca manualmente mediante un evento explícito (como pulsar un botón de recarga).

Para reaccionar automáticamente a los cambios de conectividad sin intervención del usuario, se requiere un flujo continuo de datos (`Stream`).

---

### Pregunta 7: Cancelación de suscripciones en Cubit

**7. ¿Qué pasaría si borras el `cancel()` del `close()` del Cubit y el usuario entra y sale de esa pantalla cincuenta veces?**

En `ConexionCubit`, la suscripción al `Stream` se gestiona explícitamente:

```dart
@override
Future<void> close() {
  _subscription?.cancel();
  return super.close();
}
```

**¿Qué pasa si no se cancela?** La suscripción permanecería abierta escuchando cambios de red incluso después de que la pantalla/Cubit sea destruido. Si el usuario navega varias veces por la app, se acumularán múltiples oyentes en memoria, generando **fugas de memoria (memory leaks)**, consumo innecesario de batería y errores de ejecución al intentar actualizar widgets desmontados.

---

### Pregunta 8: Analogía de foto vs. película

**8. Con lo que viste: ¿por qué decimos que un `Future` es una foto y un `Stream` una película? Explícalo con la conexión, no con la definición del libro. Cierra nombrando dos datos de una app real que pedirías con `Future` y dos que observarías con `Stream`.**

Decimos que un `Future` **es una foto** porque captura el estado de la conexión en un único instante fijo. Cuando pulsamos el botón en la primera pantalla, obtuvimos una "captura" que decía `Wi-Fi`. Si luego apagábamos el Wi-Fi, la foto seguía mostrando `Wi-Fi` congelado en el tiempo hasta que volvíamos a presionar el botón.

Por otro lado, un `Stream` **es una película** porque transmite una secuencia continua de fotogramas en tiempo real. En la segunda pantalla, al apagar y encender el Wi-Fi, no tuvimos que tocar nada: la pantalla transmitió el flujo de cambios en vivo, pasando automáticamente de `Wi-Fi` a `Sin conexión` y viceversa.

* **Dos datos con `Future` (peticiones puntuales únicas):**
  1. Obtener los términos y condiciones de la aplicación al abrir un menú.
  2. Cargar la información del perfil del usuario (nombre, correo) al iniciar sesión.
* **Dos datos con `Stream` (flujos continuos en tiempo real):**
  1. La ubicación GPS del usuario en una app de mapas o entregas mientras se desplaza.
  2. Los mensajes entrantes en una sala de chat o la bandeja de notificaciones en vivo.