import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/pantallas/pantalla_visor.dart';

void main() {
  runApp(
    const ProviderScope(
      child: _AplicacionContador(),
    ),
  );
}

class _AplicacionContador extends StatelessWidget {
  const _AplicacionContador();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contador',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const PantallaVisor(),
    );
  }
}
