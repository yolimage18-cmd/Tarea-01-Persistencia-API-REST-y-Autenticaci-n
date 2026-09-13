import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/calificacion.dart';
import '../providers/calificaciones_provider.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';

class CalificacionEditorScreen extends StatefulWidget {
  final Calificacion? item;
  const CalificacionEditorScreen({super.key, this.item});

  @override
  State<CalificacionEditorScreen> createState() => _CalificacionEditorScreenState();
}

class _CalificacionEditorScreenState extends State<CalificacionEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _subjectCtrl;
  late final TextEditingController _gradeCtrl;
  late final TextEditingController _commentCtrl;
  bool _saving = false;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item?.studentName ?? '');
    _subjectCtrl = TextEditingController(text: widget.item?.subject ?? '');
    _gradeCtrl = TextEditingController(text: widget.item?.grade.toStringAsFixed(1) ?? '');
    _commentCtrl = TextEditingController(text: widget.item?.comment ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _subjectCtrl.dispose();
    _gradeCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final provider = context.read<CalificacionesProvider>();
    final grade = double.parse(_gradeCtrl.text.trim().replaceAll(',', '.'));

    if (_isEditing) {
      await provider.update(
        widget.item!,
        studentName: _nameCtrl.text,
        subject: _subjectCtrl.text,
        grade: grade,
        comment: _commentCtrl.text,
      );
    } else {
      await provider.create(
        studentName: _nameCtrl.text,
        subject: _subjectCtrl.text,
        grade: grade,
        comment: _commentCtrl.text,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Eliminar calificación'),
        content: const Text('¿Seguro que deseas eliminar este registro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<CalificacionesProvider>().delete(widget.item!);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar calificación' : 'Registrar calificación'),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accent),
              tooltip: 'Eliminar',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _nameCtrl,
                  label: 'Nombre del estudiante',
                  icon: Icons.person_outline_rounded,
                  validator: Validators.studentName,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _subjectCtrl,
                  label: 'Asignatura',
                  icon: Icons.menu_book_outlined,
                  validator: Validators.subject,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _gradeCtrl,
                  label: 'Calificación (0.0 a 5.0)',
                  icon: Icons.grade_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    // Solo permite dígitos, punto y coma mientras se escribe;
                    // el rango 0.0-5.0 se valida al guardar (Validators.grade).
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  validator: Validators.grade,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _commentCtrl,
                  label: 'Comentario (opcional)',
                  icon: Icons.chat_bubble_outline_rounded,
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Icon(Icons.save_rounded),
                  label: const Text('Guardar calificación'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
