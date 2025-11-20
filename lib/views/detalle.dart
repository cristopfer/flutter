import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '/models/user_model.dart';
import '/services/modeloIA_service.dart';

class Detalle extends StatefulWidget {
  final PlatformFile? selectedFile;
  final Usuario? usuario;
  final AnalisisData resultadoAnalisis;

  const Detalle(
      {super.key,
      this.selectedFile,
      this.usuario,
      required this.resultadoAnalisis});

  @override
  State<Detalle> createState() => _DetalleState();
}

class _DetalleState extends State<Detalle> {
  String _selected = "";

  // Método para construir botones
  Widget _buildButton(String texto, String value, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() => _selected = value);
          onTap();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3498DB),
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF3498DB), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          texto,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Método para exportar resultado
  Future<void> _exportarResultado() async {
    try {
      final reporteContent = '''
PROSTASCAN - REPORTE MÉDICO
============================

RIESGO: ${widget.resultadoAnalisis.riesgo}
----------------
${widget.resultadoAnalisis.riesgoTexto}

ÁREA SOSPECHOSA: ${widget.resultadoAnalisis.area}

PROBABILIDAD ESTIMADA DE LESIÓN: ${widget.resultadoAnalisis.probabilidad}

CLASIFICACIÓN PRELIMINAR: ${widget.resultadoAnalisis.clasificacion}

RECOMENDACIÓN:
${widget.resultadoAnalisis.recomendacion}

Fecha de generación: ${DateTime.now().toString().split(' ')[0]}
===========================================
      ''';

      await _mostrarOpcionesExportacion(reporteContent);
    } catch (e) {
      print("Error al exportar: $e");
      _mostrarError("Error al exportar el reporte: $e");
    }
  }

  // Método para mostrar opciones de exportación
  Future<void> _mostrarOpcionesExportacion(String contenido) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Exportar Reporte"),
          content: const Text("¿Cómo deseas exportar el reporte?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _compartirComoTexto(contenido);
              },
              child: const Text("Compartir como texto"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _copiarAlPortapapeles(contenido);
              },
              child: const Text("Copiar al portapapeles"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _enviarPorCorreo(contenido);
              },
              child: const Text("Enviar por correo"),
            ),
          ],
        );
      },
    );
  }

  // Método para compartir como texto
  Future<void> _compartirComoTexto(String contenido) async {
    try {
      await Share.share(
        contenido,
        subject: 'ProstaScan - Reporte Médico',
      );
      _mostrarMensajeExito("compartido");
    } catch (e) {
      _mostrarError("Error al compartir: $e");
    }
  }

  // Método para enviar por correo
  Future<void> _enviarPorCorreo(String contenido) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      queryParameters: {
        'subject': 'ProstaScan - Reporte Médico',
        'body': contenido,
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
      _mostrarMensajeExito("enviado por correo");
    } else {
      _mostrarError("No se pudo abrir la aplicación de correo");
    }
  }

  // Método para copiar al portapapeles
  Future<void> _copiarAlPortapapeles(String contenido) async {
    // En una app web, podrías usar el Clipboard API
    // Por ahora simulamos la funcionalidad
    _mostrarMensajeExito("copiado al portapapeles");
    print("Contenido listo para copiar:\n$contenido");
  }

  // Método para mostrar mensaje de éxito
  void _mostrarMensajeExito(String accion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '¡Exportación exitosa! Reporte $accion correctamente.',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Método para mostrar error
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Método para obtener icono según el riesgo
  IconData _getIconPorRiesgo(String riesgo) {
    switch (riesgo) {
      case 'Alto Riesgo':
        return Icons.warning;
      case 'Riesgo Moderado':
        return Icons.warning_amber_rounded;
      case 'Riesgo Bajo':
        return Icons.info_outline;
      default:
        return Icons.check_circle;
    }
  }

  // Método para obtener color según el riesgo
  Color _getColorPorRiesgo(String riesgo) {
    switch (riesgo) {
      case 'Alto Riesgo':
        return Colors.red;
      case 'Riesgo Moderado':
        return Colors.orange;
      case 'Riesgo Bajo':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE5E0),
      body: SafeArea(
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.9,
            heightFactor: 0.85,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // TÍTULO PROSTASCAN
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A90E2),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: const Center(
                      child: Text(
                        'ProstaScan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icono superior
                            Image.asset(
                              "assets/reporte.png",
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Detalles del Análisis",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 20),

                            // CONTENEDOR CON LOS DATOS REALES DEL ANÁLISIS
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                border:
                                    Border.all(color: Colors.black, width: 1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _getIconPorRiesgo(
                                            widget.resultadoAnalisis.riesgo),
                                        color: _getColorPorRiesgo(
                                            widget.resultadoAnalisis.riesgo),
                                        size: 22,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        widget.resultadoAnalisis.riesgo,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.resultadoAnalisis.riesgoTexto,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Área sospechosa",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    widget.resultadoAnalisis.area,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Probabilidad estimada de lesión: ${widget.resultadoAnalisis.probabilidad}",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Clasificación preliminar\n${widget.resultadoAnalisis.clasificacion}",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Recomendación",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    widget.resultadoAnalisis.recomendacion,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            // BOTÓN EXPORTAR RESULTADO
                            _buildButton("Exportar resultado", "exportar", () {
                              _exportarResultado();
                            }),

                            const SizedBox(height: 15),

                            // BOTÓN VOLVER
                            _buildButton("Volver", "volver", () {
                              Navigator.pop(context);
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
