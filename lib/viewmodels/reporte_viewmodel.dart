import 'package:flutter/material.dart';
import '/services/historial_service.dart';
import '/models/historial_model.dart';

class ReporteViewModel extends ChangeNotifier {
  // Datos del reporte
  String _correo = '';
  String _riesgo = '';
  String _areaSospechosa = '';
  double _probabilidad = 0.0;
  String _clasificacion = '';
  String _recomendacion = '';

  // Estado de la UI
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  // Getters
  String get correo => _correo;
  String get riesgo => _riesgo;
  String get areaSospechosa => _areaSospechosa;
  double get probabilidad => _probabilidad;
  String get clasificacion => _clasificacion;
  String get recomendacion => _recomendacion;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;

  // Validaciones
  bool get isFormValid =>
      _correo.isNotEmpty &&
      _riesgo.isNotEmpty &&
      _areaSospechosa.isNotEmpty &&
      _probabilidad > 0 &&
      _clasificacion.isNotEmpty;

  // Setters para actualizar datos
  void updateCorreo(String value) {
    _correo = value;
    _clearMessages();
    notifyListeners();
  }

  void updateRiesgo(String value) {
    _riesgo = value;
    _clearMessages();
    notifyListeners();
  }

  void updateAreaSospechosa(String value) {
    _areaSospechosa = value;
    _clearMessages();
    notifyListeners();
  }

  void updateProbabilidad(double value) {
    _probabilidad = value;
    _clearMessages();
    notifyListeners();
  }

  void updateClasificacion(String value) {
    _clasificacion = value;
    _clearMessages();
    notifyListeners();
  }

  void updateRecomendacion(String value) {
    _recomendacion = value;
    _clearMessages();
    notifyListeners();
  }

  // Limpiar mensajes
  void _clearMessages() {
    if (_errorMessage.isNotEmpty || _successMessage.isNotEmpty) {
      _errorMessage = '';
      _successMessage = '';
      notifyListeners();
    }
  }

  // Establecer error
  void setError(String message) {
    _errorMessage = message;
    _successMessage = '';
    notifyListeners();
  }

  // Establecer éxito
  void setSuccess(String message) {
    _successMessage = message;
    _errorMessage = '';
    notifyListeners();
  }

  // Guardar análisis
  Future<bool> guardarAnalisis() async {
    if (!isFormValid) {
      setError("Por favor, complete todos los campos requeridos");
      return false;
    }

    if (_probabilidad < 0 || _probabilidad > 100) {
      setError("La probabilidad debe estar entre 0 y 100");
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    try {
      // Llamar al servicio para guardar el análisis
      final response = await HistorialService.guardarAnalisis(
        correo: _correo,
        riesgo: _riesgo,
        areaSospechosa: _areaSospechosa,
        probabilidad: _probabilidad,
        clasificacion: _clasificacion,
        recomendacion: _recomendacion,
      );

      _isLoading = false;
      notifyListeners();

      if (response['success'] == true) {
        final numAnalisis = response['data']['num_analisis'];
        setSuccess("Análisis guardado exitosamente ($numAnalisis)");

        // Opcional: Imprimir confirmación en consola
        HistorialService.printConfirmacionGuardado(response);

        return true;
      } else {
        setError("Error al guardar análisis: ${response['error']}");
        return false;
      }
    } catch (e) {
      _isLoading = false;
      setError("Error en el proceso: $e");
      notifyListeners();
      return false;
    }
  }

  // Cargar datos de usuario (para prellenar el correo)
  void cargarDatosUsuario(String usuarioCorreo) {
    _correo = usuarioCorreo;
    notifyListeners();
  }

  // Prellenar datos de ejemplo (para testing)
  void prellenarDatosEjemplo() {
    _riesgo = 'Moderado';
    _areaSospechosa = 'Mama derecha, cuadrante superior externo';
    _probabilidad = 65.5;
    _clasificacion = 'BI-RADS 3';
    _recomendacion = 'Control en 6 meses recomendado';
    notifyListeners();
  }

  // Reiniciar el formulario
  void resetForm() {
    _riesgo = '';
    _areaSospechosa = '';
    _probabilidad = 0.0;
    _clasificacion = '';
    _recomendacion = '';
    _errorMessage = '';
    _successMessage = '';
    _isLoading = false;
    notifyListeners();
  }

  // Reiniciar completamente (incluyendo correo)
  void resetCompleto() {
    _correo = '';
    resetForm();
  }

  // Método para obtener resumen del análisis (opcional)
  Map<String, dynamic> getResumenAnalisis() {
    return {
      'correo': _correo,
      'riesgo': _riesgo,
      'areaSospechosa': _areaSospechosa,
      'probabilidad': _probabilidad,
      'clasificacion': _clasificacion,
      'recomendacion': _recomendacion,
      'fecha': DateTime.now().toString(),
    };
  }

  // Validar probabilidad
  String? validarProbabilidad(double value) {
    if (value <= 0) {
      return "La probabilidad debe ser mayor a 0";
    }
    if (value > 100) {
      return "La probabilidad no puede ser mayor a 100";
    }
    return null;
  }
}
