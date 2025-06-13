// File: lib/presentation/screens/admin_dashboard_screen.dart
// Berisi tampilan dashboard admin untuk mengelola operasi laundry.
// Menyediakan navigasi ke fitur pembuatan pesanan, pengelolaan pesanan, riwayat, voucher, dan harga.

// Mengimpor package dan file yang diperlukan.
import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/providers/core_provider.dart';
import 'package:flutter_laundry_app/presentation/providers/order_provider.dart'
    as order_provider;
import 'package:flutter_laundry_app/presentation/providers/user_provider.dart';
import 'package:flutter_laundry_app/presentation/providers/voucher_provider.dart'
    as voucher_provider;
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/style/colors/text_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/icon_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/padding_sizes.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/loading_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';

// Kelas utama untuk layar dashboard admin
class AdminDashboardScreen extends ConsumerWidget {
  // Nama rute untuk navigasi
  static const routeName = '/admin-dashboard-screen';

  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mengamati status autentikasi dari provider
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Scaffold menyediakan struktur dasar layar
    return Scaffold(
      backgroundColor: BackgroundColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: BackgroundColors.appBarBackground,
        shadowColor: BackgroundColors.transparent,
        surfaceTintColor: BackgroundColors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PaddingSizes.dashboardHorizontal,
              ),
              child: Text(
                'Dashboard',
                style: AppTypography.appBarTitle,
              ),
            ),
            // Tombol logout untuk keluar dari sesi
            IconButton(
              icon: const Icon(
                Icons.logout,
                size: IconSizes.logout,
                color: TextColors.lightText,
              ),
              onPressed: () {
                _handleLogout(context, ref);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Menampilkan indikator loading jika data pengguna belum tersedia
            user == null
                ? const Center(child: LoadingIndicator())
                : Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PaddingSizes.sectionTitlePadding,
                            vertical: PaddingSizes.dashboardVertical,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Teks sambutan
                              Text(
                                'Welcome!',
                                style: AppTypography.welcomeIntro,
                              ),
                              // Menampilkan nama lengkap pengguna
                              Text(
                                'Worker ${user.fullName}',
                                style: AppTypography.welcomeFullName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Kontainer utama untuk daftar layanan
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: BackgroundColors.contentContainer,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  PaddingSizes.contentContainerPadding),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(
                                        PaddingSizes.formOuterPadding),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Our services',
                                          style: AppTypography.sectionTitle,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Daftar ikon layanan dalam grid
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Navigasi ke layar pembuatan pesanan
                                              GestureDetector(
                                                onTap: () {
                                                  context.go(
                                                      '/create-order-screen');
                                                },
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  child: SvgPicture.asset(
                                                    'assets/svg/create_order.svg',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              // Navigasi ke layar pengelolaan pesanan
                                              GestureDetector(
                                                onTap: () {
                                                  context.go(
                                                      '/manage-orders-screen');
                                                },
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  child: SvgPicture.asset(
                                                    'assets/svg/manage_orders.svg',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              // Navigasi ke layar riwayat pesanan
                                              GestureDetector(
                                                onTap: () {
                                                  context.go(
                                                    '/admin-order-history-screen',
                                                  );
                                                },
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  child: SvgPicture.asset(
                                                    'assets/svg/history.svg',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              // Navigasi ke layar pembuatan voucher
                                              GestureDetector(
                                                onTap: () {
                                                  context.go('/create-voucher');
                                                },
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  child: SvgPicture.asset(
                                                    'assets/svg/create_voucher.svg',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              // Navigasi ke layar daftar voucher
                                              GestureDetector(
                                                onTap: () {
                                                  context.go(
                                                      '/admin-voucher-list-screen');
                                                },
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  child: SvgPicture.asset(
                                                    'assets/svg/edit_voucher.svg',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              // Navigasi ke layar pengelolaan harga
                                              GestureDetector(
                                                onTap: () {
                                                  context.go(
                                                      '/price-management-screen');
                                                },
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  child: SvgPicture.asset(
                                                    'assets/svg/edit_price.svg',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  context.go(
                                                      '/predict-laundry-screen');
                                                },
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  child: SvgPicture.asset(
                                                    'assets/svg/predict_order.svg',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 0,
                                                height: 0,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Menangani proses logout
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    // Fungsi untuk navigasi ke layar login
    navigateToLogin() => context.go('/login-screen');

    try {
      // Memanggil fungsi signOut dari Firebase
      await ref.read(firebaseAuthProvider).signOut();
      // Mengatur ulang provider untuk membersihkan data
      ref.invalidate(currentUserUniqueNameProvider);
      ref.invalidate(order_provider.laundryOrdersProvider);
      ref.invalidate(voucher_provider.voucherListProvider);

      // Navigasi ke layar login jika konteks masih valid
      if (context.mounted) {
        navigateToLogin();
      }
    } catch (e) {
      // Menampilkan pesan error jika gagal logout
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }
}
