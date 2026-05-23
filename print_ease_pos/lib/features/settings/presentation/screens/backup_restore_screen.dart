import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/backup_provider.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(backupProvider, (prev, next) {
      if (next.message != null && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message!),
            backgroundColor: next.isError ? Colors.red : Colors.green,
          ),
        );
        if (!next.isError) {
          ref.read(backupProvider.notifier).clearMessage();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(backupProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Icon(
              Icons.backup_rounded,
              size: 80,
              color: theme.colorScheme.primary.withAlpha(77),
            ),
            const SizedBox(height: 16),
            Text(
              'Protect your data',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Backup your settings, templates, and receipts. Restore them anytime.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(flex: 2),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: state.isLoading
                    ? null
                    : () => ref.read(backupProvider.notifier).exportBackup(),
                icon: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.file_upload_outlined),
                label: Text(state.isLoading ? 'Exporting...' : 'Export Backup'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: state.isLoading
                    ? null
                    : () => ref.read(backupProvider.notifier).importBackup(),
                icon: const Icon(Icons.file_download_outlined),
                label: const Text('Restore from Backup'),
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
