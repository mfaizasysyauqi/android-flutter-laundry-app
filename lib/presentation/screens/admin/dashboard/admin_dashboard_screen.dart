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

class AdminDashboardScreen extends ConsumerWidget {
  static const routeName = '/admin-dashboard-screen';

  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

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
                              Text(
                                'Welcome!',
                                style: AppTypography.welcomeIntro,
                              ),
                              Text(
                                'Worker ${user.fullName}',
                                style: AppTypography.welcomeFullName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
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
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
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

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    navigateToLogin() => context.go('/login-screen');

    try {
      await ref.read(firebaseAuthProvider).signOut();
      ref.invalidate(currentUserUniqueNameProvider);
      ref.invalidate(order_provider.laundryOrdersProvider);
      ref.invalidate(
          voucher_provider.voucherListProvider); // Invalidate voucher list

      if (context.mounted) {
        navigateToLogin();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }
}
