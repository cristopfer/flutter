import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'reporte.dart';
import 'detalle.dart';
import '/models/user_model.dart';
import '/services/modeloIA_service.dart';

class Procesando extends StatefulWidget {
  final PlatformFile? selectedFile;
  final Usuario? usuario;
  const Procesando({super.key, this.selectedFile, this.usuario});

  @override
  State<Procesando> createState() => _ProcesandoState();
}

class _ProcesandoState extends State<Procesando> {
  String _selected = "";
  bool _isProcessing = true;
  String _estadoProcesamiento = "Iniciando análisis...";

  @override
  void initState() {
    super.initState();
    _procesarImagen();
  }

  // Método para procesar la imagen real - CORREGIDO
  Future<void> _procesarImagen() async {
    if (widget.selectedFile == null) {
      setState(() {
        _estadoProcesamiento = "Error: No hay archivo seleccionado";
        _isProcessing = false;
      });
      return;
    }

    try {
      setState(() {
        _estadoProcesamiento = "Cargando imagen...";
      });

      setState(() {
        _estadoProcesamiento = "Analizando con IA...";
      });

      // ✅ USAR EL MÉTODO UNIVERSAL COMPATIBLE CON WEB
      final resultado =
          await ModeloIAService.analizarImagenUniversal(widget.selectedFile!);

      if (resultado.success && resultado.data != null) {
        setState(() {
          _estadoProcesamiento = "Análisis completado ✓";
          _isProcessing = false;
        });

        // ✅ NAVEGAR A REPORTE CON EL RESULTADO REAL
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Reporte(
              archivoProcesado: widget.selectedFile,
              usuario: widget.usuario,
              resultadoAnalisis: resultado.data!,
            ),
          ),
        );
      } else {
        setState(() {
          _estadoProcesamiento = "Error en el análisis: ${resultado.error}";
          _isProcessing = false;
        });

        // ✅ NAVEGAR A REPORTE COMO FALLBACK
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => Reporte(
                  archivoProcesado: widget.selectedFile,
                  usuario: widget.usuario,
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      setState(() {
        _estadoProcesamiento = "Error: $e";
        _isProcessing = false;
      });

      // ✅ NAVEGAR A REPORTE EN CASO DE ERROR
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => Reporte(
                archivoProcesado: widget.selectedFile,
                usuario: widget.usuario,
              ),
            ),
          );
        }
      });
    }
  }

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
                            // Processing icon with animation
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF4A90E2)),
                                  strokeWidth: 6,
                                ),
                                Icon(
                                  _isProcessing ? Icons.analytics : Icons.check,
                                  color: _isProcessing
                                      ? Colors.blue
                                      : Colors.green,
                                  size: 30,
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // Processing text
                            Text(
                              _estadoProcesamiento,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _isProcessing
                                    ? Colors.black87
                                    : _estadoProcesamiento.contains('Error')
                                        ? Colors.red
                                        : Colors.green,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Información del archivo si está disponible
                            if (widget.selectedFile != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _isProcessing
                                      ? Colors.blue[50]
                                      : _estadoProcesamiento.contains('Error')
                                          ? Colors.red[50]
                                          : Colors.green[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _isProcessing
                                        ? Colors.blue
                                        : _estadoProcesamiento.contains('Error')
                                            ? Colors.red
                                            : Colors.green,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _isProcessing
                                          ? Icons.file_present
                                          : _estadoProcesamiento
                                                  .contains('Error')
                                              ? Icons.error
                                              : Icons.check_circle,
                                      color: _isProcessing
                                          ? Colors.blue
                                          : _estadoProcesamiento
                                                  .contains('Error')
                                              ? Colors.red
                                              : Colors.green,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Archivo: ${widget.selectedFile!.name}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'Tamaño: ${(widget.selectedFile!.size / 1024).toStringAsFixed(2)} KB',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            Text(
                              _isProcessing
                                  ? 'Estamos analizando tu imagen con nuestro modelo de IA.'
                                  : _estadoProcesamiento.contains('Error')
                                      ? 'Hubo un problema al procesar la imagen.'
                                      : '¡Análisis completado exitosamente!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),

                            if (_isProcessing)
                              const Text(
                                'Por favor espera, esto puede tomar unos segundos...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            const SizedBox(height: 40),

                            // ✅ BOTÓN VOLVER
                            _buildButton("Volver", "volver", () {
                              _isProcessing = false;
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
