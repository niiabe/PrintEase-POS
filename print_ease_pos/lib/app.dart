import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/notification_service.dart';
import 'core/services/permission_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/controllers/settings_provider.dart';
import 'features/templates/data/models/receipt_template.dart';
import 'features/templates/presentation/controllers/template_provider.dart';
import 'routes/app_router.dart';

class PrintEaseApp extends ConsumerStatefulWidget {
  const PrintEaseApp({super.key});

  @override
  ConsumerState<PrintEaseApp> createState() => _PrintEaseAppState();
}

class _PrintEaseAppState extends ConsumerState<PrintEaseApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        await NotificationService().initialize();
        await ref.read(settingsProvider.notifier).loadSettings();
        await _seedDefaultTemplates();
        await _requestPermissions();
      } catch (e) {
        debugPrint('App init error: $e');
      }
    });
  }

  Future<void> _requestPermissions() async {
    final service = PermissionService();
    await service.requestAllAppPermissions();
  }

  Future<void> _seedDefaultTemplates() async {
    final repo = ref.read(templateRepositoryProvider);
    final existing = await repo.getTemplates();
    if (existing.isNotEmpty) return;

    for (final name in ReceiptTemplate.presetNames) {
      await repo.saveTemplate(
        ReceiptTemplate(
          name: name,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'PrintEase POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
