import 'package:flutter/material.dart';

class AnalisisHistorial {
  final String numAnalisis;
  final String riesgo;
  final String riesgoTexto;
  final String area;
  final String probabilidad;
  final String clasificacion;
  final String recomendacion;
  final String fecha;
  final String estado;
  final String correo;

  AnalisisHistorial({
    required this.numAnalisis,
    required this.riesgo,
    required this.riesgoTexto,
    required this.area,
    required this.probabilidad,
    required this.clasificacion,
    required this.recomendacion,
    required this.fecha,
    required this.estado,
    required this.correo,
  });

  factory AnalisisHistorial.fromJson(Map<String, dynamic> json) {
    return AnalisisHistorial(
      numAnalisis: json['numAnalisis'],
      riesgo: json['riesgo'],
      riesgoTexto: json['riesgoTexto'],
      area: json['area'],
      probabilidad: json['probabilidad'],
      clasificacion: json['clasificacion'],
      recomendacion: json['recomendacion'],
      fecha: json['fecha'],
      estado: json['estado'],
      correo: json['correo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numAnalisis': numAnalisis,
      'riesgo': riesgo,
      'riesgoTexto': riesgoTexto,
      'area': area,
      'probabilidad': probabilidad,
      'clasificacion': clasificacion,
      'recomendacion': recomendacion,
      'fecha': fecha,
      'estado': estado,
      'correo': correo,
    };
  }

  // ✅ MÉTODO PARA OBTENER DETALLES COMPLETOS
  Map<String, String> getDetallesCompletos() {
    return {
      'Número de Análisis': numAnalisis,
      'Fecha': fecha,
      'Nivel de Riesgo': riesgo,
      'Descripción del Riesgo': riesgoTexto,
      'Área Evaluada': area,
      'Probabilidad': probabilidad,
      'Clasificación PIRADS': clasificacion,
      'Recomendación': recomendacion,
      'Estado': estado,
      'Correo Asociado': correo,
    };
  }

  // ✅ MÉTODO PARA OBTENER COLOR SEGÚN RIESGO
  Color getColorRiesgo() {
    if (riesgo.contains('Alto')) {
      return Colors.red;
    } else if (riesgo.contains('Moderado')) {
      return Colors.orange;
    } else if (riesgo.contains('Bajo')) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  // ✅ MÉTODO PARA OBTENER ICONO SEGÚN RIESGO
  IconData getIconoRiesgo() {
    if (riesgo.contains('Alto')) {
      return Icons.warning;
    } else if (riesgo.contains('Moderado')) {
      return Icons.info;
    } else if (riesgo.contains('Bajo')) {
      return Icons.check_circle;
    } else {
      return Icons.help;
    }
  }

  // ✅ MÉTODO PARA OBTENER DESCRIPCIÓN DEL COLOR (opcional)
  String getDescripcionColor() {
    if (riesgo.contains('Alto')) {
      return 'Rojo - Riesgo Alto';
    } else if (riesgo.contains('Moderado')) {
      return 'Naranja - Riesgo Moderado';
    } else if (riesgo.contains('Bajo')) {
      return 'Verde - Riesgo Bajo';
    } else {
      return 'Gris - Riesgo No Especificado';
    }
  }

  // ✅ MÉTODO PARA VERIFICAR SI ES UN ANÁLISIS RECIENTE (opcional)
  bool esReciente() {
    try {
      final fechaAnalisis = DateTime.parse(fecha);
      final ahora = DateTime.now();
      final diferencia = ahora.difference(fechaAnalisis).inDays;
      return diferencia <= 30; // Considerar reciente si es menor a 30 días
    } catch (e) {
      return false;
    }
  }

  // ✅ MÉTODO PARA OBTENER PRIORIDAD (opcional - para ordenamiento)
  int getPrioridad() {
    if (riesgo.contains('Alto')) {
      return 1;
    } else if (riesgo.contains('Moderado')) {
      return 2;
    } else if (riesgo.contains('Bajo')) {
      return 3;
    } else {
      return 4;
    }
  }

  // ✅ MÉTODO PARA OBTENER RESUMEN RÁPIDO (opcional)
  String getResumen() {
    return '$numAnalisis - $riesgo - $fecha';
  }

  // ✅ MÉTODO PARA VERIFICAR SI REQUIERE ACCIÓN INMEDIATA
  bool requiereAccionInmediata() {
    return riesgo.contains('Alto') && estado != 'Completado';
  }

  // ✅ MÉTODO PARA OBTENER INSTRUCCIONES SEGÚN RIESGO
  String getInstrucciones() {
    if (riesgo.contains('Alto')) {
      return 'Consulta médica urgente recomendada';
    } else if (riesgo.contains('Moderado')) {
      return 'Seguimiento médico programado necesario';
    } else if (riesgo.contains('Bajo')) {
      return 'Controles periódicos según indicación médica';
    } else {
      return 'Esperar indicaciones del especialista';
    }
  }
}
