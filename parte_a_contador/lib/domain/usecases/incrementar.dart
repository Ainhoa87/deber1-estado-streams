import '../repositories/contador_repository.dart';

class Incrementar {
  Incrementar(this._repository);

  final ContadorRepository _repository;

  Future<int> call() async {
    final valor = await _repository.leer() + 1;
    await _repository.guardar(valor);
    return valor;
  }
}