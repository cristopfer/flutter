class Usuario {
  final String nombre;
  final String correo;
  final String password;
  final int estado;

  Usuario({
    required this.nombre,
    required this.correo,
    required this.password,
    required this.estado,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nombre: json['nombre'],
      correo: json['correo'],
      password: json['password'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'correo': correo,
      'password': password,
      'estado': estado,
    };
  }
}
