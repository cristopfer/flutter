import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/models/user_model.dart';

class UserService {
  static List<Usuario> _usuarios = [];
  static const String _usersKey = 'app_users';

  static const String _baseUrl = 'https://movil001.onrender.com/api';

  // 🔥 HEADERS CORREGIDOS - AGREGAR ngrok-skip-browser-warning
  static Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      'User-Agent': 'FlutterApp/1.0',
    };
  }

  // Inicializar el servicio
  static Future<void> initialize() async {
    await _loadUsers();
  }

  // Cargar usuarios desde SharedPreferences o assets
  static Future<void> _loadUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? usersJson = prefs.getString(_usersKey);

      if (usersJson != null && usersJson.isNotEmpty) {
        // Leer desde SharedPreferences
        final jsonMap = jsonDecode(usersJson);
        _usuarios = (jsonMap['usuarios'] as List)
            .map((userJson) => Usuario.fromJson(userJson))
            .toList();
        print(
            '✅ Usuarios cargados desde SharedPreferences: ${_usuarios.length}');
      } else {
        // Cargar desde assets por primera vez
        await _loadFromAssets();
        await _saveUsers(); // Guardar en SharedPreferences
      }
    } catch (e) {
      print('❌ Error cargando usuarios: $e');
      await _loadFromAssets(); // Fallback a assets
    }
  }

  // Cargar usuarios iniciales desde assets
  static Future<void> _loadFromAssets() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/users.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      _usuarios = (jsonMap['usuarios'] as List)
          .map((userJson) => Usuario.fromJson(userJson))
          .toList();
      print('✅ Usuarios cargados desde assets: ${_usuarios.length}');
    } catch (e) {
      print('❌ Error cargando desde assets: $e');
      _usuarios = [];
    }
  }

  // Guardar usuarios en SharedPreferences
  static Future<void> _saveUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonMap = {
        'usuarios': _usuarios.map((user) => user.toJson()).toList()
      };
      await prefs.setString(_usersKey, jsonEncode(jsonMap));
      print('✅ Usuarios guardados en SharedPreferences: ${_usuarios.length}');
    } catch (e) {
      print('❌ Error guardando usuarios: $e');
    }
  }

  // Validar usuario via API REST
  static Future<Map<String, dynamic>?> validateUser(
      String email, String password) async {
    try {
      print('🔐 Intentando login via API para: $email');
      print('🌐 URL: $_baseUrl/login');
      print('🔑 Headers: $_headers'); // ← DEBUG HEADERS

      final response = await http
          .post(
            Uri.parse('$_baseUrl/login'),
            headers: _headers, // ← USAR HEADERS CORREGIDOS
            body: jsonEncode({
              'correo': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          print('✅ Login exitoso via API');
          return {
            'success': true,
            'user': Usuario(
              nombre: email.split('@').first, // Nombre temporal del email
              correo: email,
              password: password,
              estado: responseData['estado'],
            ),
            'message': responseData['mensaje_estado'],
            'estado': responseData['estado'],
          };
        } else {
          print('❌ Error en login via API: ${responseData['error']}');
          return {
            'success': false,
            'error': responseData['error'] ?? 'Error desconocido',
          };
        }
      } else {
        print('❌ Error HTTP: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Error de conexión: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error en validateUser: $e');
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // Agregar nuevo usuario
  static Future<Map<String, dynamic>?> addUser(Usuario newUser) async {
    try {
      print('📝 Intentando registrar usuario via API: ${newUser.correo}');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/register'),
            headers: _headers, // ← USAR HEADERS CORREGIDOS
            body: jsonEncode({
              'nombre': newUser.nombre,
              'correo': newUser.correo,
              'password': newUser.password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          print('✅ Usuario registrado exitosamente via API: ${newUser.nombre}');

          // También agregar localmente para consistencia
          _usuarios.add(newUser);
          await _saveUsers();

          return {
            'success': true,
            'message': responseData['message'],
            'user': newUser,
          };
        } else {
          print('❌ Error en registro via API: ${responseData['error']}');
          return {
            'success': false,
            'error': responseData['error'] ?? 'Error desconocido',
          };
        }
      } else {
        // Manejar otros códigos de estado
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        print('❌ Error HTTP: ${response.statusCode} - ${errorData['error']}');
        return {
          'success': false,
          'error':
              errorData['error'] ?? 'Error de conexión: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error en addUser: $e');
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  static Future<Map<String, dynamic>?> updateUserStatus(
      String email, String password, int newStatus) async {
    try {
      // 🔥 Solo permitir actualización a estado 1 (activo) via API
      if (newStatus != 1) {
        print('❌ Solo se permite actualizar a estado 1 (activo) via API');
        return {
          'success': false,
          'error': 'Solo se permite activar la cuenta via API',
        };
      }

      print('🔐 Actualizando estado para: $email');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/accept-terms'),
            headers: _headers, // ← USAR HEADERS CORREGIDOS
            body: jsonEncode({
              'correo': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          print('✅ Estado actualizado exitosamente via API para: $email');

          // 🔥 ACTUALIZAR TAMBIÉN LOCALMENTE
          final userIndex =
              _usuarios.indexWhere((user) => user.correo == email);
          if (userIndex != -1) {
            final updatedUser = Usuario(
              nombre: _usuarios[userIndex].nombre,
              correo: _usuarios[userIndex].correo,
              password: _usuarios[userIndex].password,
              estado: newStatus,
            );
            _usuarios[userIndex] = updatedUser;
            await _saveUsers();
          }

          return {
            'success': true,
            'message': responseData['message'],
            'user': Usuario(
              nombre: email.split('@').first, // Nombre temporal
              correo: email,
              password: password,
              estado: newStatus,
            ),
          };
        } else {
          print(
              '❌ Error actualizando estado via API: ${responseData['error']}');
          return {
            'success': false,
            'error': responseData['error'] ?? 'Error desconocido',
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
      print('❌ Error en updateUserStatus: $e');
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  static void printAllUsers() {
    print('📋 USUARIOS REGISTRADOS:');
    for (var i = 0; i < _usuarios.length; i++) {
      final user = _usuarios[i];
      print(
          '${i + 1}. ${user.nombre} - ${user.correo} - ${user.password} - Estado: ${user.estado}');
    }
  }

  static Usuario? getUserByEmail(String email) {
    try {
      return _usuarios.firstWhere((user) => user.correo == email);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateUserPassword(
      String email, String newPassword) async {
    try {
      print('🔄 UserService.updateUserPassword - Buscando usuario: $email');
      // Buscar el usuario por email
      final userIndex = _usuarios.indexWhere((user) => user.correo == email);

      if (userIndex != -1) {
        print('✅ Usuario encontrado en índice: $userIndex');
        // Crear un nuevo usuario con la contraseña actualizada
        final updatedUser = Usuario(
          nombre: _usuarios[userIndex].nombre,
          correo: _usuarios[userIndex].correo,
          password: newPassword, // Nueva contraseña
          estado: _usuarios[userIndex].estado,
        );
        // Reemplazar el usuario en la lista
        _usuarios[userIndex] = updatedUser;
        // Guardar en SharedPreferences
        await _saveUsers();

        print('✅ Contraseña actualizada exitosamente para: $email');
        print('📋 Lista actualizada de usuarios:');
        printAllUsers(); // Esto mostrará todos los usuarios en consola
        return true;
      } else {
        print('❌ Usuario no encontrado: $email');
        print('📋 Usuarios disponibles:');
        printAllUsers();
        return false;
      }
    } catch (e) {
      print('❌ Error actualizando contraseña: $e');
      return false;
    }
  }

  static Future<void> clearAllSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _usuarios.clear();
    print('✅ SharedPreferences - TODOS los datos borrados');
  }

  static List<Usuario> get usuarios => _usuarios;
  static bool get hasUsers => _usuarios.isNotEmpty;
}
