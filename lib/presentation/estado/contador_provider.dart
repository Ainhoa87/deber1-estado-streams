import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/contador_prefs_repository.dart';
import '../../domain/repositories/contador_repository.dart';
import '../../domain/usecases/decrementar.dart';
import '../../domain/usecases/incrementar.dart';
import '../../domain/usecases/obtener_contador.dart';

final contadorRepositoryProvider = Provider<ContadorRepository>(
  (ref) => ContadorPrefsRepository(),
);

final obtenerContadorProvider = Provider<ObtenerContador>(
  (ref) => ObtenerContador(ref.watch(contadorRepositoryProvider)),
);

final incrementarProvider = Provider<Incrementar>(
  (ref) => Incrementar(ref.watch(contadorRepositoryProvider)),
);

final decrementarProvider = Provider<Decrementar>(
  (ref) => Decrementar(ref.watch(contadorRepositoryProvider)),
);

final contadorProvider = NotifierProvider<ContadorNotifier, int>(
  ContadorNotifier.new,
);

class ContadorNotifier extends Notifier<int> {
  @override
  int build() => 0;

  Future<void> cargar() async {
    state = await ref.read(obtenerContadorProvider)();
  }

  Future<void> incrementar() async {
    state = await ref.read(incrementarProvider)();
  }

  Future<void> decrementar() async {
    state = await ref.read(decrementarProvider)();
  }
}
