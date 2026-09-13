import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calificacion.dart';
import '../providers/auth_provider.dart';
import '../providers/calificaciones_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/calificacion_card.dart';
import '../widgets/offline_banner.dart';
import '../widgets/summary_header.dart';
import 'calificacion_editor_screen.dart';
import 'login_screen.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalificacionesProvider>().loadInitial();
    });
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openEditor({Calificacion? item}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CalificacionEditorScreen(item: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalificacionesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de calificaciones'),
        actions: [
          IconButton(
            tooltip: 'Sincronizar ahora',
            icon: Icon(
              provider.isOnline ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
              color: provider.isOnline ? AppColors.success : AppColors.warning,
            ),
            onPressed: () => context.read<CalificacionesProvider>().syncNow(),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!provider.isOnline) const OfflineBanner(),
          if (provider.isOnline && provider.isSyncing) const SyncingBanner(),
          if (!provider.isLoading) SummaryHeader(count: provider.items.length, average: provider.average),
          const SizedBox(height: 4),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.items.isEmpty
                    ? _EmptyState(onCreate: () => _openEditor())
                    : RefreshIndicator(
                        onRefresh: () => context.read<CalificacionesProvider>().syncNow(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                          itemCount: provider.items.length,
                          itemBuilder: (context, index) {
                            final item = provider.items[index];
                            return CalificacionCard(
                              item: item,
                              onTap: () => _openEditor(item: item),
                              onDelete: () => context.read<CalificacionesProvider>().delete(item),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Agregar calificación'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.grade_rounded, size: 42, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text('Aún no tienes calificaciones', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Registra la nota de un estudiante. Funciona incluso sin conexión.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar calificación'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(240, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
