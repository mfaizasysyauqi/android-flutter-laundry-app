import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/domain/entities/order.dart' as domain;
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

class ManageOrdersScreen extends ConsumerWidget {
  const ManageOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login-screen');
          });
          return const Scaffold(
            body: Center(child: LoadingIndicator()),
          );
        }
        return _buildOrdersScreen(context, ref);
      },
      loading: () => const Scaffold(
        body: Center(child: LoadingIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildOrdersScreen(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(orderFilterProvider);
    final ordersAsync = ref.watch(laundryOrdersProvider);

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
          'Manage Orders',
          style: AppTypography.darkAppBarTitle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(laundryOrdersProvider),
          ),
        ],
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
              'Manage Customer Orders',
              style: AppTypography.sectionTitle,
            ),
          ),
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
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return _buildEmptyState(context, selectedFilter);
                }
                return _buildOrdersList(orders);
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

  String _getFilterName(OrderFilter filter) {
    switch (filter) {
      case OrderFilter.all:
        return 'All Active Orders';
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

  Widget _buildOrdersList(List<domain.Order> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(order: order, isAdmin: true);
      },
    );
  }

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
