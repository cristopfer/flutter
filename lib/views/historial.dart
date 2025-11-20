import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/viewmodels/historial_viewmodel.dart';
import '/models/historial_model.dart';
import '/models/user_model.dart';
import 'detalle_historial.dart';

class Historial extends StatelessWidget {
  final Usuario? usuario;
  const Historial({super.key, this.usuario});

  @override
  Widget build(BuildContext context) {
    print('📋 Historial - Usuario recibido: ${usuario?.correo}');

    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = HistorialViewModel();
        if (usuario != null) {
          viewModel.setUsuario(usuario);
        }
        return viewModel;
      },
      child: _HistorialScaffold(),
    );
  }
}

class _HistorialScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE5E0),
      body: SafeArea(
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.9,
            heightFactor: 0.85,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Consumer<HistorialViewModel>(
                builder: (context, viewModel, _) {
                  return _HistorialContent(viewModel: viewModel);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistorialContent extends StatelessWidget {
  final HistorialViewModel viewModel;

  const _HistorialContent({required this.viewModel});

  // ✅ MÉTODO CORREGIDO - AHORA RECIBE CONTEXT COMO PARÁMETRO
  Widget _buildSmallButton(BuildContext context, AnalisisHistorial item) {
    return ElevatedButton(
      onPressed: () {
        // ✅ NAVEGAR A LA PANTALLA DE DETALLE
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalleHistorial(analisis: item),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF27AE60),
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF27AE60), width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
      child: const Text(
        "Ver",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ✅ MÉTODO PARA BOTONES GRANDES (Volver)
  Widget _buildLargeButton(
      BuildContext context, String texto, String value, VoidCallback onTap) {
    final bool isSelected = viewModel.selectedButton == value;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          viewModel.setSelectedButton(value);
          onTap();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3498DB),
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF3498DB), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          minimumSize: const Size(double.infinity, 55),
        ),
        child: Text(
          texto,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHistorialItem(
      BuildContext context, AnalisisHistorial item, int index) {
    Color iconColor;
    IconData iconData;

    if (item.riesgo.contains('Alto')) {
      iconColor = Colors.red;
      iconData = Icons.warning;
    } else if (item.riesgo.contains('Moderado')) {
      iconColor = Colors.orange;
      iconData = Icons.info;
    } else if (item.riesgo.contains('Bajo')) {
      iconColor = Colors.green;
      iconData = Icons.check_circle;
    } else {
      iconColor = Colors.grey;
      iconData = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),

          const SizedBox(width: 10),

          // Texto del análisis
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.numAnalisis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  item.fecha,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Riesgo: ${item.riesgo}',
                  style: TextStyle(
                    fontSize: 12,
                    color: iconColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ✅ BOTÓN "VER" PEQUEÑO
          _buildSmallButton(context, item),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 10),
          Text('Cargando historial...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 10),
          Text(
            'Error: ${viewModel.errorMessage}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: viewModel.recargarHistorial,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, color: Colors.grey, size: 50),
          const SizedBox(height: 10),
          const Text(
            'No hay análisis en tu historial',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (viewModel.isLoading) {
      return _buildLoadingState();
    }

    if (viewModel.errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (!viewModel.tieneHistorial) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Todos tus análisis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),

          // ✅ LISTA COMPLETA DE ANÁLISIS
          Column(
            children: viewModel.historial
                .map((item) => _buildHistorialItem(
                    context, item, viewModel.historial.indexOf(item)))
                .toList(),
          ),

          const SizedBox(height: 20),

          // ✅ BOTÓN "VOLVER"
          _buildLargeButton(context, "Volver", "volver", () {
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF4A90E2),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const Center(
            child: Text(
              'Historial',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildContent(context),
          ),
        ),
      ],
    );
  }
}
