import 'package:flutter/material.dart';
import '/models/user_model.dart'; //

class HomeViewModel extends ChangeNotifier {
  // Estados
  Usuario? _usuario;
  String _selectedButton = "";
  bool _isLoading = false;

  // Getters
  Usuario? get usuario {
    print(
        '🔍 HomeViewModel.usuario getter - Usuario actual: ${_usuario?.nombre}');
    return _usuario;
  }

  String get selectedButton => _selectedButton;
  bool get isLoading => _isLoading;

  String get nombreUsuario {
    final nombre = _usuario?.nombre ?? 'Usuario';
    print('🔍 HomeViewModel.nombreUsuario getter - Nombre: $nombre');
    return nombre;
  }

  void inicializarUsuario(Usuario? usuario) {
    print('🔄 HomeViewModel.inicializarUsuario() - INICIANDO');
    print('🔄 Usuario nuevo: ${usuario?.nombre}');

    _usuario = usuario;

    print(
        '✅ HomeViewModel.inicializarUsuario() - Usuario establecido: ${_usuario?.nombre}');
    print('✅ HomeViewModel.inicializarUsuario() - Correo: ${_usuario?.correo}');

    // ❌ NO LLAMAR notifyListeners() aquí durante la inicialización
  }

  // Setters
  void setUsuario(Usuario? usuario) {
    print('🔄 HomeViewModel.setUsuario() - INICIANDO');
    print('🔄 Usuario anterior: ${_usuario?.nombre}');
    print('🔄 Usuario nuevo: ${usuario?.nombre}');

    _usuario = usuario;

    print(
        '✅ HomeViewModel.setUsuario() - Usuario establecido: ${_usuario?.nombre}');
    print('✅ HomeViewModel.setUsuario() - Correo: ${_usuario?.correo}');
    print('✅ HomeViewModel.setUsuario() - Estado: ${_usuario?.estado}');

    // Forzar notificación inmediata
    notifyListeners();

    print('📢 HomeViewModel.setUsuario() - Listeners notificados');
  }

  void setSelectedButton(String value) {
    print('🔄 HomeViewModel.setSelectedButton() - Botón: $value');
    _selectedButton = value;
    notifyListeners();
  }

  void setLoading(bool loading) {
    print('🔄 HomeViewModel.setLoading() - Loading: $loading');
    _isLoading = loading;
    notifyListeners();
  }

  // Método para confirmar logout - AHORA RETORNA Future<bool>
  Future<bool> showLogoutDialog(BuildContext context) async {
    print('🔄 HomeViewModel.showLogoutDialog() - Mostrando diálogo');

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                print('❌ HomeViewModel - Logout cancelado');
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                print('✅ HomeViewModel - Logout confirmado');
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    final finalResult = result ?? false;
    print('🔚 HomeViewModel.showLogoutDialog() - Resultado: $finalResult');
    return finalResult;
  }

  // ✅ MÉTODO ACTUALIZADO - Ahora limpia SharedPreferences
  Future<void> clearUserData() async {
    print('🔄 HomeViewModel.clearUserData() - Limpiando datos');
    // Limpiar SharedPreferences usando UserService
    // Limpiar datos locales del ViewModel
    //await UserService.clearAllSharedPreferences();
    _usuario = null;
    _selectedButton = "";
    _isLoading = false;

    print(
        '✅ HomeViewModel.clearUserData() - Datos locales y SharedPreferences limpiados');
    notifyListeners();
  }

  // Verificar estado actual del ViewModel
  void printEstadoActual() {
    print('📊 ESTADO ACTUAL DEL HOMEVIEWMODEL:');
    print('📊 Usuario: ${_usuario?.nombre}');
    print('📊 Correo: ${_usuario?.correo}');
    print('📊 Estado: ${_usuario?.estado}');
    print('📊 Botón seleccionado: $_selectedButton');
    print('📊 Loading: $_isLoading');
  }

  // Resetear ViewModel (solo datos locales)
  void reset() {
    print('🔄 HomeViewModel.reset() - Reseteando ViewModel');

    _usuario = null;
    _selectedButton = "";
    _isLoading = false;

    print('✅ HomeViewModel.reset() - ViewModel reseteado');
    notifyListeners();
  }
}
