import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../core/layout/main_layout.dart';
import '../core/network/auth_service.dart';
import '../features/pos/presentation/providers/pos_cart_bloc.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/pos/presentation/screens/pos_screen.dart';
import '../features/wallet/presentation/screens/wallet_screen.dart';
import '../features/queue/presentation/screens/queue_screen.dart';
import '../features/queue/presentation/screens/queue_monitor_screen.dart';
import '../features/booking/presentation/screens/booking_screen.dart';
import '../features/invoice/presentation/screens/invoice_screen.dart';
import '../features/qr/presentation/screens/qr_generator_screen.dart';
import '../features/staff/presentation/screens/staff_management_screen.dart';
import '../features/printer/presentation/screens/printer_settings_screen.dart';
import '../features/catalog/presentation/screens/catalog_screen.dart';
import '../features/inventory/presentation/screens/inventory_screen.dart';
import '../features/crm/presentation/screens/crm_screen.dart';
import '../features/reports/presentation/screens/report_screen.dart';
import '../features/reports/presentation/screens/chatbot_screen.dart';
import '../features/reports/presentation/screens/accounting_screen.dart';
import '../features/kitchen/presentation/screens/kds_screen.dart';
import '../features/hris/presentation/screens/hris_screen.dart';
import '../features/delivery/presentation/screens/delivery_screen.dart';
import '../features/marketing/presentation/screens/marketing_screen.dart';
import '../features/hq/presentation/screens/hq_dashboard_screen.dart';
import '../features/platform/presentation/screens/platform_admin_screen.dart';
import '../features/supply/presentation/screens/supply_chain_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/business_site/presentation/screens/onboarding_wizard_screen.dart';
import '../features/business_site/presentation/screens/public_site_screen.dart';
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  redirect: (context, state) {
    final isLoggedIn = AuthService.isLoggedIn;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation.startsWith('/b/');
    final isPublicRoute = state.matchedLocation.startsWith('/b/');

    if (!isLoggedIn && !isAuthRoute) return '/login';
    if (isLoggedIn && (state.matchedLocation == '/login' || state.matchedLocation == '/register')) return '/dashboard';
    return null;
  },
  routes: [
    // --- Public / Auth Routes ---
    GoRoute(
      path: '/login',
      name: 'login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OnboardingWizardScreen(),
    ),
    GoRoute(
      path: '/b/:slug',
      name: 'business_site',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        final tableNumber = state.uri.queryParameters['table'];
        return PublicSiteScreen(slug: slug, tableNumber: tableNumber);
      },
    ),

    // --- Admin Route (No MainLayout for now) ---
    GoRoute(
      path: '/admin',
      name: 'admin',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AdminDashboardScreen(),
    ),

    // --- Core Application Routes wrapped in MainLayout (ShellRoute) ---
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) => const DashboardScreen(),
          routes: [
            GoRoute(
              path: 'pos',
              name: 'pos',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => BlocProvider(
                create: (_) => PosCartBloc(),
                child: const PosScreen(),
              ),
            ),
            GoRoute(
              path: 'wallet',
              name: 'wallet',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const WalletScreen(),
            ),
            GoRoute(
              path: 'queue',
              name: 'queue',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const QueueScreen(),
              routes: [
                GoRoute(
                  path: 'monitor',
                  name: 'queue_monitor',
                  parentNavigatorKey: _shellNavigatorKey,
                  builder: (context, state) => const QueueMonitorScreen(),
                ),
              ],
            ),
            GoRoute(
              path: 'staff',
              name: 'staff',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const StaffManagementScreen(),
            ),
            GoRoute(
              path: 'printer',
              name: 'printer',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const PrinterSettingsScreen(),
            ),
            GoRoute(
              path: 'qr',
              name: 'qr',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) {
                final slug = state.extra as String? ?? 'unknown';
                return QrGeneratorScreen(businessSlug: slug);
              },
            ),
            GoRoute(
              path: 'booking',
              name: 'booking',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const BookingScreen(),
            ),
            GoRoute(
              path: 'invoice',
              name: 'invoice',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const InvoiceScreen(),
            ),
            GoRoute(
              path: 'catalog',
              name: 'catalog',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const CatalogScreen(),
            ),
            GoRoute(
              path: 'reports',
              name: 'reports',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const ReportScreen(),
            ),
            GoRoute(
              path: 'inventory',
              name: 'inventory',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const InventoryScreen(),
            ),
            GoRoute(
              path: 'crm',
              name: 'crm',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const CrmScreen(),
            ),
            GoRoute(
              path: 'ai',
              name: 'chatbot',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const ChatbotScreen(),
            ),
            GoRoute(
              path: 'kds',
              name: 'kds',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const KdsScreen(),
            ),
            GoRoute(
              path: 'supply',
              name: 'supply',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const SupplyChainScreen(),
            ),
            GoRoute(
              path: 'accounting',
              name: 'accounting',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const AccountingScreen(),
            ),
            GoRoute(
              path: 'hris',
              name: 'hris',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const HrisScreen(),
            ),
            GoRoute(
              path: 'delivery',
              name: 'delivery',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const DeliveryScreen(),
            ),
            GoRoute(
              path: 'marketing',
              name: 'marketing',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const MarketingScreen(),
            ),
            GoRoute(
              path: 'hq',
              name: 'hq',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const HqDashboardScreen(),
            ),
            GoRoute(
              path: 'platform',
              name: 'platform',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const PlatformAdminScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
