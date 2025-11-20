import 'package:flutter/material.dart';
import '/services/user_service.dart';
import '/models/user_model.dart';

class RegistroViewModel extends ChangeNotifier {
  // Estados del ViewModel
  String nombre = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String errorMessage = '';
  bool isLoading = false;
  bool registroExitoso = false;

  // Validaciones
  bool get isFormValid =>
      nombre.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty;

  bool get passwordsMatch => password == confirmPassword;

  bool get emailIsValid => email.contains('@') && email.contains('.');

  bool get passwordIsStrong => password.length >= 6;

  // Métodos para actualizar estado
  void updateNombre(String value) {
    nombre = value;
    _clearError();
  }

  void updateEmail(String value) {
    email = value;
    _clearError();
  }

  void updatePassword(String value) {
    password = value;
    _clearError();
  }

  void updateConfirmPassword(String value) {
    confirmPassword = value;
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

  // Método principal de registro
  Future<bool> registrarUsuario() async {
    // Validaciones
    if (!isFormValid) {
      setError("Por favor, complete todos los campos");
      return false;
    }

    if (!passwordsMatch) {
      setError("Las contraseñas no coinciden");
      return false;
    }

    if (!emailIsValid) {
      setError("Por favor, ingrese un correo electrónico válido");
      return false;
    }

    if (!passwordIsStrong) {
      setError("La contraseña debe tener al menos 6 caracteres");
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      // Crear nuevo usuario
      final nuevoUsuario = Usuario(
        nombre: nombre.trim(),
        correo: email.trim().toLowerCase(),
        password: password,
        estado: 0, // Estado por defecto (no ha aceptado condiciones)
      );

      // 🔥 LLAMADA ACTUALIZADA: Registrar usuario via API
      final response = await UserService.addUser(nuevoUsuario);

      isLoading = false;

      if (response != null && response['success'] == true) {
        registroExitoso = true;
        notifyListeners();
        return true;
      } else {
        final error = response?['error'] ?? "Error desconocido en el registro";
        setError(error);
        return false;
      }
    } catch (e) {
      isLoading = false;
      setError("Error en el registro: $e");
      notifyListeners();
      return false;
    }
  }

  // Resetear el ViewModel
  void reset() {
    nombre = '';
    email = '';
    password = '';
    confirmPassword = '';
    errorMessage = '';
    isLoading = false;
    registroExitoso = false;
    notifyListeners();
  }
}
