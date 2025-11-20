import 'package:flutter/material.dart';
import '/services/user_service.dart';
import '/models/user_model.dart';

class LoginViewModel extends ChangeNotifier {
  String email = '';
  String password = '';
  String errorMessage = '';
  bool isLoading = false;
  Usuario? currentUser;

  // Validaciones
  bool get isFormValid => email.isNotEmpty && password.isNotEmpty;

  void updateEmail(String value) {
    email = value;
    _clearError();
  }

  void updatePassword(String value) {
    password = value;
    _clearError();
  }

  void _clearError() {
    if (errorMessage.isNotEmpty) {
      errorMessage = '';
      notifyListeners();
    }
  }

  void setError(String message) {
    errorMessage = message;
    notifyListeners();
  }

  Future<Usuario?> login() async {
    if (email.isEmpty || password.isEmpty) {
      setError("Por favor, complete todos los campos");
      return null;
    }

    isLoading = true;
    notifyListeners();

    try {
      // Validar credenciales
      final response = await UserService.validateUser(email, password);

      isLoading = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        currentUser = response['user'] as Usuario;

        // Manejar diferentes estados del usuario
        final estado = response['estado'];
        final mensaje = response['message'];

        if (estado == 1) {
          // Usuario activo - login exitoso
          return currentUser;
        } else if (estado == 0) {
          return currentUser;
        } else if (estado == 2) {
          // Usuario bloqueado
          setError("Cuenta bloqueada. Contacte al administrador.");
          return null;
        } else {
          // Estado desconocido
          setError("Estado de cuenta desconocido: $mensaje");
          return null;
        }
      } else {
        setError("Error de logueo: Correo o contraseña incorrectos");
        return null;
      }
    } catch (e) {
      isLoading = false;
      setError("Error en el proceso de login: $e");
      notifyListeners();
      return null;
    }
  }

  void reset() {
    email = '';
    password = '';
    errorMessage = '';
    isLoading = false;
    currentUser = null;
    notifyListeners();
  }
}
