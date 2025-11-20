import 'package:flutter/material.dart';
// Importa tus pantallas
import 'login.dart';
import 'registro.dart';

class Presentacion extends StatefulWidget {
  const Presentacion({super.key});

  @override
  State<Presentacion> createState() => _PresentacionState();
}

class _PresentacionState extends State<Presentacion> {
  String _selected = ""; // guarda qué botón fue presionado

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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      SizedBox(
                        height: 120,
                        child:
                            Image.asset("assets/logo.png", fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'ProstaScan',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Segmentación y clasificación de\nimágenes prostáticas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Botón Iniciar Sesión
                      _buildButton("Iniciar Sesión", "login", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Login()),
                        );
                      }),
                      const SizedBox(height: 16),

                      // Botón Nuevo Análisis
                      _buildButton("Nuevo Análisis", "analisis", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Login()),
                        );
                      }),
                      const SizedBox(height: 16),

                      // Botón Registrarse
                      _buildButton("Registrarse", "register", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Registro()),
                        );
                      }),

                      const SizedBox(height: 25),
                      const Text(
                        'Versión preliminar Beta',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/facebook.png", fit: BoxFit.contain),
            const SizedBox(width: 25),
            Image.asset("assets/google.png", fit: BoxFit.contain),
            const SizedBox(width: 25),
            Image.asset("assets/apple.png", fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }

  /// Método que construye los botones con estilo dinámico y acción
  Widget _buildButton(String texto, String value, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() => _selected = value);
          onTap(); // Ejecuta la acción de navegación
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
}
