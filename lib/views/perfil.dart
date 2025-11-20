import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/user_model.dart';
import '/viewmodels/perfil_viewmodel.dart';

class Perfil extends StatelessWidget {
  final Usuario? usuario;

  const Perfil({super.key, this.usuario});

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
              child: ChangeNotifierProvider(
                create: (context) => PerfilViewModel()..setUsuario(usuario),
                child: _PerfilContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PerfilContent extends StatelessWidget {
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
              'Perfil',
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
            child: Consumer<PerfilViewModel>(
              builder: (context, viewModel, _) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile icon
                      Image.network(
                        'https://www.vhv.rs/dpng/d/436-4363443_view-user-icon-png-font-awesome-user-circle.png',
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),

                      // Username
                      Text(
                        viewModel.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Estado
                      Text(
                        'Estado: ${viewModel.estado}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Campos de información
                      _buildInfoFields(context, viewModel),
                      const SizedBox(height: 40),

                      // Botón Volver
                      _buildVolverButton(context, viewModel),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoFields(BuildContext context, PerfilViewModel viewModel) {
    return Column(
      children: [
        // Nombre completo
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Image.asset("assets/user2.png", fit: BoxFit.contain),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  viewModel.nombreCompleto,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),

        // Correo electrónico
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Image.asset("assets/correo.png", fit: BoxFit.contain),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  viewModel.correo,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),

        // Contraseña
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Image.asset("assets/candado.png", fit: BoxFit.contain),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '********',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () =>
                    _mostrarDialogoCambiarContrasena(context, viewModel),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF4A90E2), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                child: const Text(
                  'Cambiar',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4A90E2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),

        // Salud prostática
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Image.network(
                'https://cdn-icons-png.flaticon.com/512/11865/11865199.png',
                height: 20,
                width: 20,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Salud prostática: ${viewModel.saludProstatica}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVolverButton(BuildContext context, PerfilViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: viewModel.isLoading
            ? null
            : () {
                Navigator.pop(context);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.black, width: 1),
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
                'Volver',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  void _mostrarDialogoCambiarContrasena(
      BuildContext context, PerfilViewModel viewModel) {
    final nuevaContrasenaController = TextEditingController();
    final confirmarContrasenaController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Variables de estado DENTRO del StatefulBuilder
            bool isLoading = false;
            String errorMessage = '';

            // Calcular validaciones en cada build
            final passwordsMatch = nuevaContrasenaController.text ==
                confirmarContrasenaController.text;
            final isValid = nuevaContrasenaController.text.length >= 6 &&
                passwordsMatch &&
                nuevaContrasenaController.text.isNotEmpty &&
                confirmarContrasenaController.text.isNotEmpty;

            return AlertDialog(
              title: const Text('Cambiar Contraseña'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mensaje de error
                    if (errorMessage.isNotEmpty)
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
                                errorMessage,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),

                    // Campo nueva contraseña
                    TextField(
                      controller: nuevaContrasenaController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Nueva Contraseña',
                        border: OutlineInputBorder(),
                        hintText: 'Mínimo 6 caracteres',
                      ),
                      onChanged: (value) {
                        setState(() {
                          errorMessage = ''; // Forzar rebuild
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo confirmar contraseña
                    TextField(
                      controller: confirmarContrasenaController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar Contraseña',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          errorMessage = ''; // Forzar rebuild
                        });
                      },
                    ),

                    // Mensaje de validación en tiempo real
                    if (nuevaContrasenaController.text.isNotEmpty &&
                        confirmarContrasenaController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          passwordsMatch
                              ? '✓ Las contraseñas coinciden'
                              : '✗ Las contraseñas no coinciden',
                          style: TextStyle(
                            color: passwordsMatch ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: (isLoading || !isValid)
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                            errorMessage = '';
                          });

                          final success = await viewModel.cambiarContrasena(
                            nuevaContrasenaController.text.trim(),
                            confirmarContrasenaController.text.trim(),
                          );

                          setState(() {
                            isLoading = false;
                          });

                          if (success && context.mounted) {
                            // Mostrar mensaje de éxito
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    '✓ Contraseña actualizada correctamente'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                              ),
                            );
                            Navigator.of(dialogContext).pop();
                          } else if (context.mounted) {
                            // Mostrar mensaje de error
                            setState(() {
                              errorMessage = viewModel.errorMessage;
                            });
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Cambiar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
