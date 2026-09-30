import '../repositories/contador_repository.dart';

class ObtenerContador {
  ObtenerContador(this._repository);

  final ContadorRepository _repository;

  Future<int> call() => _repository.leer();
}