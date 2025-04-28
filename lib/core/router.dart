import 'package:flutter_laundry_app/domain/entities/voucher.dart';
import 'package:flutter_laundry_app/presentation/screens/admin/order/admin_order_history_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/admin/order/manage_orders_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/admin/price/price_management_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/admin/voucher/admin_voucher_details_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/admin/voucher/admin_voucher_list_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/admin/dashboard/admin_dashboard_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/user/dashboard/user_dashboard_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/admin/order/create_order_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/user/order/order_tracking_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/auth/login_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/auth/register_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/splash_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/user/order/user_order_history_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/admin/voucher/create_voucher_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/admin/voucher/edit_voucher_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/user/voucher/user_voucher_details_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/user/voucher/user_voucher_list_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/splash-screen',
    routes: [
      GoRoute(
        path: '/splash-screen',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register-screen',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/login-screen',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/user-dashboard-screen',
        builder: (context, state) => const UserDashboardScreen(),
      ),
      GoRoute(
        path: '/admin-dashboard-screen',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/create-order-screen',
        builder: (context, state) => const CreateOrderScreen(),
      ),
      GoRoute(
        path: '/manage-orders-screen',
        builder: (context, state) => const ManageOrdersScreen(),
      ),
      GoRoute(
        path: '/order-tracking-screen',
        builder: (context, state) => const OrderTrackingScreen(),
      ),
      GoRoute(
        path: '/price-management-screen',
        builder: (context, state) => const PriceManagementScreen(),
      ),
      GoRoute(
        path: '/create-voucher',
        builder: (context, state) => const CreateVoucherScreen(),
      ),
      GoRoute(
        path: '/edit-voucher-screen',
        builder: (context, state) {
          final voucher = state.extra as Voucher;
          return EditVoucherScreen(voucher: voucher);
        },
      ),
      GoRoute(
        path: '/admin-order-history-screen',
        builder: (context, state) {
          return const AdminOrderHistoryScreen();
        },
      ),
      GoRoute(
        path: '/user-order-history-screen',
        builder: (context, state) {
          return const UserOrderHistoryScreen();
        },
      ),
      GoRoute(
        path: '/admin-voucher-list-screen',
        builder: (context, state) => const AdminVoucherListScreen(),
      ),
      GoRoute(
        path: '/user-voucher-list-screen',
        builder: (context, state) => const UserVoucherListScreen(),
      ),
      GoRoute(
        path: '/admin-voucher-details-screen',
        builder: (context, state) {
          final voucher = state.extra as Voucher;
          return AdminVoucherDetailsScreen(voucher: voucher);
        },
      ),
      GoRoute(
        path: '/user-voucher-details-screen',
        builder: (context, state) {
          final voucher = state.extra as Voucher;
          return UserVoucherDetailsScreen(voucher: voucher);
        },
      ),
    ],
  );
});
