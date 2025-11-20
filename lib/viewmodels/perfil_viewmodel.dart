import 'package:flutter/material.dart';
import '/services/user_service.dart';
import '/models/user_model.dart';

class PerfilViewModel extends ChangeNotifier {
  // Estados
  Usuario? _usuario;
  String _selectedButton = "";
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  // Getters
  Usuario? get usuario => _usuario;
  String get selectedButton => _selectedButton;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;

  // Datos del usuario para la UI
  String get nombreCompleto => _usuario?.nombre ?? 'Usuario no disponible';
  String get correo => _usuario?.correo ?? 'Correo no disponible';
  String get estado =>
      _usuario?.estado == 1 ? 'Activo' : 'Pendiente de activación';
  String get saludProstatica => 'Estado normal';

  // Setters
  void setUsuario(Usuario? usuario) {
    _usuario = usuario;
    print('🔄 PerfilViewModel - Usuario establecido: ${usuario?.nombre}');
    notifyListeners();
  }

  void setSelectedButton(String value) {
    _selectedButton = value;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = '';
    _successMessage = '';
  }

  // Método para cambiar contraseña
  Future<bool> cambiarContrasena(
      String nuevaContrasena, String confirmarContrasena) async {
    print('🔄 Iniciando cambio de contraseña...');
    _clearMessages();

    // Validaciones
    if (nuevaContrasena.isEmpty || confirmarContrasena.isEmpty) {
      _errorMessage = 'Por favor, complete todos los campos';
      print('❌ Validación fallida: Campos vacíos');
      notifyListeners();
      return false;
    }

    if (nuevaContrasena.length < 6) {
      _errorMessage = 'La contraseña debe tener al menos 6 caracteres';
      print('❌ Validación fallida: Contraseña muy corta');
      notifyListeners();
      return false;
    }

    if (nuevaContrasena != confirmarContrasena) {
      _errorMessage = 'Las contraseñas no coinciden';
      print('❌ Validación fallida: Contraseñas no coinciden');
      notifyListeners();
      return false;
    }

    if (_usuario == null) {
      _errorMessage = 'Usuario no disponible';
      print('❌ Validación fallida: Usuario nulo');
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('📞 Llamando a UserService.updateUserPassword...');
      print('📧 Email: ${_usuario!.correo}');
      print(
          '🔐 Nueva contraseña: ${nuevaContrasena.replaceAll(RegExp(r'.'), '*')}');

      // Llamar al servicio para actualizar la contraseña
      final actualizado = await UserService.updateUserPassword(
          _usuario!.correo, nuevaContrasena);

      _isLoading = false;

      if (actualizado) {
        _successMessage = 'Contraseña actualizada exitosamente';
        print('✅ Contraseña actualizada correctamente en UserService');

        // Actualizar el usuario local con la nueva contraseña
        _usuario = Usuario(
          nombre: _usuario!.nombre,
          correo: _usuario!.correo,
          password: nuevaContrasena,
          estado: _usuario!.estado,
        );

        print('✅ Usuario local actualizado con nueva contraseña');
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Error al actualizar la contraseña en el servicio';
        print('❌ UserService.updateUserPassword retornó false');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error: $e';
      print('❌ Excepción en cambiarContrasena: $e');
      notifyListeners();
      return false;
    }
  }

  // Resetear ViewModel
  void reset() {
    _usuario = null;
    _selectedButton = "";
    _isLoading = false;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();
  }
}
