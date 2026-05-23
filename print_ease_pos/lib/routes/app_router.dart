import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../shared/layouts/app_shell.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/printer/presentation/screens/printer_screen.dart';
import '../features/receipts/presentation/screens/receipts_screen.dart';
import '../features/receipts/presentation/screens/receipt_detail_screen.dart';
import '../features/receipts/presentation/screens/create_receipt_screen.dart';
import '../features/templates/presentation/screens/templates_screen.dart';
import '../features/templates/presentation/screens/template_designer_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/backup_restore_screen.dart';
import '../features/pdf_export/presentation/screens/pdf_export_screen.dart';
import '../features/pdf_export/presentation/screens/pdf_preview_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.dashboard,
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          pageBuilder: (context, state) => _noTransitionPage(
            context,
            state,
            const DashboardScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.printer,
          pageBuilder: (context, state) => _noTransitionPage(
            context,
            state,
            const PrinterScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.receipts,
          pageBuilder: (context, state) => _noTransitionPage(
            context,
            state,
            const ReceiptsScreen(),
          ),
          routes: [
            GoRoute(
              path: 'create',
              pageBuilder: (context, state) => _noTransitionPage(
                context,
                state,
                const CreateReceiptScreen(),
              ),
            ),
            GoRoute(
              path: ':id',
              pageBuilder: (context, state) => _noTransitionPage(
                context,
                state,
                ReceiptDetailScreen(
                  receiptId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ),
            GoRoute(
              path: ':id/edit',
              pageBuilder: (context, state) => _noTransitionPage(
                context,
                state,
                CreateReceiptScreen(
                  editReceiptId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.templates,
          pageBuilder: (context, state) => _noTransitionPage(
            context,
            state,
            const TemplatesScreen(),
          ),
          routes: [
            GoRoute(
              path: 'create',
              pageBuilder: (context, state) => _noTransitionPage(
                context,
                state,
                const TemplateDesignerScreen(),
              ),
            ),
            GoRoute(
              path: ':id',
              pageBuilder: (context, state) => _noTransitionPage(
                context,
                state,
                TemplateDesignerScreen(
                  templateId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) => _noTransitionPage(
            context,
            state,
            const SettingsScreen(),
          ),
          routes: [
            GoRoute(
              path: 'backup',
              pageBuilder: (context, state) => _noTransitionPage(
                context,
                state,
                const BackupRestoreScreen(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.pdfExport,
          pageBuilder: (context, state) => _noTransitionPage(
            context,
            state,
            const PdfExportScreen(),
          ),
          routes: [
            GoRoute(
              path: ':id',
              pageBuilder: (context, state) => _noTransitionPage(
                context,
                state,
                PdfPreviewScreen(
                  documentId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

Page<void> _noTransitionPage(BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
  );
}
