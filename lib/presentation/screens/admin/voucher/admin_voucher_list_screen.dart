import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/domain/entities/voucher.dart';
import 'package:flutter_laundry_app/presentation/providers/auth_provider.dart';
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/icon_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/margin_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/padding_sizes.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/filter_chip_widget.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/loading_indicator.dart';
import 'package:flutter_laundry_app/presentation/widgets/voucher/voucher_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_laundry_app/presentation/providers/voucher_provider.dart'
    as voucher_provider;

class AdminVoucherListScreen extends ConsumerStatefulWidget {
  static const routeName = '/admin-voucher-list-screen';
  const AdminVoucherListScreen({super.key});

  @override
  AdminVoucherListScreenState createState() => AdminVoucherListScreenState();
}

class AdminVoucherListScreenState
    extends ConsumerState<AdminVoucherListScreen> {
  String selectedTab = 'All Vouchers';
  static const List<String> filterOptions = [
    'All Vouchers',
    'Discount',
    'Free Laundry',
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null && authState.status != AuthStatus.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login-screen');
      });
      return const Scaffold(
        body: Center(child: LoadingIndicator()),
      );
    }

    // Gunakan laundryId dari user (asumsi user adalah pemilik laundry)
    final laundryId = user?.id;
    if (laundryId == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Laundry ID not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: BackgroundColors.transparent,
        shadowColor: BackgroundColors.transparent,
        surfaceTintColor: BackgroundColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: IconSizes.navigationIcon,
          ),
          onPressed: () {
            context.go('/admin-dashboard-screen');
          },
        ),
        title: Text(
          'Vouchers',
          style: AppTypography.darkAppBarTitle,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  right: PaddingSizes.sectionTitlePadding,
                  left: PaddingSizes.sectionTitlePadding,
                  top: PaddingSizes.topOnly,
                ),
                child: Text(
                  'My Vouchers',
                  style: AppTypography.sectionTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: PaddingSizes.contentContainerPadding),
          Container(
            padding: const EdgeInsets.all(PaddingSizes.cardPadding),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: filterOptions
                    .map((tabName) => Padding(
                          padding: const EdgeInsets.only(
                              right: MarginSizes.filterChipSpacing),
                          child: FilterChipWidget<String>(
                            filter: tabName,
                            selectedFilter: selectedTab,
                            label: tabName,
                            onSelected: (value) {
                              setState(() {
                                selectedTab = value;
                              });
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final voucherState = ref.watch(
                    voucher_provider.adminVoucherListProvider(laundryId));

                if (voucherState.isLoading) {
                  return const Center(child: LoadingIndicator());
                }

                if (voucherState.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${voucherState.error}'),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(voucher_provider
                                  .adminVoucherListProvider(laundryId)
                                  .notifier)
                              .refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                List<Voucher> filteredVouchers = voucherState.vouchers;
                if (selectedTab == 'Discount') {
                  filteredVouchers = voucherState.vouchers
                      .where(
                          (voucher) => voucher.type.toLowerCase() == 'discount')
                      .toList();
                } else if (selectedTab == 'Free Laundry') {
                  filteredVouchers = voucherState.vouchers
                      .where((voucher) =>
                          voucher.type.toLowerCase() == 'free laundry')
                      .toList();
                }

                if (filteredVouchers.isEmpty) {
                  return _buildEmptyState(context, selectedTab);
                }

                return SafeArea(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: PaddingSizes.sectionTitlePadding),
                    itemCount: filteredVouchers.length,
                    itemBuilder: (context, index) {
                      final voucher = filteredVouchers[index];
                      final uniqueName =
                          voucherState.laundryNames[voucher.laundryId] ??
                              'Unknown Laundry';
                      return VoucherCard(
                        voucher: voucher,
                        uniqueName: uniqueName,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: IconSizes.emptyStateIcon,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: MarginSizes.medium),
          Text(
            'No $tabName found',
            style: AppTypography.emptyStateTitle,
          ),
          const SizedBox(height: MarginSizes.small),
          Text(
            'Vouchers matching your filter will appear here',
            style: AppTypography.emptyStateSubtitle,
          ),
        ],
      ),
    );
  }
}
