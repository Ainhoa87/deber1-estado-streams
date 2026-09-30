import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/entities/estado_conexion.dart';
import '../../domain/repositories/conexion_repository.dart';

class ConexionPlusRepository implements ConexionRepository {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<EstadoConexion> consultarAhora() async {
    final resultados = await _connectivity.checkConnectivity();
    return _convertir(resultados);
  }

  @override
  Stream<EstadoConexion> observarCambios() {
    return _connectivity.onConnectivityChanged.map(_convertir);
  }

  EstadoConexion _convertir(List<ConnectivityResult> resultados) {
    if (resultados.contains(ConnectivityResult.wifi)) {
      return EstadoConexion.wifi;
    }
    if (resultados.contains(ConnectivityResult.mobile)) {
      return EstadoConexion.datosMoviles;
    }
    if (resultados.contains(ConnectivityResult.none)) {
      return EstadoConexion.sinConexion;
    }
    return EstadoConexion.otro;
  }
}
