import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Franja superior con el resumen de las calificaciones cargadas:
/// cuántas hay y cuál es el promedio general (con color según si el
/// promedio aprueba o no). Es el "toque diferente" que no tiene la
/// referencia: da contexto de un vistazo antes de leer la lista.
class SummaryHeader extends StatelessWidget {
  final int count;
  final double average;

  const SummaryHeader({super.key, required this.count, required this.average});

  @override
  Widget build(BuildContext context) {
    final isPassing = average >= 3.0;
    final color = count == 0 ? AppColors.primary : (isPassing ? AppColors.success : AppColors.accent);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count ${count == 1 ? 'calificación registrada' : 'calificaciones registradas'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Promedio general',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              count == 0 ? '--' : average.toStringAsFixed(1),
              style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
