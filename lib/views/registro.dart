import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import '/viewmodels/registro_viewmodel.dart';

class Registro extends StatelessWidget {
  const Registro({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegistroViewModel(),
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
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Consumer<RegistroViewModel>(
                    builder: (context, viewModel, _) =>
                        _RegistroContent(viewModel: viewModel),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegistroContent extends StatefulWidget {
  final RegistroViewModel viewModel;

  const _RegistroContent({required this.viewModel});

  @override
  State<_RegistroContent> createState() => __RegistroContentState();
}

class __RegistroContentState extends State<_RegistroContent> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _selected = "";

  @override
  void initState() {
    super.initState();

    // Sincronizar controllers con ViewModel
    _nombreController.addListener(() {
      widget.viewModel.updateNombre(_nombreController.text);
    });

    _emailController.addListener(() {
      widget.viewModel.updateEmail(_emailController.text);
    });

    _passwordController.addListener(() {
      widget.viewModel.updatePassword(_passwordController.text);
    });

    _confirmPasswordController.addListener(() {
      widget.viewModel.updateConfirmPassword(_confirmPasswordController.text);
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegistro() async {
    final success = await widget.viewModel.registrarUsuario();

    if (success && mounted) {
      _showSuccessMessage(widget.viewModel.nombre);

      // Navegar al login después de 2 segundos
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Login()),
          );
        }
      });
    }
  }

  void _showSuccessMessage(String nombre) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Cuenta creada exitosamente para $nombre!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo user+
          Image.asset("assets/user1.png", fit: BoxFit.contain),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Crear Cuenta',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Slogan
          const Text(
            'Registrate para acceder a tu cuidado',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 30),

          // Input fields
          _buildInputFields(),

          // Mensaje de error CON CONSUMER
          Consumer<RegistroViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.errorMessage.isEmpty) return const SizedBox();
              return Column(
                children: [
                  const SizedBox(height: 20),
                  _buildErrorMessage(viewModel.errorMessage),
                ],
              );
            },
          ),

          const SizedBox(height: 25),

          // Registrarse button CON CONSUMER
          Consumer<RegistroViewModel>(
            builder: (context, viewModel, _) {
              return _buildRegistroButton(viewModel.isLoading);
            },
          ),

          const SizedBox(height: 20),

          // Login link
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        TextField(
          controller: _nombreController,
          decoration: InputDecoration(
            prefixIcon: Image.asset("assets/user2.png", fit: BoxFit.contain),
            labelText: 'Nombre completo',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            prefixIcon: Image.asset("assets/correo.png", fit: BoxFit.contain),
            labelText: 'Correo electrónico',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: Image.asset("assets/candado.png", fit: BoxFit.contain),
            labelText: 'Contraseña',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: Image.asset("assets/candado1.png", fit: BoxFit.contain),
            labelText: 'Confirmar contraseña',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_outlined,
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistroButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                setState(() => _selected = "registrarse");
                _handleRegistro();
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
                'Registrarse',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Login()),
        );
      },
      child: const Text(
        '¿Ya tienes cuenta? Inicia sesión',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF27AE60),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
