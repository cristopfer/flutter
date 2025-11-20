import 'package:flutter/material.dart';
import '/models/historial_model.dart';
import '/services/historial_service.dart';
import '/models/user_model.dart';

class HistorialViewModel extends ChangeNotifier {
  // Estados
  List<AnalisisHistorial> _historial = [];
  bool _isLoading = true;
  String _selectedButton = "";
  Usuario? _usuario;
  String _errorMessage = '';

  // Getters
  List<AnalisisHistorial> get historial => _historial;
  bool get isLoading => _isLoading;
  String get selectedButton => _selectedButton;
  Usuario? get usuario => _usuario;
  String get errorMessage => _errorMessage;

  // Setters
  void setUsuario(Usuario? usuario) {
    _usuario = usuario;
    print('🔄 HistorialViewModel - Usuario establecido: ${usuario?.correo}');
    _cargarHistorialUsuario();
  }

  void setSelectedButton(String value) {
    _selectedButton = value;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // ✅ CARGAR HISTORIAL DESDE EL SERVICIO
  Future<void> _cargarHistorialUsuario() async {
    if (_usuario == null) {
      print('⚠️ HistorialViewModel - No hay usuario para cargar historial');
      _historial = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    setLoading(true);
    clearError();

    try {
      // ✅ LLAMAR AL SERVICIO PARA OBTENER HISTORIAL
      final resultado =
          await HistorialService.obtenerHistorialUsuario(_usuario!.correo);

      if (resultado['success'] == true) {
        _historial = (resultado['data'] as List<AnalisisHistorial>);
        print(
            '✅ HistorialViewModel - Historial cargado: ${_historial.length} análisis para ${_usuario!.correo}');
      } else {
        setError(resultado['error'] ?? 'Error desconocido al cargar historial');
        _historial = [];
        print('❌ HistorialViewModel - Error: ${resultado['error']}');
      }
    } catch (e) {
      setError('Error de conexión: $e');
      _historial = [];
      print('❌ HistorialViewModel - Error cargando historial: $e');
    } finally {
      setLoading(false);
    }
  }

  // ✅ MÉTODO PARA RECARGAR HISTORIAL MANUALMENTE
  Future<void> recargarHistorial() async {
    if (_usuario != null) {
      print('🔄 HistorialViewModel - Recargando historial...');
      await _cargarHistorialUsuario();
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // ✅ VERIFICAR SI TIENE HISTORIAL
  bool get tieneHistorial => _historial.isNotEmpty;

  // ✅ AGREGAR NUEVO ANÁLISIS AL HISTORIAL (para actualizar después de guardar)
  void agregarAnalisis(AnalisisHistorial nuevoAnalisis) {
    _historial.insert(0, nuevoAnalisis); // Insertar al inicio
    print(
        '✅ HistorialViewModel - Nuevo análisis agregado: ${nuevoAnalisis.numAnalisis}');
    notifyListeners();
  }

  // ✅ REINICIAR VIEWMODEL
  void reset() {
    _historial = [];
    _isLoading = true;
    _selectedButton = "";
    _usuario = null;
    _errorMessage = '';
    notifyListeners();
  }
}
