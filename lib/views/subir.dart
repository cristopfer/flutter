import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '/models/user_model.dart';
import 'scan.dart'; // Importar Scan para la navegación

class Upload extends StatefulWidget {
  final Usuario? usuario;
  const Upload({super.key, this.usuario});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  String _selected = ""; // Controla qué botón está seleccionado
  String? _fileName; // Para mostrar el nombre del archivo seleccionado
  PlatformFile? _selectedFile; // Archivo seleccionado
  @override
  void initState() {
    super.initState();
  }

  // Método para seleccionar archivo
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp', 'tiff', 'tif', 'dcm'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _fileName = _selectedFile!.name;
        });

        // Navegar a Scan después de seleccionar el archivo
        // Puedes pasar el archivo como argumento si lo necesitas en Scan
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scan(
              selectedFile: _selectedFile,
              usuario: widget.usuario,
            ),
          ),
        );
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

  // Método para mostrar diálogo de error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
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
    final bool isSelected = _selected == value;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() => _selected = value);
          onTap(); // Ejecuta la acción
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3498DB),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFDDE5E0), // Slightly darker green background
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
                  // Embedded and extended blue title bar
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
                            // Upload icon
                            Image.asset(
                              "assets/subir.png", // Cambia por tu asset local
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Subir Imagen',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Selecciona una imagen para analizar.\nFormatos soportados: JPG, PNG, BMP, TIFF, DICOM',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),

                            // Mostrar nombre del archivo seleccionado (opcional)
                            if (_fileName != null) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.file_present,
                                        color: Colors.blue),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _fileName!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 40),

                            // ✅ BOTÓN SUBIR CON EFECTO DEL LOGIN
                            _buildButton("Subir", "subir", _pickFile),

                            const SizedBox(height: 15), // Espacio entre botones

                            // ✅ BOTÓN CANCELAR CON EFECTO DEL LOGIN
                            _buildButton("Cancelar", "cancelar", () {
                              // ✅ VOLVER A LA PANTALLA HOME
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
