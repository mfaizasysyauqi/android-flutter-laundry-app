// File: lib/presentation/screens/order_tracking_screen.dart
// Berisi tampilan untuk melacak pesanan pengguna.
// Menyediakan filter untuk menampilkan semua pesanan, tertunda, diproses, selesai, atau dibatalkan.

// Mengimpor package dan file yang diperlukan.
import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/domain/entities/order.dart';
import 'package:flutter_laundry_app/presentation/providers/auth_provider.dart';
import 'package:flutter_laundry_app/presentation/providers/order_provider.dart';
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/icon_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/margin_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/padding_sizes.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/filter_chip_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/order/order_card.dart';
import '../../../widgets/common/loading_indicator.dart';

// Kelas utama untuk layar pelacakan pesanan
class OrderTrackingScreen extends ConsumerWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mengamati status autentikasi
    final authState = ref.watch(authStateProvider);

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
        // Membangun layar pesanan
        return _buildOrdersScreen(context, ref);
      },
      // Menampilkan indikator loading saat status autentikasi sedang dimuat
      loading: () => const Scaffold(
        body: Center(child: LoadingIndicator()),
      ),
      // Menampilkan pesan error jika autentikasi gagal
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  // Membangun tampilan utama layar pesanan
  Widget _buildOrdersScreen(BuildContext context, WidgetRef ref) {
    // Mengamati filter yang dipilih
    final selectedFilter = ref.watch(orderFilterProvider);
    // Mengamati daftar pesanan
    final ordersAsync = ref.watch(customerOrdersProvider);

    return Scaffold(
      // AppBar dengan navigasi dan tombol refresh
      appBar: AppBar(
        backgroundColor: BackgroundColors.transparent,
        shadowColor: BackgroundColors.transparent,
        surfaceTintColor: BackgroundColors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: IconSizes.navigationIcon,
          ),
          // Kembali ke dashboard pengguna
          onPressed: () {
            context.go('/user-dashboard-screen');
          },
        ),
        title: Text(
          'Track Orders',
          style: AppTypography.darkAppBarTitle,
        ),
        centerTitle: true,
        actions: [
          // Tombol untuk menyegarkan daftar pesanan
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(customerOrdersProvider),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul bagian
          Padding(
            padding: const EdgeInsets.only(
              right: PaddingSizes.sectionTitlePadding,
              left: PaddingSizes.sectionTitlePadding,
              top: PaddingSizes.topOnly,
            ),
            child: Text(
              'Tracking your orders',
              style: AppTypography.sectionTitle,
            ),
          ),
          // Filter untuk memilih jenis pesanan
          Container(
            padding: const EdgeInsets.all(PaddingSizes.cardPadding),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChipWidget<OrderFilter>(
                    filter: OrderFilter.all,
                    selectedFilter: selectedFilter,
                    label: _getFilterName(OrderFilter.all),
                    onSelected: (filter) =>
                        ref.read(orderFilterProvider.notifier).state = filter,
                  ),
                  const SizedBox(width: MarginSizes.filterChipSpacing),
                  FilterChipWidget<OrderFilter>(
                    filter: OrderFilter.pending,
                    selectedFilter: selectedFilter,
                    label: _getFilterName(OrderFilter.pending),
                    onSelected: (filter) =>
                        ref.read(orderFilterProvider.notifier).state = filter,
                  ),
                  const SizedBox(width: MarginSizes.filterChipSpacing),
                  FilterChipWidget<OrderFilter>(
                    filter: OrderFilter.processing,
                    selectedFilter: selectedFilter,
                    label: _getFilterName(OrderFilter.processing),
                    onSelected: (filter) =>
                        ref.read(orderFilterProvider.notifier).state = filter,
                  ),
                  const SizedBox(width: MarginSizes.filterChipSpacing),
                  FilterChipWidget<OrderFilter>(
                    filter: OrderFilter.completed,
                    selectedFilter: selectedFilter,
                    label: _getFilterName(OrderFilter.completed),
                    onSelected: (filter) =>
                        ref.read(orderFilterProvider.notifier).state = filter,
                  ),
                  const SizedBox(width: MarginSizes.filterChipSpacing),
                  FilterChipWidget<OrderFilter>(
                    filter: OrderFilter.cancelled,
                    selectedFilter: selectedFilter,
                    label: _getFilterName(OrderFilter.cancelled),
                    onSelected: (filter) =>
                        ref.read(orderFilterProvider.notifier).state = filter,
                  ),
                ],
              ),
            ),
          ),
          // Daftar pesanan
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                // Menampilkan status kosong jika tidak ada pesanan
                if (orders.isEmpty) {
                  return _buildEmptyState(context, selectedFilter);
                }
                // Menampilkan daftar pesanan
                return SafeArea(child: _buildOrdersList(orders));
              },
              // Menampilkan indikator loading saat data diambil
              loading: () => const Center(child: LoadingIndicator()),
              // Menampilkan pesan error jika gagal mengambil data
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

  // Mendapatkan nama filter untuk ditampilkan
  String _getFilterName(OrderFilter filter) {
    switch (filter) {
      case OrderFilter.all:
        return 'All Orders';
      case OrderFilter.pending:
        return 'Pending';
      case OrderFilter.processing:
        return 'Processing';
      case OrderFilter.completed:
        return 'Completed';
      case OrderFilter.cancelled:
        return 'Cancelled';
    }
  }

  // Membangun daftar pesanan
  Widget _buildOrdersList(List<Order> orders) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: PaddingSizes.sectionTitlePadding),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        // Menampilkan kartu pesanan
        return OrderCard(order: order, isAdmin: false);
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
            'No ${_getFilterName(filter).toLowerCase()} found',
            style: AppTypography.emptyStateTitle,
          ),
          const SizedBox(height: MarginSizes.small),
          Text(
            'Orders matching your filter will appear here',
            style: AppTypography.emptyStateSubtitle,
          ),
        ],
      ),
    );
  }
}
