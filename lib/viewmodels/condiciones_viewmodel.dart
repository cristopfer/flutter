import 'package:flutter/material.dart';
import '/services/user_service.dart';
import '/models/user_model.dart';

class CondicionesViewModel extends ChangeNotifier {
  // Estados
  String _userEmail = '';
  String _userPassword = ''; // 🔥 NUEVO: Necesitamos la contraseña
  bool _isLoading = false;
  String _errorMessage = '';
  Usuario? _usuario;

  // Getters
  String get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Usuario? get usuario => _usuario;

  // Setters
  void setUserEmail(String email) {
    _userEmail = email;
  }

  void setUserPassword(String password) {
    // 🔥 NUEVO: Setter para contraseña
    _userPassword = password;
  }

  void setUserCredentials(String email, String password) {
    // 🔥 CONVENIENCIA
    _userEmail = email;
    _userPassword = password;
  }

  // Método para aceptar condiciones
  Future<bool> aceptarCondiciones() async {
    if (_userEmail.isEmpty || _userPassword.isEmpty) {
      // 🔥 VALIDAR CONTRASEÑA
      _errorMessage = "Credenciales del usuario no disponibles";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      print("🔐 Aceptando condiciones para: $_userEmail");

      // 🔥 ACTUALIZADO: Llamar al endpoint API con email y contraseña
      final response =
          await UserService.updateUserStatus(_userEmail, _userPassword, 1);

      if (response != null && response['success'] == true) {
        print('✅ Estado del usuario actualizado exitosamente via API');

        // Obtener el usuario actualizado
        _usuario = response['user'] as Usuario;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final error =
            response?['error'] ?? 'Error desconocido al aceptar condiciones';
        _errorMessage = error;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error en el proceso: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Resetear ViewModel
  void reset() {
    _userEmail = '';
    _userPassword = ''; // 🔥 LIMPIAR CONTRASEÑA
    _isLoading = false;
    _errorMessage = '';
    _usuario = null;
    notifyListeners();
  }
}
