import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import '/viewmodels/condiciones_viewmodel.dart';

class Condiciones extends StatelessWidget {
  final String userEmail;
  final String userPassword;

  const Condiciones({
    super.key,
    required this.userEmail,
    required this.userPassword,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CondicionesViewModel()
        ..setUserCredentials(
            userEmail, userPassword), // 🔥 CORRECCIÓN: Pasar ambas credenciales
      child: Scaffold(
        backgroundColor: const Color(0xFFDDE5E0),
        body: SafeArea(
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.9,
              heightFactor: 0.92,
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
                child: Consumer<CondicionesViewModel>(
                  builder: (context, viewModel, _) =>
                      _CondicionesContent(viewModel: viewModel),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CondicionesContent extends StatefulWidget {
  final CondicionesViewModel viewModel;

  const _CondicionesContent({required this.viewModel});

  @override
  State<_CondicionesContent> createState() => __CondicionesContentState();
}

class __CondicionesContentState extends State<_CondicionesContent> {
  String _selected = "";

  void _handleAceptarCondiciones() async {
    final success = await widget.viewModel.aceptarCondiciones();

    if (success && mounted) {
      // Navegar a Home con el usuario
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Home(usuario: widget.viewModel.usuario!),
        ),
      );
    } else if (mounted) {
      // Mostrar error si falla
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.errorMessage),
          backgroundColor: Colors.red,
        ),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/logo.png", fit: BoxFit.contain),
                  const SizedBox(height: 20),

                  // Términos y condiciones
                  _buildTerminosCondiciones(),

                  const SizedBox(height: 40),

                  // Mostrar error si existe
                  Consumer<CondicionesViewModel>(
                    builder: (context, viewModel, _) {
                      if (viewModel.errorMessage.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            viewModel.errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),

                  // Botón Aceptar
                  Consumer<CondicionesViewModel>(
                    builder: (context, viewModel, _) {
                      return _buildAceptarButton(viewModel.isLoading);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTerminosCondiciones() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Image.asset("assets/contrato.png", fit: BoxFit.contain),
          const SizedBox(height: 10),
          const Text(
            'Esta aplicación procesa imágenes y resultados médicos. Sus datos serán almacenados de forma segura en su dispositivo y podrá decidir si desea compartirlos con un especialista. Al continuar, acepta nuestra política de privacidad y consentimiento informado.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAceptarButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                setState(() => _selected = "aceptar");
                _handleAceptarCondiciones();
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
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Aceptar y continuar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
