// services/modeloIA_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io'; // ← AÑADE ESTE IMPORT
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart'; // ← AÑADE ESTE IMPORT

class AnalisisResult {
  final bool success;
  final String? message;
  final String? error;
  final AnalisisData? data;

  AnalisisResult({
    required this.success,
    this.message,
    this.error,
    this.data,
  });

  factory AnalisisResult.fromJson(Map<String, dynamic> json) {
    return AnalisisResult(
      success: json['success'] ?? false,
      message: json['message'],
      error: json['error'],
      data: json['data'] != null ? AnalisisData.fromJson(json['data']) : null,
    );
  }
}

class AnalisisData {
  final String riesgo;
  final String riesgoTexto;
  final String area;
  final String probabilidad;
  final String clasificacion;
  final String recomendacion;

  AnalisisData({
    required this.riesgo,
    required this.riesgoTexto,
    required this.area,
    required this.probabilidad,
    required this.clasificacion,
    required this.recomendacion,
  });

  factory AnalisisData.fromJson(Map<String, dynamic> json) {
    return AnalisisData(
      riesgo: json['riesgo'] ?? 'Desconocido',
      riesgoTexto: json['riesgoTexto'] ?? '',
      area: json['area'] ?? 'No especificada',
      probabilidad: json['probabilidad'] ?? '0%',
      clasificacion: json['clasificacion'] ?? 'No clasificado',
      recomendacion: json['recomendacion'] ?? '',
    );
  }
}

class ModeloIAService {
  static const String baseUrl = 'https://eysen001-eysen002.hf.space/api';
  static const Duration timeout = Duration(seconds: 180);

  // Método para analizar imagen desde bytes (compatible con Web)
  static Future<AnalisisResult> analizarImagenBytes(
      Uint8List imageBytes, String fileName) async {
    try {
      print('🖼️ Enviando imagen para análisis desde bytes...');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/analizar'),
      );

      // Crear multipart file desde bytes
      request.files.add(http.MultipartFile.fromBytes(
        'imagen',
        imageBytes,
        filename: fileName,
      ));

      var streamedResponse = await request.send().timeout(timeout);
      var response = await http.Response.fromStream(streamedResponse);

      print('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        return AnalisisResult.fromJson(jsonResponse);
      } else {
        Map<String, dynamic> errorResponse = json.decode(response.body);
        return AnalisisResult(
          success: false,
          error: errorResponse['error'] ??
              'Error del servidor: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      return AnalisisResult(
        success: false,
        error: 'Error: $e',
      );
    }
  }

  // Método original para compatibilidad con móvil
  static Future<AnalisisResult> analizarImagen(File imagenFile) async {
    try {
      print('🖼️ Enviando imagen para análisis desde archivo...');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/analizar'),
      );

      request.files.add(await http.MultipartFile.fromPath(
        'imagen',
        imagenFile.path,
        filename: 'imagen_analisis.jpg',
      ));

      var streamedResponse = await request.send().timeout(timeout);
      var response = await http.Response.fromStream(streamedResponse);

      print('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        return AnalisisResult.fromJson(jsonResponse);
      } else {
        Map<String, dynamic> errorResponse = json.decode(response.body);
        return AnalisisResult(
          success: false,
          error: errorResponse['error'] ??
              'Error del servidor: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      return AnalisisResult(
        success: false,
        error: 'Error: $e',
      );
    }
  }

  // Método universal que detecta automáticamente la plataforma
  static Future<AnalisisResult> analizarImagenUniversal(
      PlatformFile platformFile) async {
    if (platformFile.bytes != null) {
      // Web - usar bytes
      return await analizarImagenBytes(platformFile.bytes!, platformFile.name);
    } else if (platformFile.path != null) {
      // Móvil - usar path
      return await analizarImagen(File(platformFile.path!));
    } else {
      return AnalisisResult(
        success: false,
        error: 'No se pudo acceder al archivo',
      );
    }
  }
}
