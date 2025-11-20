import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/historial_model.dart';

class HistorialService {
  static const String _baseUrl = 'https://movil001.onrender.com/api';

  // 🔥 HEADERS CONSISTENTES con UserService
  static Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      'User-Agent': 'FlutterApp/1.0',
    };
  }

  // ✅ MÉTODO PARA GUARDAR ANÁLISIS
  static Future<Map<String, dynamic>> guardarAnalisis({
    required String correo,
    required String riesgo,
    required String areaSospechosa,
    required double probabilidad,
    required String clasificacion,
    required String recomendacion,
  }) async {
    try {
      print('📝 Intentando guardar análisis para: $correo');
      print('🌐 URL: $_baseUrl/guardar_analisis');

      final Map<String, dynamic> requestBody = {
        'correo': correo,
        'riesgo': riesgo,
        'area_sospechosa': areaSospechosa,
        'probabilidad': probabilidad,
        'clasificacion': clasificacion,
        'recomendacion': recomendacion,
      };

      print('📤 Request body: $requestBody');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/guardar_analisis'),
            headers: _headers,
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          print('✅ Análisis guardado exitosamente');

          return {
            'success': true,
            'message': responseData['message'],
            'data': {
              'num_analisis': responseData['data']['num_analisis'],
              'id_historial': responseData['data']['id_historial'],
            },
          };
        } else {
          print('❌ Error guardando análisis: ${responseData['error']}');
          return {
            'success': false,
            'error': responseData['error'] ??
                'Error desconocido al guardar análisis',
          };
        }
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        print('❌ Error HTTP: ${response.statusCode} - ${errorData['error']}');
        return {
          'success': false,
          'error':
              errorData['error'] ?? 'Error de conexión: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error en guardarAnalisis: $e');
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // ✅ MÉTODO - OBTENER HISTORIAL DE USUARIO (SIMPLIFICADO)
  static Future<Map<String, dynamic>> obtenerHistorialUsuario(
      String correo) async {
    try {
      print('📋 Intentando obtener historial para: $correo');
      print('🌐 URL: $_baseUrl/historial_usuario');

      final Map<String, dynamic> requestBody = {
        'correo': correo,
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/historial_usuario'),
            headers: _headers,
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          print('✅ Historial obtenido exitosamente');

          // ✅ SIMPLIFICADO: Sin _obtenerRiesgoTexto
          List<AnalisisHistorial> historial = [];
          if (responseData['data'] != null) {
            for (var item in responseData['data']) {
              final mappedItem = {
                'numAnalisis': item['num_analisis'] ?? 'N/A',
                'riesgo': item['riesgo'] ?? 'No especificado',
                'riesgoTexto': '', // Dejamos vacío o el modelo lo maneja
                'area': item['area_sospechosa'] ?? 'No especificada',
                'probabilidad': '${item['probabilidad'] ?? 0}%',
                'clasificacion': item['clasificacion'] ?? 'No especificada',
                'recomendacion': item['recomendacion'] ?? 'Sin recomendación',
                'fecha': item['fecha'] ??
                    DateTime.now().toIso8601String().split('T')[0],
                'estado': 'Completado',
                'correo': correo,
              };

              historial.add(AnalisisHistorial.fromJson(mappedItem));
            }
          }

          return {
            'success': true,
            'message': responseData['message'],
            'data': historial,
            'count': historial.length,
          };
        } else {
          print('❌ Error obteniendo historial: ${responseData['error']}');
          return {
            'success': false,
            'error': responseData['error'] ??
                'Error desconocido al obtener historial',
          };
        }
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        print('❌ Error HTTP: ${response.statusCode} - ${errorData['error']}');
        return {
          'success': false,
          'error':
              errorData['error'] ?? 'Error de conexión: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error en obtenerHistorialUsuario: $e');
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // ✅ MÉTODO OPCIONAL - Solo para debug
  static void printConfirmacionGuardado(Map<String, dynamic> resultado) {
    if (resultado['success'] == true) {
      final data = resultado['data'];
      print('🎉 ANÁLISIS GUARDADO EXITOSAMENTE');
      print('   Número: ${data['num_analisis']}');
      print('   ID: ${data['id_historial']}');
      print('   Mensaje: ${resultado['message']}');
    } else {
      print('❌ ERROR AL GUARDAR ANÁLISIS');
      print('   Error: ${resultado['error']}');
    }
  }

  // ✅ MÉTODO OPCIONAL - Imprimir historial obtenido
  static void printHistorialObtenido(Map<String, dynamic> resultado) {
    if (resultado['success'] == true) {
      final historial = resultado['data'] as List<AnalisisHistorial>;
      print('📋 HISTORIAL OBTENIDO EXITOSAMENTE');
      print('   Cantidad: ${historial.length} análisis');
      for (var analisis in historial) {
        print(
            '   📄 ${analisis.numAnalisis} - ${analisis.riesgo} - ${analisis.fecha}');
      }
    } else {
      print('❌ ERROR AL OBTENER HISTORIAL');
      print('   Error: ${resultado['error']}');
    }
  }
}
