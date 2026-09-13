import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calificacion.dart';
import '../theme/app_theme.dart';

/// Tarjeta de calificación: avatar con iniciales del estudiante, nombre y
/// asignatura, una insignia de color con la nota (verde si aprueba, coral
/// si no), comentario y estado de sincronización.
class CalificacionCard extends StatelessWidget {
  final Calificacion item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CalificacionCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  String get _initials {
    final parts = item.studentName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // El color se calcula a partir del nombre del estudiante, así el
    // mismo estudiante siempre se ve con el mismo color en toda la lista.
    final accent = AppColors.accentFor(item.studentName.trim().toLowerCase());
    final gradeColor = item.isPassing ? AppColors.success : AppColors.accent;
    final dateLabel = DateFormat('d MMM, h:mm a', 'es').format(item.updatedAt);

    return Dismissible(
      key: ValueKey(item.localId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 7),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: accent.withOpacity(0.16),
                      child: Text(
                        _initials,
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.studentName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.menu_book_rounded, size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.subject,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: gradeColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        item.grade.toStringAsFixed(1),
                        style: TextStyle(
                          color: gradeColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.comment.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    item.comment,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Fecha: $dateLabel',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    const Spacer(),
                    Icon(
                      item.isSynced ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                      size: 17,
                      color: item.isSynced ? AppColors.success : AppColors.textMuted,
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(Icons.delete_outline_rounded, size: 19, color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
