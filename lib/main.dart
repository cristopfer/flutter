import 'package:flutter/material.dart';
import 'views/presentacion.dart';
import 'services/user_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    UserService.initialize();
    return MaterialApp(
      title: 'Presentacion App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Presentacion(),
      debugShowCheckedModeBanner: false,
    );
  }
}
