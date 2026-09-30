import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/estado_conexion.dart';
import '../../domain/usecases/consultar_conexion.dart';
import '../../domain/usecases/observar_conexion.dart';
import '../estado/conexion_cubit.dart';

class PantallaStream extends StatelessWidget {
  const PantallaStream({
    super.key,
    required this.consultarConexion,
    required this.observarConexion,
  });

  final ConsultarConexion consultarConexion;
  final ObservarConexion observarConexion;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConexionCubit>(
      create: (_) =>
          ConexionCubit(consultarConexion, observarConexion)..iniciar(),
      child: const _PantallaStreamContenido(),
    );
  }
}

class _PantallaStreamContenido extends StatefulWidget {
  const _PantallaStreamContenido();

  @override
  State<_PantallaStreamContenido> createState() =>
      _PantallaStreamContenidoState();
}

class _PantallaStreamContenidoState extends State<_PantallaStreamContenido> {
  int _cambiosRecibidos = 0;

  String _textoEstado(EstadoConexion estado) {
    return switch (estado) {
      EstadoConexion.wifi => 'Wi-Fi',
      EstadoConexion.datosMoviles => 'Datos moviles',
      EstadoConexion.otro => 'Otra conexión',
      EstadoConexion.sinConexion => 'Sin conexion',
    };
  }

  IconData _iconoEstado(EstadoConexion estado) {
    return switch (estado) {
      EstadoConexion.wifi => Icons.wifi,
      EstadoConexion.datosMoviles => Icons.signal_cellular_alt,
      EstadoConexion.otro => Icons.public,
      EstadoConexion.sinConexion => Icons.wifi_off,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConexionCubit, EstadoConexion>(
      listener: (context, estado) {
        setState(() {
          _cambiosRecibidos++;
        });
      },
      child: BlocBuilder<ConexionCubit, EstadoConexion>(
        builder: (context, estado) {
          final color = estado == EstadoConexion.sinConexion
              ? Colors.red
              : Colors.green;

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_iconoEstado(estado), size: 72, color: color),
                const SizedBox(height: 12),
                Text(
                  _textoEstado(estado),
                  style: Theme.of(context).textTheme.displayMedium
                      ?.copyWith(color: color),
                ),
                const SizedBox(height: 16),
                Text('Cambios recibidos: $_cambiosRecibidos'),
              ],
            ),
          );
        },
      ),
    );
  }
}
