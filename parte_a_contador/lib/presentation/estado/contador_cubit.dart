import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/decrementar.dart';
import '../../domain/usecases/incrementar.dart';
import '../../domain/usecases/obtener_contador.dart';

class ContadorCubit extends Cubit<int> {
  ContadorCubit({
    required ObtenerContador obtenerContador,
    required Incrementar incrementar,
    required Decrementar decrementar,
  }) : _obtenerContador = obtenerContador,
       _incrementar = incrementar,
       _decrementar = decrementar,
       super(0);

  final ObtenerContador _obtenerContador;
  final Incrementar _incrementar;
  final Decrementar _decrementar;

  Future<void> cargar() async {
    emit(await _obtenerContador());
  }

  Future<void> incrementar() async {
    emit(await _incrementar());
  }

  Future<void> decrementar() async {
    emit(await _decrementar());
  }
}