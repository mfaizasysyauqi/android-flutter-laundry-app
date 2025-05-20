// File: lib/presentation/screens/admin_order_history_screen.dart
// Berisi tampilan riwayat pesanan untuk admin.
// Menyediakan filter untuk menampilkan pesanan berdasarkan status (semua, selesai, dibatalkan).

// Mengimpor package dan file yang diperlukan.
import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../style/app_typography.dart';
import '../../../style/colors/background_colors.dart';
import '../../../style/sizes/icon_sizes.dart';
import '../../../style/sizes/margin_sizes.dart';
import '../../../style/sizes/padding_sizes.dart';
import '../../../widgets/common/filter_chip_widget.dart';
import '../../../widgets/common/loading_indicator.dart';
import '../../../providers/order_provider.dart';
import '../../../widgets/order/order_card.dart';
import '../../../../domain/entities/order.dart' as domain;

// Kelas utama untuk layar riwayat pesanan admin
class AdminOrderHistoryScreen extends ConsumerWidget {
  // Nama rute untuk navigasi
  static const routeName = '/admin-order-history-screen';
  const AdminOrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mengamati status autentikasi
    final authState = ref.watch(authStateProvider);

    // Menangani status autentikasi dengan AsyncValue
    return authState.when(
      data: (user) {
        // Jika pengguna tidak terautentikasi, arahkan ke layar login
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login-screen');
          });
          return const Scaffold(
            body: Center(child: LoadingIndicator()),
          );
        }
        // Membangun layar riwayat jika pengguna valid
        return _buildHistoryScreen(context, ref);
      },
      loading: () => const Scaffold(
        body: Center(child: LoadingIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  // Membangun tampilan utama layar riwayat
  Widget _buildHistoryScreen(BuildContext context, WidgetRef ref) {
    // Mengamati filter yang dipilih dan data pesanan
    final selectedFilter = ref.watch(orderFilterProvider);
    final ordersAsync = ref.watch(historyOrdersProvider);

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
          // Kembali ke dashboard
          onPressed: () {
            context.go('/admin-dashboard-screen');
          },
        ),
        title: Text(
          'History',
          style: AppTypography.darkAppBarTitle,
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              right: PaddingSizes.sectionTitlePadding,
              left: PaddingSizes.sectionTitlePadding,
              top: PaddingSizes.topOnly,
            ),
            child: Text(
              'History Laundry',
              style: AppTypography.sectionTitle,
            ),
          ),
          // Filter untuk memilih status pesanan
          Container(
            padding: const EdgeInsets.all(PaddingSizes.cardPadding),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChipWidget<OrderFilter>(
                    filter: OrderFilter.all,
                    selectedFilter: selectedFilter,
                    label: 'All Orders',
                    onSelected: (filter) =>
                        ref.read(orderFilterProvider.notifier).state = filter,
                  ),
                  const SizedBox(width: MarginSizes.filterChipSpacing),
                  FilterChipWidget<OrderFilter>(
                    filter: OrderFilter.completed,
                    selectedFilter: selectedFilter,
                    label: 'Completed',
                    onSelected: (filter) =>
                        ref.read(orderFilterProvider.notifier).state = filter,
                  ),
                  const SizedBox(width: MarginSizes.filterChipSpacing),
                  FilterChipWidget<OrderFilter>(
                    filter: OrderFilter.cancelled,
                    selectedFilter: selectedFilter,
                    label: 'Cancelled',
                    onSelected: (filter) =>
                        ref.read(orderFilterProvider.notifier).state = filter,
                  ),
                ],
              ),
            ),
          ),
          // Menampilkan daftar pesanan atau status lainnya
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return _buildEmptyState(context, selectedFilter);
                }
                return _buildOrdersList(orders, ref);
              },
              loading: () => const Center(child: LoadingIndicator()),
              error: (error, stackTrace) => Center(
                child: Text(
                  'Error: ${error.toString()}',
                  style: AppTypography.errorText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Membangun daftar pesanan
  Widget _buildOrdersList(List<domain.Order> orders, WidgetRef ref) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        // Menampilkan kartu pesanan dengan mode admin
        return OrderCard(
          order: order,
          isAdmin: true,
        );
      },
    );
  }

  // Menampilkan tampilan saat tidak ada pesanan
  Widget _buildEmptyState(BuildContext context, OrderFilter filter) {
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
            'No history found',
            style: AppTypography.emptyStateTitle,
          ),
          const SizedBox(height: MarginSizes.small),
          Text(
            'Completed or cancelled orders will appear here',
            style: AppTypography.emptyStateSubtitle,
          ),
        ],
      ),
    );
  }
}