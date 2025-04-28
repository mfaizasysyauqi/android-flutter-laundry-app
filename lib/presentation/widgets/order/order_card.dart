import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/domain/entities/order.dart';
import 'package:flutter_laundry_app/presentation/providers/order_provider.dart';
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/style/colors/border_colors.dart';
import 'package:flutter_laundry_app/presentation/style/colors/button_colors.dart';
import 'package:flutter_laundry_app/presentation/style/colors/text_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/button_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/icon_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/margin_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/padding_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/text_sizes.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/loading_indicator.dart';
import 'package:flutter_laundry_app/presentation/widgets/order/status_badge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class OrderCard extends ConsumerWidget {
  final Order order;
  final bool isAdmin;

  const OrderCard({
    super.key,
    required this.order,
    this.isAdmin = true,
  });

  String formatTotalPrice(double totalPrice) {
    if (totalPrice > 999999999) {
      double valueInBillions = totalPrice / 1000000000;
      return 'Rp ${valueInBillions.toStringAsFixed(valueInBillions < 10 ? 1 : 0)} m';
    } else if (totalPrice > 999999) {
      double valueInMillions = totalPrice / 1000000;
      return 'Rp ${valueInMillions.toStringAsFixed(valueInMillions < 10 ? 1 : 0)} jt';
    } else {
      final currencyFormat = NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return currencyFormat.format(totalPrice);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final orderActions = ref.watch(orderActionsProvider);

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: MarginSizes.cardMargin,
        horizontal: MarginSizes.cardMargin,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: BackgroundColors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(PaddingSizes.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'ID: #${order.id}',
                        style: AppTypography.orderId,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          dateFormat.format(order.createdAt),
                          style: AppTypography.date,
                        ),
                        Text(
                          order.status == 'pending' ||
                                  order.status == 'processing'
                              ? ' > '
                              : order.status == 'completed'
                                  ? ' - '
                                  : order.status == 'cancelled'
                                      ? ' × '
                                      : ' ? ',
                          style: AppTypography.date,
                        ),
                        Text(
                          order.status == 'completed' &&
                                  order.completedAt != null
                              ? dateFormat.format(order.completedAt!)
                              : dateFormat.format(order.estimatedCompletion),
                          style: AppTypography.date,
                        ),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: PaddingSizes.verticalDivider),
                  child: Divider(height: 1, color: BorderColors.divider),
                ),
                const SizedBox(height: MarginSizes.medium),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SvgPicture.asset(
                        'assets/svg/dummy_brand.svg',
                        width: 100,
                        height: 100,
                        placeholderBuilder: (context) => const SizedBox(
                          width: 70,
                          height: 70,
                          child: LoadingIndicator(),
                        ),
                      ),
                    ),
                    const SizedBox(width: MarginSizes.cardContentSpacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAdmin == false
                                ? order.laundryUniqueName
                                : order.customerUniqueName,
                            style: AppTypography.laundryName.copyWith(
                              fontSize: TextSizes.generalText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            order.laundrySpeed == 'Express'
                                ? order.laundrySpeed
                                : order.laundrySpeed == 'Reguler'
                                    ? order.laundrySpeed
                                    : order.laundrySpeed,
                            style: AppTypography.laundrySpeed.copyWith(
                              fontSize: TextSizes.speedText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: MarginSizes.small),
                          Wrap(
                            spacing: MarginSizes.cardElementSpacing,
                            runSpacing: MarginSizes.cardElementSpacing,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/svg/weight_icon.svg',
                                    width: IconSizes.orderDetailIcon,
                                    height: IconSizes.orderDetailIcon,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(
                                      width: MarginSizes.cardElementSpacing),
                                  Flexible(
                                    child: Text(
                                      'Weight: ${order.weight} kg',
                                      style: AppTypography.weightClothes,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/svg/clothes_icon.svg',
                                    width: IconSizes.orderDetailIcon,
                                    height: IconSizes.orderDetailIcon,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(
                                      width: MarginSizes.cardElementSpacing),
                                  Flexible(
                                    child: Text(
                                      'Clothes: ${order.clothes} Items',
                                      style: AppTypography.weightClothes,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: MarginSizes.cardElementSpacing),
                    Column(
                      children: [
                        Text(
                          formatTotalPrice(order.totalPrice),
                          style: AppTypography.price.copyWith(
                            fontSize: TextSizes.generalText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (order.isHistory || !isAdmin) ...[
                          StatusBadge(status: order.status),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isAdmin && !order.isHistory) ...[
            const Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: PaddingSizes.sectionTitlePadding),
              child: Divider(height: 1, color: BorderColors.divider),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: PaddingSizes.contentContainerPadding,
                horizontal: PaddingSizes.sectionTitlePadding,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Wrap(
                    spacing: MarginSizes.cardElementSpacing,
                    runSpacing: MarginSizes.cardElementSpacing,
                    children: [
                      if (order.status == 'pending') ...[
                        IntrinsicWidth(
                          child: ElevatedButton(
                            onPressed: () => _updateStatus(
                                context, orderActions, 'processing'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ButtonColors.startProcessing,
                              foregroundColor: ButtonColors.buttonTextColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: ButtonSizes.verticalPadding,
                                horizontal: ButtonSizes.horizontalPadding,
                              ),
                            ),
                            child: Text(
                              'Start Processing',
                              style: AppTypography.buttonText,
                            ),
                          ),
                        ),
                      ],
                      if (order.status == 'cancelled')
                        IntrinsicWidth(
                          child: ElevatedButton(
                            onPressed: () =>
                                _sendToHistory(context, orderActions),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ButtonColors.cancelledOrder,
                              foregroundColor: ButtonColors.buttonTextColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: ButtonSizes.verticalPadding,
                                horizontal: ButtonSizes.horizontalPadding,
                              ),
                            ),
                            child: Text(
                              'Send to History',
                              style: AppTypography.buttonText,
                            ),
                          ),
                        ),
                      if (order.status == 'processing') ...[
                        IntrinsicWidth(
                          child: ElevatedButton(
                            onPressed: () => _updateStatus(
                                context, orderActions, 'completed'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ButtonColors.orderComplete,
                              foregroundColor: ButtonColors.buttonTextColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: ButtonSizes.verticalPadding,
                                horizontal: ButtonSizes.horizontalPadding,
                              ),
                            ),
                            child: Text(
                              'Order Completed',
                              style: AppTypography.buttonText,
                            ),
                          ),
                        ),
                      ],
                      if (order.status != 'cancelled' &&
                          order.status != 'pending' &&
                          order.status != 'processing')
                        IntrinsicWidth(
                          child: ElevatedButton(
                            onPressed: () =>
                                _sendToHistory(context, orderActions),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ButtonColors.sendToHistory,
                              foregroundColor: ButtonColors.buttonTextColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: ButtonSizes.verticalPadding,
                                horizontal: ButtonSizes.horizontalPadding,
                              ),
                            ),
                            child: Text(
                              'Send to History',
                              style: AppTypography.buttonText,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (order.status == 'pending' || order.status == 'processing')
                    TextButton(
                      onPressed: () =>
                          _updateStatus(context, orderActions, 'cancelled'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/trash_icon.svg',
                            width: IconSizes.cancelActionIcon,
                            height: IconSizes.cancelActionIcon,
                            fit: BoxFit.contain,
                            colorFilter: const ColorFilter.mode(
                              TextColors.cancelActionTextColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: MarginSizes.sectionSpacing),
                          Text(
                            'Cancel',
                            style: AppTypography.cancelText,
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  StatusBadge(status: order.status),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _updateStatus(
      BuildContext context, OrderActions actions, String newStatus) async {
    try {
      await actions.updateOrderStatus(order.id, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to ${newStatus.toUpperCase()}'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update order: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _sendToHistory(
      BuildContext context, OrderActions actions) async {
    try {
      await actions.setOrderAsHistory(order.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order sent to history'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to send order to history: ${e.toString()}')),
        );
      }
    }
  }
}
