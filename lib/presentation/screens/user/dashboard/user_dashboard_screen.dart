// File: lib/presentation/screens/user_dashboard_screen.dart
// Berisi tampilan dashboard untuk pengguna (pelanggan).
// Menyediakan akses ke pelacakan pesanan, riwayat pesanan, daftar voucher, dan logout.

// Mengimpor package dan file yang diperlukan.
import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/providers/core_provider.dart';
import 'package:flutter_laundry_app/presentation/providers/order_provider.dart';
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

// Kelas utama untuk layar dashboard pengguna
class UserDashboardScreen extends ConsumerWidget {
  // Nama rute untuk navigasi
  static const routeName = '/user-dashboard-screen';

  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mengamati status autentikasi
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      // Latar belakang dashboard
      backgroundColor: BackgroundColors.dashboardBackground,
      // AppBar dengan judul dan tombol logout
      appBar: AppBar(
        backgroundColor: BackgroundColors.appBarBackground,
        shadowColor: BackgroundColors.transparent,
        surfaceTintColor: BackgroundColors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PaddingSizes.dashboardHorizontal,
              ),
              // Judul dashboard
              child: Text(
                'Dashboard',
                style: AppTypography.appBarTitle,
              ),
            ),
            // Tombol logout
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
      // Body utama dengan layout aman
      body: SafeArea(
        child: Column(
          children: [
            // Menampilkan indikator loading jika pengguna belum terautentikasi
            user == null
                ? const Center(child: LoadingIndicator())
                : Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bagian sambutan
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PaddingSizes.sectionTitlePadding,
                            vertical: PaddingSizes.dashboardVertical,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome!',
                                style: AppTypography.welcomeIntro,
                              ),
                              Text(
                                'Customer ${user.fullName}',
                                style: AppTypography.welcomeFullName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Kontainer untuk layanan
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
                                  // Judul bagian layanan
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
                                  // Daftar layanan dalam scroll view
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          // Baris untuk pelacakan dan riwayat pesanan
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Tombol pelacakan pesanan
                                              GestureDetector(
                                                onTap: () {
                                                  context.go(
                                                      '/order-tracking-screen');
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
                                                    'assets/svg/track_orders.svg',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              // Tombol riwayat pesanan
                                              GestureDetector(
                                                onTap: () {
                                                  context.go(
                                                      '/user-order-history-screen');
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
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          // Baris untuk daftar voucher
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  context.go(
                                                      '/user-voucher-list-screen');
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
                                                    'assets/svg/voucher.svg',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
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
      // Memanggil fungsi logout dari Firebase
      await ref.read(firebaseAuthProvider).signOut();
      // Mengosongkan data provider
      ref.invalidate(currentUserUniqueNameProvider);
      ref.invalidate(customerOrdersProvider);
      ref.invalidate(voucher_provider.voucherListProvider);

      // Navigasi ke layar login jika widget masih terpasang
      if (context.mounted) {
        navigateToLogin();
      }
    } catch (e) {
      // Menampilkan pesan error jika logout gagal
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }
}
