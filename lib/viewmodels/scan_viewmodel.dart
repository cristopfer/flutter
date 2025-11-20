// viewmodels/scan_viewmodel.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/modeloIA_service.dart';

class ScanViewModel with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  AnalisisData? _resultadoAnalisis;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  AnalisisData? get resultadoAnalisis => _resultadoAnalisis;

  Future<void> analizarImagen(File imagenFile) async {
    _isLoading = true;
    _errorMessage = '';
    _resultadoAnalisis = null;
    notifyListeners();

    try {
      AnalisisResult resultado =
          await ModeloIAService.analizarImagen(imagenFile);

      if (resultado.success && resultado.data != null) {
        _resultadoAnalisis = resultado.data;
      } else {
        _errorMessage =
            resultado.error ?? 'Error desconocido al analizar la imagen';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void limpiarResultado() {
    _resultadoAnalisis = null;
    _errorMessage = '';
    notifyListeners();
  }
}
