// File: router.dart
// Berisi konfigurasi routing untuk aplikasi Flutter menggunakan package go_router dan Riverpod.

// Mengimpor package dan file yang diperlukan untuk routing dan widget.
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

// Provider untuk menyediakan instance GoRouter menggunakan Riverpod.
final routerProvider = Provider<GoRouter>((ref) {
  // Konfigurasi GoRouter dengan logging diagnostik dan lokasi awal.
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/splash-screen',
    routes: [
      // Rute untuk layar splash.
      GoRoute(
        path: '/splash-screen',
        builder: (context, state) => const SplashScreen(),
      ),
      // Rute untuk layar login (root).
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),
      // Rute untuk layar registrasi.
      GoRoute(
        path: '/register-screen',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Rute untuk layar login (alternatif).
      GoRoute(
        path: '/login-screen',
        builder: (context, state) => const LoginScreen(),
      ),
      // Rute untuk dashboard pengguna.
      GoRoute(
        path: '/user-dashboard-screen',
        builder: (context, state) => const UserDashboardScreen(),
      ),
      // Rute untuk dashboard admin.
      GoRoute(
        path: '/admin-dashboard-screen',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      // Rute untuk layar pembuatan pesanan.
      GoRoute(
        path: '/create-order-screen',
        builder: (context, state) => const CreateOrderScreen(),
      ),
      // Rute untuk layar pengelolaan pesanan.
      GoRoute(
        path: '/manage-orders-screen',
        builder: (context, state) => const ManageOrdersScreen(),
      ),
      // Rute untuk layar pelacakan pesanan.
      GoRoute(
        path: '/order-tracking-screen',
        builder: (context, state) => const OrderTrackingScreen(),
      ),
      // Rute untuk layar pengelolaan harga.
      GoRoute(
        path: '/price-management-screen',
        builder: (context, state) => const PriceManagementScreen(),
      ),
      // Rute untuk layar pembuatan voucher.
      GoRoute(
        path: '/create-voucher',
        builder: (context, state) => const CreateVoucherScreen(),
      ),
      // Rute untuk layar pengeditan voucher, menerima objek Voucher sebagai extra.
      GoRoute(
        path: '/edit-voucher-screen',
        builder: (context, state) {
          final voucher = state.extra as Voucher;
          return EditVoucherScreen(voucher: voucher);
        },
      ),
      // Rute untuk layar riwayat pesanan admin.
      GoRoute(
        path: '/admin-order-history-screen',
        builder: (context, state) {
          return const AdminOrderHistoryScreen();
        },
      ),
      // Rute untuk layar riwayat pesanan pengguna.
      GoRoute(
        path: '/user-order-history-screen',
        builder: (context, state) {
          return const UserOrderHistoryScreen();
        },
      ),
      // Rute untuk layar daftar voucher admin.
      GoRoute(
        path: '/admin-voucher-list-screen',
        builder: (context, state) => const AdminVoucherListScreen(),
      ),
      // Rute untuk layar daftar voucher pengguna.
      GoRoute(
        path: '/user-voucher-list-screen',
        builder: (context, state) => const UserVoucherListScreen(),
      ),
      // Rute untuk layar detail voucher admin, menerima objek Voucher sebagai extra.
      GoRoute(
        path: '/admin-voucher-details-screen',
        builder: (context, state) {
          final voucher = state.extra as Voucher;
          return AdminVoucherDetailsScreen(voucher: voucher);
        },
      ),
      // Rute untuk layar detail voucher pengguna, menerima objek Voucher sebagai extra.
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