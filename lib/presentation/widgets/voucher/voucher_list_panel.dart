import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_laundry_app/domain/entities/voucher.dart';
import 'package:flutter_laundry_app/presentation/providers/core_provider.dart';
import 'package:flutter_laundry_app/presentation/providers/user_provider.dart';
import 'package:flutter_laundry_app/presentation/providers/voucher_provider.dart'
    as voucher_provider;
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/icon_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/margin_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/padding_sizes.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/filter_chip_widget.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/loading_indicator.dart';
import 'package:flutter_laundry_app/presentation/widgets/voucher/apply_voucher_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoucherListPanel extends ConsumerStatefulWidget {
  final String? userId;
  final double? weight;
  final String? laundryId;
  final Function(String voucherName, String voucherId) onVoucherSelected;
  final VoidCallback onClose;

  const VoucherListPanel({
    super.key,
    this.userId,
    this.weight,
    this.laundryId,
    required this.onVoucherSelected,
    required this.onClose,
  });

  @override
  VoucherListPanelState createState() => VoucherListPanelState();
}

class VoucherListPanelState extends ConsumerState<VoucherListPanel> {
  String _selectedTab = 'All Vouchers';
  static const List<String> _filterOptions = [
    'All Vouchers',
    'Discount',
    'Free Laundry',
  ];

  bool _isVoucherEligible(Voucher voucher, double? weight) {
    final now = DateTime.now();

    if (voucher.validityPeriod != null &&
        voucher.validityPeriod!.isBefore(now)) {
      return false;
    }

    switch (voucher.obtainMethod) {
      case 'Laundry 5 Kg':
        return weight != null && weight >= 5;
      case 'Laundry 10 Kg':
        return weight != null && weight >= 10;
      case 'First Laundry':
        return true;
      case 'Laundry on Birthdate':
        return false; // Implement birthdate check
      case 'Weekday Laundry':
        return now.weekday >= 1 && now.weekday <= 5;
      case 'New Service':
        return false; // Placeholder
      case 'Twin Date':
        return now.day == now.month;
      case 'Special Date':
        final specialDates = [
          DateTime(now.year, 12, 25),
          DateTime(now.year, 1, 1),
        ];
        return specialDates
            .any((date) => date.day == now.day && date.month == now.month);
      default:
        return true;
    }
  }

  Future<void> _debugFirestoreVouchers(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('vouchers')
          .where('ownerVoucherIds', arrayContains: userId)
          .get();
      debugPrint('Vouchers for userId $userId: ${snapshot.docs.length} found');
    } catch (e) {
      debugPrint('Error fetching vouchers: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.laundryId != null) {
          ref
              .read(voucher_provider
                  .workerVoucherListProvider(
                    voucher_provider.WorkerVoucherParams(
                      ownerUserId: widget.userId!,
                      laundryId: widget.laundryId!,
                    ),
                  )
                  .notifier)
              .refresh();
        } else {
          ref
              .read(
                  voucher_provider.voucherListProvider(widget.userId).notifier)
              .refresh();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userId != null) {
      _debugFirestoreVouchers(widget.userId!);
    }

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chevron_left,
                    size: IconSizes.navigationIcon,
                  ),
                  onPressed: widget.onClose,
                ),
                Text(
                  'Select Voucher',
                  style: AppTypography.modalTitle,
                ),
                const SizedBox(width: 48),
              ],
            ),
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: PaddingSizes.cardPadding,
                  right: PaddingSizes.cardPadding,
                  bottom: PaddingSizes.cardPadding,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _filterOptions
                        .map((tabName) => Padding(
                              padding: const EdgeInsets.only(
                                  right: MarginSizes.filterChipSpacing),
                              child: FilterChipWidget<String>(
                                filter: tabName,
                                selectedFilter: _selectedTab,
                                label: tabName,
                                onSelected: (value) {
                                  setState(() {
                                    _selectedTab = value;
                                  });
                                },
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final userRoleAsync = ref.watch(userRoleProvider);
                  final currentUser =
                      ref.read(firebaseAuthProvider).currentUser;

                  if (userRoleAsync.isLoading) {
                    return const Center(child: LoadingIndicator());
                  }

                  if (userRoleAsync.hasError) {
                    return Center(
                      child: Text('Error: ${userRoleAsync.error}'),
                    );
                  }

                  final isWorker = userRoleAsync.hasValue &&
                      userRoleAsync.value == 'Worker' &&
                      widget.laundryId != null &&
                      currentUser != null;

                  final voucherState = isWorker
                      ? ref.watch(voucher_provider.workerVoucherListProvider(
                          voucher_provider.WorkerVoucherParams(
                            ownerUserId: widget.userId!,
                            laundryId: widget.laundryId!,
                          ),
                        ))
                      : ref.watch(
                          voucher_provider.voucherListProvider(widget.userId));

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
                            onPressed: () {
                              if (isWorker) {
                                ref
                                    .read(voucher_provider
                                        .workerVoucherListProvider(
                                          voucher_provider.WorkerVoucherParams(
                                            ownerUserId: widget.userId!,
                                            laundryId: widget.laundryId!,
                                          ),
                                        )
                                        .notifier)
                                    .refresh();
                              } else {
                                ref
                                    .read(voucher_provider
                                        .voucherListProvider(widget.userId)
                                        .notifier)
                                    .refresh();
                              }
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  var filteredVouchers = voucherState.vouchers
                      .where((voucher) =>
                          widget.userId == null ||
                          voucher.ownerVoucherIds.contains(widget.userId))
                      .where((voucher) =>
                          _selectedTab == 'All Vouchers' ||
                          voucher.type == _selectedTab)
                      .where((voucher) =>
                          _isVoucherEligible(voucher, widget.weight))
                      .toList();

                  if (filteredVouchers.isEmpty) {
                    return const Center(
                      child: Text(
                        'No eligible vouchers available',
                        style: AppTypography.bodyText,
                      ),
                    );
                  }

                  return SafeArea(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PaddingSizes.cardPadding,
                        vertical: PaddingSizes.cardPadding,
                      ),
                      itemCount: filteredVouchers.length,
                      itemBuilder: (context, index) {
                        final voucher = filteredVouchers[index];
                        final uniqueName =
                            voucherState.laundryNames[voucher.laundryId] ??
                                'Unknown Laundry';
                        final isLaundryOwner = userRoleAsync.hasValue &&
                            userRoleAsync.value == 'Worker';
                    
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: MarginSizes.cardMargin),
                          child: ApplyVoucherCard(
                            voucher: voucher,
                            uniqueName: uniqueName,
                            isLaundryOwner: isLaundryOwner,
                            onApply: () {
                              widget.onVoucherSelected(voucher.name, voucher.id);
                              debugPrint(
                                  'Applying voucher: name=${voucher.name}, id=${voucher.id}');
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
