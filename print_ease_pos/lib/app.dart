import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/controllers/settings_provider.dart';
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
    Future.microtask(() {
      ref.read(settingsProvider.notifier).loadSettings();
    });
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
