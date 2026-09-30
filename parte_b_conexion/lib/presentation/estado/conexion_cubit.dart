import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/estado_conexion.dart';
import '../../domain/usecases/consultar_conexion.dart';
import '../../domain/usecases/observar_conexion.dart';

class ConexionCubit extends Cubit<EstadoConexion> {
  ConexionCubit(this._consultarConexion, this._observarConexion)
    : super(EstadoConexion.otro);

  final ConsultarConexion _consultarConexion;
  final ObservarConexion _observarConexion;
  StreamSubscription<EstadoConexion>? _suscripcion;

  Future<void> iniciar() async {
    final estadoInicial = await _consultarConexion();
    if (isClosed) return;

    emit(estadoInicial);
    _suscripcion = _observarConexion().listen((estado) {
      if (!isClosed) emit(estado);
    });
  }

  @override
  Future<void> close() async {
    await _suscripcion?.cancel();
    await super.close();
  }
}
