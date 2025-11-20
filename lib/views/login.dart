import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'condiciones.dart';
import 'home.dart';
import 'registro.dart';
import '/viewmodels/login_viewmodel.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
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
                  child: Consumer<LoginViewModel>(
                    builder: (context, viewModel, _) =>
                        _LoginContent(viewModel: viewModel),
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildSocialButtons(),
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Padding(
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
    );
  }
}

class _LoginContent extends StatelessWidget {
  final LoginViewModel viewModel;

  const _LoginContent({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo and slogan
          Image.asset("assets/botiquin.png", fit: BoxFit.contain),
          const SizedBox(height: 5),
          const Text(
            'Bienvenido',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Inicia sesión para continuar con tu cuidado',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 30),

          // Input fields
          _buildInputFields(viewModel),
          const SizedBox(height: 30),

          // Login button
          _buildLoginButton(context, viewModel),
          const SizedBox(height: 20),

          // Links
          _buildLinks(context),
        ],
      ),
    );
  }

  Widget _buildInputFields(LoginViewModel viewModel) {
    return Column(
      children: [
        TextField(
          onChanged: viewModel.updateEmail,
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
        const SizedBox(height: 20),
        TextField(
          onChanged: viewModel.updatePassword,
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

        // Error message
        if (viewModel.errorMessage.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildErrorMessage(viewModel.errorMessage),
        ],
      ],
    );
  }

  Widget _buildErrorMessage(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            errorMessage.contains("Error") ? Colors.red[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: errorMessage.contains("Error") ? Colors.red : Colors.orange,
        ),
      ),
      child: Row(
        children: [
          Icon(
            errorMessage.contains("Error")
                ? Icons.error_outline
                : Icons.warning_amber_outlined,
            color: errorMessage.contains("Error") ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color:
                    errorMessage.contains("Error") ? Colors.red : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, LoginViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            viewModel.isLoading ? null : () => _handleLogin(context, viewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3498DB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: viewModel.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'INGRESAR',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _handleLogin(
      BuildContext context, LoginViewModel viewModel) async {
    final usuario = await viewModel.login();

    if (usuario != null) {
      _showWelcomeMessage(context, usuario.nombre);

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (usuario.estado == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Condiciones(
                userEmail: usuario.correo,
                userPassword: usuario.password,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Home(usuario: usuario),
            ),
          );
        }
      });
    }
  }

  void _showWelcomeMessage(BuildContext context, String nombre) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Bienvenido $nombre!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildLinks(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Olvidaste tu contraseña?',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF27AE60),
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Registro()),
            );
          },
          child: const Text(
            '¿No tienes cuenta? Registrate',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF27AE60),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
