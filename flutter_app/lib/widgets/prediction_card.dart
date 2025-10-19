// lib/widgets/prediction_card.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Widget corregido para mostrar una predicción.
/// Evita dependencias implícitas en objetos que no estaban definidos.
/// Ahora recibe los valores necesarios explícitamente.
class PredictionCard extends StatelessWidget {
  final int index;
  final String className;
  final int classId;
  final double confidencePercent;
  final Color color;
  final bool success;

  const PredictionCard({
    Key? key,
    required this.index,
    required this.className,
    required this.classId,
    required this.confidencePercent,
    required this.color,
    this.success = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.cardElevation,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.defaultRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? AppColors.success : AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Predicción #${index + 1}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Información de la predicción
            Text(
              className,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ID: $classId',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 12),

            // Row con confianza y chip de color
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${confidencePercent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ),
                // Indicador pequeño del color
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
