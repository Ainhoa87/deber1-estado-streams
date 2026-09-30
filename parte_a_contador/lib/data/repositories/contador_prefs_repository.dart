import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/contador_repository.dart';

class ContadorPrefsRepository implements ContadorRepository {
  static const _clave = 'contador';

  @override
  Future<int> leer() async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getInt(_clave) ?? 0;
  }

  @override
  Future<void> guardar(int valor) async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setInt(_clave, valor);
  }
}