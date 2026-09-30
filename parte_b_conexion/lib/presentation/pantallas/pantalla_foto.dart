import 'package:flutter/material.dart';

import '../../domain/entities/estado_conexion.dart';
import '../../domain/usecases/consultar_conexion.dart';

class PantallaFoto extends StatefulWidget {
  const PantallaFoto({super.key, required this.consultarConexion});

  final ConsultarConexion consultarConexion;

  @override
  State<PantallaFoto> createState() => _PantallaFotoState();
}

class _PantallaFotoState extends State<PantallaFoto> {
  EstadoConexion? _estado;
  DateTime? _horaConsulta;
  bool _consultando = false;
  bool _error = false;

  Future<void> _consultarAhora() async {
    final horaConsulta = DateTime.now();
    setState(() {
      _consultando = true;
      _error = false;
    });

    try {
      final estado = await widget.consultarConexion();
      if (!mounted) return;

      setState(() {
        _estado = estado;
        _horaConsulta = horaConsulta;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _horaConsulta = horaConsulta;
        _error = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _consultando = false;
        });
      }
    }
  }

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

  String _formatearHora(DateTime hora) {
    final horas = hora.hour.toString().padLeft(2, '0');
    final minutos = hora.minute.toString().padLeft(2, '0');
    final segundos = hora.second.toString().padLeft(2, '0');
    return '$horas:$minutos:$segundos';
  }

  @override
  Widget build(BuildContext context) {
    final estado = _estado;
    final color = _error || estado == EstadoConexion.sinConexion
        ? Colors.red
        : Colors.green;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_consultando)
            const CircularProgressIndicator()
          else if (_error)
            Icon(Icons.error_outline, size: 72, color: color)
          else if (estado != null) ...[
            Icon(_iconoEstado(estado), size: 72, color: color),
            const SizedBox(height: 12),
            Text(
              _textoEstado(estado),
              style: Theme.of(context).textTheme.displayMedium
                  ?.copyWith(color: color),
            ),
          ],
          if (_error) ...[
            const SizedBox(height: 12),
            Text(
              'No se pudo consultar',
              style: Theme.of(context).textTheme.displaySmall
                  ?.copyWith(color: color),
            ),
          ],
          if (_horaConsulta case final hora?) ...[
            const SizedBox(height: 12),
            Text('Consulta: ${_formatearHora(hora)}'),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _consultando ? null : _consultarAhora,
            child: Text(_consultando ? 'Consultando...' : 'Consultar ahora'),
          ),
        ],
      ),
    );
  }
}
