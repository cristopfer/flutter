import 'package:flutter/material.dart';
import '/models/historial_model.dart';

class DetalleHistorial extends StatelessWidget {
  final AnalisisHistorial analisis;

  const DetalleHistorial({super.key, required this.analisis});

  @override
  Widget build(BuildContext context) {
    final detalles = analisis.getDetallesCompletos();
    final colorRiesgo = analisis.getColorRiesgo();
    final iconoRiesgo = analisis.getIconoRiesgo();

    return Scaffold(
      backgroundColor: const Color(0xFFDDE5E0),
      body: SafeArea(
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.9,
            heightFactor: 0.9,
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
              child: Column(
                children: [
                  // Header con icono de riesgo
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: colorRiesgo.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          iconoRiesgo,
                          color: colorRiesgo,
                          size: 50,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          analisis.numAnalisis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          analisis.riesgo,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorRiesgo,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Información principal
                            _buildInfoCard(
                              'Descripción',
                              analisis.riesgoTexto,
                              Icons.description,
                            ),
                            const SizedBox(height: 5),

                            // Detalles en cards
                            _buildDetailCard('Área Evaluada', analisis.area,
                                Icons.location_on),
                            const SizedBox(height: 10),

                            _buildDetailCard('Probabilidad',
                                analisis.probabilidad, Icons.analytics),
                            const SizedBox(height: 10),

                            _buildDetailCard('Clasificación PIRADS',
                                analisis.clasificacion, Icons.assessment),
                            const SizedBox(height: 10),

                            _buildDetailCard('Fecha del Análisis',
                                analisis.fecha, Icons.calendar_today),
                            const SizedBox(height: 10),

                            // ✅ CORREGIDO: Cambiar Icons.status por Icons.info_outline o Icons.circle
                            _buildDetailCard(
                                'Estado', analisis.estado, Icons.info_outline),
                            const SizedBox(height: 15),

                            // Recomendación
                            _buildRecomendacionCard(analisis.recomendacion),
                            const SizedBox(height: 20),

                            // Botón Volver
                            _buildVolverButton(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String titulo, String contenido, IconData icono) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              contenido,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
                height: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String titulo, String valor, IconData icono) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icono, color: Colors.grey[600], size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecomendacionCard(String recomendacion) {
    return Card(
      elevation: 3,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.medical_services, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Recomendación Médica',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              recomendacion,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolverButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF3498DB),
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF3498DB), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Volver al Historial',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
