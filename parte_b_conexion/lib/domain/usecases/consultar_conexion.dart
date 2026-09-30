import '../entities/estado_conexion.dart';
import '../repositories/conexion_repository.dart';

class ConsultarConexion {
  ConsultarConexion(this._repository);

  final ConexionRepository _repository;

  Future<EstadoConexion> call() => _repository.consultarAhora();
}
