import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'subir.dart';
import 'historial.dart';
import 'perfil.dart';
import 'login.dart';
import '/models/user_model.dart';
import '/viewmodels/home_viewmodel.dart';

class Home extends StatelessWidget {
  final Usuario? usuario;
  const Home({super.key, this.usuario});

  @override
  Widget build(BuildContext context) {
    print('🏠 Home construido con usuario: ${usuario?.nombre}');

    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = HomeViewModel();
        if (usuario != null) {
          print('✅ HomeViewModel inicializado con: ${usuario?.nombre}');
          viewModel.setUsuario(usuario);
        } else {
          print('⚠️ HomeViewModel inicializado SIN usuario');
        }
        return viewModel;
      },
      child: _HomeScaffold(usuario: usuario),
    );
  }
}

class _HomeScaffold extends StatelessWidget {
  final Usuario? usuario;

  const _HomeScaffold({this.usuario});

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
              child: Consumer<HomeViewModel>(
                builder: (context, viewModel, _) {
                  return _HomeContent(viewModel: viewModel);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomeViewModel viewModel;

  const _HomeContent({required this.viewModel});

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await viewModel.showLogoutDialog(context);

    if (shouldLogout && context.mounted) {
      viewModel.clearUserData();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF4A90E2),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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

        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con nombre de usuario y menú
                  _buildUserHeader(context),
                  const SizedBox(height: 20),

                  // Resumen rápido
                  _buildQuickSummary(),
                  const SizedBox(height: 15),

                  // Análisis ejemplo
                  _buildAnalysisExample(),
                  const SizedBox(height: 20),

                  // Botones de navegación
                  _buildNavigationButtons(context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    final nombre = viewModel.nombreUsuario;
    print('👤 Mostrando nombre de usuario: $nombre');

    return Row(
      children: [
        // Nombre de usuario
        Expanded(
          child: Text(
            'Hola, $nombre',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),

        // Menú de usuario
        Container(
          width: 60,
          height: 60,
          child: PopupMenuButton<String>(
            icon: Image.asset(
              "assets/user3.png",
              fit: BoxFit.contain,
            ),
            onSelected: (String value) {
              _handleMenuSelection(context, value);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'perfil',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 8),
                    Text('Perfil'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'cerrar_sesion',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    if (value == 'perfil') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Perfil(usuario: viewModel.usuario),
        ),
      );
    } else if (value == 'cerrar_sesion') {
      _handleLogout(context);
    }
  }

  Widget _buildQuickSummary() {
    return const Text(
      'Resumen rápido de tu estado',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildAnalysisExample() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFA500),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'R',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Análisis Ejemplo',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '28/09/2025',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Resumen: Estado normal',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Botón Ver
          _buildButton("Ver", "ver", () {
            print("Botón Ver presionado");
          }),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      children: [
        // Nuevo Análisis
        Expanded(
          child: GestureDetector(
            onTap: () {
              print('🏠 HOME - Navegando a Subir');
              print('🏠 Usuario que se pasa: ${viewModel.usuario?.nombre}');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Upload(
                      usuario: viewModel.usuario), // ✅ CORREGIDO: PASAR USUARIO
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/camara.png",
                      fit: BoxFit.contain, height: 40),
                  const SizedBox(height: 8),
                  const Text(
                    'Nuevo Análisis',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Historial
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => Historial(usuario: viewModel.usuario)),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/tiempo.png",
                      fit: BoxFit.contain, height: 40),
                  const SizedBox(height: 8),
                  const Text(
                    'Historial',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String texto, String value, VoidCallback onTap) {
    //final bool isSelected = viewModel.selectedButton == value;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          viewModel.setSelectedButton(value);
          onTap();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF27AE60),
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF27AE60), width: 1),
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
