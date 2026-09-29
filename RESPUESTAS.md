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
* **¿Por qué no se rompe?** Ahora la comunicación no depende del paso de argumentos en las rutas de navegación (`Navigator.pop/push`). La `PantallaVisor` escucha (`ref.watch`) reactivamente el estado provisto globalmente por Riverpod, reaccionando y redibujándose de forma automática en cuanto el estado cambia, sin importar cómo el usuario salga de la pantalla[cite: 11].
* **¿Dónde vive el contador?** El contador vive fuera del árbol de widgets, dentro del estado administrado por el **Notifier / Provider** en el contenedor global de Riverpod (`ProviderScope`)[cite: 7].

---

### Pregunta 3: Comportamiento en la versión BLoC (Cubit)

**3. ¿Qué te permite ver el BlocObserver que las otras dos versiones no te daban? ¿En qué situación real sería útil ese registro?**
* **¿Qué permite ver?** Permite observar de manera centralizada el historial completo de cambios de estado y transiciones (`currentState` -> `nextState`) en tiempo real directamente desde la consola, sin necesidad de agregar fragmentos de `print` manuales en cada widget o método.
* **Caso de uso real:** Es útil para auditorías de errores, monitoreo y generación de *logs* de diagnóstico en producción (integración con Sentry o Crashlytics), lo que facilita rastrear la secuencia exacta de acciones previas a una falla.