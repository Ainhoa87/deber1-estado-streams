import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repositories/contador_prefs_repository.dart';
import 'domain/usecases/decrementar.dart';
import 'domain/usecases/incrementar.dart';
import 'domain/usecases/obtener_contador.dart';
import 'presentation/estado/contador_cubit.dart';
import 'presentation/pantallas/pantalla_visor.dart';

void main() {
  Bloc.observer = _ContadorBlocObserver();
  runApp(const _AplicacionContador());
}

class _AplicacionContador extends StatelessWidget {
  const _AplicacionContador();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContadorCubit>(
      create: (_) {
        final repositorio = ContadorPrefsRepository();
        return ContadorCubit(
          obtenerContador: ObtenerContador(repositorio),
          incrementar: Incrementar(repositorio),
          decrementar: Decrementar(repositorio),
        )..cargar();
      },
      child: MaterialApp(
        title: 'Contador',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const PantallaVisor(),
      ),
    );
  }
}

class _ContadorBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    if (bloc is ContadorCubit) {
      debugPrint(
        'ContadorCubit: ${change.currentState} -> ${change.nextState}',
      );
    }
    super.onChange(bloc, change);
  }
}
