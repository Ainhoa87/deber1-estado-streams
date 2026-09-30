// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:parte_b_conexion/domain/entities/estado_conexion.dart';
import 'package:parte_b_conexion/domain/repositories/conexion_repository.dart';
import 'package:parte_b_conexion/domain/usecases/consultar_conexion.dart';
import 'package:parte_b_conexion/domain/usecases/observar_conexion.dart';
import 'package:parte_b_conexion/main.dart';

void main() {
  testWidgets('muestra las pestañas Future y Stream', (tester) async {
    final repository = _FakeConexionRepository();

    await tester.pumpWidget(
      MyApp(
        consultarConexion: ConsultarConexion(repository),
        observarConexion: ObservarConexion(repository),
      ),
    );

    expect(find.text('Con Future'), findsOneWidget);
    expect(find.text('Con Stream'), findsOneWidget);
    expect(find.text('Consultar ahora'), findsOneWidget);

    await tester.tap(find.text('Con Stream'));
    await tester.pumpAndSettle();

    expect(find.text('Cambios recibidos: 1'), findsOneWidget);
  });
}

class _FakeConexionRepository implements ConexionRepository {
  @override
  Future<EstadoConexion> consultarAhora() async => EstadoConexion.wifi;

  @override
  Stream<EstadoConexion> observarCambios() => const Stream.empty();
}
