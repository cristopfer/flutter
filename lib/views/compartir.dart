import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'reporte.dart';
import '/models/user_model.dart';

class Compartir extends StatelessWidget {
  final Usuario? usuario; // ✅ AGREGAR PARÁMETRO USUARIO

  const Compartir({super.key, this.usuario}); // ✅ AGREGAR AL CONSTRUCTOR

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DetalleScreen(usuario: usuario), // ✅ PASAR USUARIO A DETALLESCREEN
    );
  }
}

class DetalleScreen extends StatefulWidget {
  final Usuario? usuario; // ✅ AGREGAR PARÁMETRO USUARIO

  const DetalleScreen({super.key, this.usuario}); // ✅ AGREGAR AL CONSTRUCTOR

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  String _selected = ""; // Controla qué botón está seleccionado
  bool _incluirDatos = false;
  String? _fileName; // Para mostrar el nombre del archivo seleccionado
  PlatformFile? _selectedFile; // Archivo seleccionado
  final TextEditingController _emailController = TextEditingController();

  // Método para seleccionar archivo
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'bmp',
          'tiff',
          'tif',
          'dcm',
          'pdf',
          'doc',
          'docx'
        ],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _fileName = _selectedFile!.name;
        });
      } else {
        // Usuario canceló la selección
        print("Selección de archivo cancelada");
      }
    } catch (e) {
      print("Error al seleccionar archivo: $e");
      // Mostrar mensaje de error al usuario
      if (!mounted) return;
      _showErrorDialog("Error al seleccionar archivo: $e");
    }
  }

  // Método para validar y enviar
  void _validarYEnviar() {
    // Validar campos
    if (_emailController.text.isEmpty) {
      _showErrorDialog(
          "Por favor, ingrese el correo electrónico del especialista.");
      return;
    }

    if (_selectedFile == null) {
      _showErrorDialog("Por favor, adjunte un archivo antes de enviar.");
      return;
    }

    if (!_incluirDatos) {
      _showErrorDialog(
          "Por favor, confirme si desea incluir datos médicos sensibles.");
      return;
    }

    // Si todos los campos están llenos, mostrar mensaje de éxito
    _mostrarMensajeExito();
  }

  // Método para mostrar mensaje de éxito
  void _mostrarMensajeExito() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                '¡Envío exitoso! El reporte ha sido compartido con el especialista.',
                style: TextStyle(fontSize: 16),
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

    // Opcional: Limpiar formulario después del envío exitoso
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _emailController.clear();
        _fileName = null;
        _selectedFile = null;
        _incluirDatos = false;
      });
    });
  }

  // Método para mostrar diálogo de error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error de validación"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Método para construir botones con el mismo efecto del login
  Widget _buildButton(String texto, String value, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() => _selected = value);
          onTap();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFF3498DB), // Blanco cuando no está seleccionado
          foregroundColor: Colors.white, // Texto
          side: const BorderSide(
              color: Color(0xFF3498DB), width: 1), // Borde negro
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
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
                  // ✅ BARRA DE TÍTULO AZUL COMO LAS OTRAS PANTALLAS
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
                            // Icono de compartir
                            Image.asset(
                              'assets/reporte.png', // coloca tu imagen en assets
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 20),

                            // Título
                            const Text(
                              "Compartir con Especialista",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Campo de correo
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email_outlined),
                                hintText: "Correo electrónico del especialista",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ✅ BOTÓN ADJUNTAR RESULTADO CON EFECTO DEL LOGIN - MODIFICADO
                            _buildButton(
                                "Adjuntar resultado", "adjuntar", _pickFile),

                            // Mostrar nombre del archivo seleccionado
                            if (_fileName != null) ...[
                              const SizedBox(height: 15),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.attach_file,
                                        color: Colors.green),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Archivo adjunto: $_fileName',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'Tamaño: ${(_selectedFile!.size / 1024).toStringAsFixed(2)} KB',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          _fileName = null;
                                          _selectedFile = null;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Checkbox incluir datos sensibles
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _incluirDatos,
                                    onChanged: (value) {
                                      setState(() {
                                        _incluirDatos = value!;
                                      });
                                    },
                                  ),
                                  const Expanded(
                                    child: Text(
                                      "Incluir datos médicos sensibles en el envío",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),

                            // ✅ BOTÓN ENVIAR CON EFECTO DEL LOGIN - MODIFICADO
                            _buildButton("Enviar", "enviar", _validarYEnviar),

                            const SizedBox(height: 15),

                            // ✅ BOTÓN CANCELAR CON EFECTO DEL LOGIN
                            _buildButton("Cancelar", "cancelar", () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Reporte(
                                      usuario: widget
                                          .usuario), // ✅ PASAR USUARIO A REPORTE
                                ),
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
