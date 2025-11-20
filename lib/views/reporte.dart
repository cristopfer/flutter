import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'detalle.dart';
import 'compartir.dart';
import '/models/user_model.dart';
import '/services/modeloIA_service.dart';
import '/viewmodels/reporte_viewmodel.dart';

class Reporte extends StatefulWidget {
  final PlatformFile? archivoProcesado;
  final Usuario? usuario;
  final AnalisisData? resultadoAnalisis;
  const Reporte(
      {super.key, this.archivoProcesado, this.usuario, this.resultadoAnalisis});

  @override
  State<Reporte> createState() => _ReporteState();
}

class _ReporteState extends State<Reporte> {
  String _selected = "";
  AnalisisData? _resultadoAnalisis;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    if (widget.resultadoAnalisis != null) {
      _resultadoAnalisis = widget.resultadoAnalisis;
    } else if (widget.archivoProcesado != null) {
      // Solo procesar si no viene con resultado
      _procesarArchivo();
    }
  }

  // Método para procesar el archivo y obtener el análisis - CORREGIDO
  Future<void> _procesarArchivo() async {
    if (widget.archivoProcesado != null) {
      setState(() {
        _procesando = true;
      });

      try {
        // ✅ USAR EL MÉTODO UNIVERSAL COMPATIBLE CON WEB
        final resultado = await ModeloIAService.analizarImagenUniversal(
            widget.archivoProcesado!);

        setState(() {
          _procesando = false;
          if (resultado.success && resultado.data != null) {
            _resultadoAnalisis = resultado.data;
          }
        });
      } catch (e) {
        setState(() {
          _procesando = false;
        });
        print("Error procesando archivo: $e");
      }
    }
  }

  // Método para navegar a Detalle
  void _irADetalle() {
    if (_resultadoAnalisis != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Detalle(
            usuario: widget.usuario,
            resultadoAnalisis: _resultadoAnalisis!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay resultado de análisis disponible'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ MÉTODO MODIFICADO - Ahora usa ReporteViewModel
  void _mostrarDialogoGuardar() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (_) => ReporteViewModel(),
          child: Consumer<ReporteViewModel>(
            builder: (context, viewModel, _) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/disk.png",
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Está por enviar sus resultados médicos al correo del especialista. Confirme que desea compartir esta información.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // ✅ MOSTRAR MENSAJES DE ERROR O ÉXITO
                      if (viewModel.errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  viewModel.errorMessage,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (viewModel.successMessage.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  viewModel.successMessage,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDialogButton(
                              "Cerrar",
                              "cerrar",
                              () {
                                Navigator.of(context).pop();
                              },
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildDialogButton(
                              viewModel.isLoading
                                  ? "Guardando..."
                                  : "Confirmar",
                              "confirmar",
                              viewModel.isLoading
                                  ? () {}
                                  : () =>
                                      _confirmarGuardado(context, viewModel),
                              color: const Color(0xFF3498DB),
                              isLoading: viewModel.isLoading,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ✅ NUEVO MÉTODO - Confirmar y guardar en historial
  Future<void> _confirmarGuardado(
      BuildContext context, ReporteViewModel viewModel) async {
    if (_resultadoAnalisis == null || widget.usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay datos de análisis para guardar'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Configurar los datos en el ViewModel
    viewModel.cargarDatosUsuario(widget.usuario!.correo);
    viewModel.updateRiesgo(_resultadoAnalisis!.riesgo);
    viewModel.updateAreaSospechosa(_resultadoAnalisis!.area);

    // Convertir probabilidad de string a double
    final probabilidadString =
        _resultadoAnalisis!.probabilidad.replaceAll('%', '');
    final probabilidad = double.tryParse(probabilidadString) ?? 0.0;
    viewModel.updateProbabilidad(probabilidad);

    viewModel.updateClasificacion(_resultadoAnalisis!.clasificacion);
    viewModel.updateRecomendacion(_resultadoAnalisis!.recomendacion);

    // Guardar el análisis
    final resultado = await viewModel.guardarAnalisis();

    if (resultado) {
      // Cerrar el diálogo después de un breve delay
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.of(context).pop();
        _mostrarMensajeExito();
      }
    }
    // Si hay error, se muestra automáticamente en el diálogo
  }

  void _mostrarMensajeExito() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Resultado guardado exitosamente en el historial',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildDialogButton(String texto, String value, VoidCallback onTap,
      {Color? color, bool isLoading = false}) {
    return SizedBox(
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? const Color(0xFF3498DB),
          foregroundColor: Colors.white,
          side: BorderSide(color: color ?? const Color(0xFF3498DB), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                texto,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

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

  Color _getColorPorRiesgo(String riesgo) {
    switch (riesgo) {
      case 'Alto Riesgo':
        return Colors.red;
      case 'Riesgo Moderado':
        return Colors.orange;
      case 'Riesgo Bajo':
        return Colors.blue;
      default:
        return Colors.grey;
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
                            Image.asset(
                              "assets/reporte.png",
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Reporte de Análisis',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (widget.archivoProcesado != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _resultadoAnalisis != null
                                      ? Colors.green[50]
                                      : _procesando
                                          ? Colors.blue[50]
                                          : Colors.orange[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _resultadoAnalisis != null
                                        ? Colors.green
                                        : _procesando
                                            ? Colors.blue
                                            : Colors.orange,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _resultadoAnalisis != null
                                          ? Icons.analytics
                                          : _procesando
                                              ? Icons.hourglass_empty
                                              : Icons.error_outline,
                                      color: _resultadoAnalisis != null
                                          ? Colors.green
                                          : _procesando
                                              ? Colors.blue
                                              : Colors.orange,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Archivo: ${widget.archivoProcesado!.name}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            _resultadoAnalisis != null
                                                ? 'Procesado exitosamente'
                                                : _procesando
                                                    ? 'Procesando análisis...'
                                                    : 'Error en el procesamiento',
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
                            const Text(
                              'Aquí se mostrará el informe detallado de tu último análisis.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _resultadoAnalisis?.riesgo ??
                                            (_procesando
                                                ? 'Procesando...'
                                                : 'No disponible'),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: _getColorPorRiesgo(
                                              _resultadoAnalisis?.riesgo ?? ''),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Image.asset(
                                        "assets/lupa.png",
                                        fit: BoxFit.contain,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  _buildButton(
                                      "Ver detalle",
                                      "detalle",
                                      _resultadoAnalisis != null
                                          ? _irADetalle
                                          : () {}),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            _buildButton(
                                "Compartir con especialista", "compartir", () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      Compartir(usuario: widget.usuario),
                                ),
                              );
                            }),
                            const SizedBox(height: 15),
                            _buildButton("Guardar en historial", "guardar", () {
                              _mostrarDialogoGuardar();
                            }),
                            const SizedBox(height: 15),
                            _buildButton("Volver", "volver", () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Home(usuario: widget.usuario),
                                ),
                                (route) => false,
                              );
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
