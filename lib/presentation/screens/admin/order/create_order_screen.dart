import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_laundry_app/core/utils/voucher_obtain_method_checker.dart';
import 'package:flutter_laundry_app/data/models/order_model.dart';
import 'package:flutter_laundry_app/data/models/voucher_model.dart';
import 'package:flutter_laundry_app/domain/entities/voucher.dart';
import 'package:flutter_laundry_app/presentation/providers/core_provider.dart';
import 'package:flutter_laundry_app/presentation/providers/order_provider.dart'
    as order_provider;
import 'package:flutter_laundry_app/presentation/providers/user_provider.dart'
    as user_provider;
import 'package:flutter_laundry_app/presentation/providers/voucher_provider.dart'
    as voucher_provider;
import 'package:flutter_laundry_app/presentation/widgets/order/customer_selection_panel.dart';
import 'package:flutter_laundry_app/presentation/widgets/order/laundry_speed_panel.dart';
import 'package:flutter_laundry_app/presentation/widgets/voucher/voucher_list_panel.dart';
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/icon_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/margin_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/padding_sizes.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/custom_button.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/custom_text_form_field.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/loading_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MaxValueInputFormatter extends TextInputFormatter {
  final double maxValue;

  MaxValueInputFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final double? parsedValue = double.tryParse(newValue.text);
    if (parsedValue == null) {
      return oldValue;
    }

    if (parsedValue > maxValue) {
      return oldValue;
    }

    return newValue;
  }
}

final userIdByUniqueNameProvider =
    FutureProvider.family<String, String>((ref, uniqueName) async {
  final getUserByUniqueNameUseCase =
      ref.watch(user_provider.getUserByUniqueNameUseCaseProvider);
  final result = await getUserByUniqueNameUseCase(uniqueName);
  return result.fold(
    (failure) => throw Exception('Failed to fetch user ID: $failure'),
    (user) => user.id,
  );
});

final voucherByIdProvider =
    FutureProvider.family<VoucherModel, String>((ref, voucherId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('vouchers')
      .doc(voucherId)
      .get();
  if (!snapshot.exists) {
    throw Exception('Voucher not found');
  }
  return VoucherModel.fromJson(snapshot.data()!, snapshot.id);
});

class CreateOrderScreen extends ConsumerStatefulWidget {
  static const routeName = '/create-order-screen';

  const CreateOrderScreen({super.key});

  @override
  CreateOrderScreenState createState() => CreateOrderScreenState();
}

class CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _uniqueNameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _clothesController = TextEditingController();
  final TextEditingController _laundrySpeedController = TextEditingController();
  final TextEditingController _vouchersController = TextEditingController();
  Timer? _debounce;
  String? _selectedUserId;
  String? _selectedVoucherId;

  bool _isUniqueNameFormLocked = false;
  bool _isLaundrySpeedFormLocked = false;
  bool _isVoucherFormLocked = false;
  bool _isConfirmButtonLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
      _weightController.addListener(_debouncedUpdatePrediction);
      _clothesController.addListener(_debouncedUpdatePrediction);
      _laundrySpeedController.addListener(_debouncedUpdatePrediction);
    });
  }

  Future<void> _loadUserData() async {
    final userState = ref.read(user_provider.userProvider);
    if (userState.user == null) {
      try {
        await ref.read(user_provider.userProvider.notifier).getUser();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load user data: $e')),
          );
        }
      }
    }
    ref.read(user_provider.customersProvider);
  }

  Future<void> _createOrder() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isConfirmButtonLocked = true;
      });

      String uniqueName = _uniqueNameController.text;
      double weight = double.parse(_weightController.text);
      int clothes = int.parse(_clothesController.text);
      String laundrySpeed = _laundrySpeedController.text;
      List<String> vouchers =
          _selectedVoucherId != null ? [_selectedVoucherId!] : [];

      try {
        if (_selectedUserId == null) {
          throw Exception('No user selected');
        }
        final userId = _selectedUserId!;

        final currentUser = ref.read(firebaseAuthProvider).currentUser;
        if (currentUser == null) {
          throw Exception('User not authenticated');
        }

        final userState = ref.read(user_provider.userProvider);
        final orderState = ref.read(order_provider.orderNotifierProvider);
        if (userState.user == null) {
          throw Exception('User data not loaded');
        }

        final order = OrderModel(
          id: FirebaseFirestore.instance.collection('orders').doc().id,
          laundryUniqueName: userState.user!.uniqueName,
          customerUniqueName: uniqueName,
          weight: weight,
          clothes: clothes,
          laundrySpeed: laundrySpeed,
          vouchers: vouchers,
          totalPrice: _calculateTotalPrice(
              userState.user!, weight, laundrySpeed, vouchers),
          status: 'pending',
          createdAt: DateTime.now(),
          estimatedCompletion: orderState.predictedCompletion ?? DateTime.now(),
          isHistory: false,
        );

        await ref
            .read(order_provider.orderNotifierProvider.notifier)
            .createOrder(
              uniqueName,
              weight,
              clothes,
              laundrySpeed,
              vouchers,
              order.totalPrice,
            );

        final updateVoucherOwnerUseCase =
            ref.read(voucher_provider.updateVoucherOwnerUseCaseProvider);
        if (vouchers.isNotEmpty) {
          for (String voucherId in vouchers) {
            final removeResult =
                await updateVoucherOwnerUseCase(voucherId, userId, false);
            removeResult.fold(
              (failure) => throw Exception(
                  'Failed to update voucher: ${failure.message}'),
              (_) => debugPrint(
                  'Removed userId $userId from ownerVoucherIds for voucher $voucherId'),
            );
          }
        }

        final getVouchersByLaundryIdUseCase =
            ref.read(voucher_provider.getVouchersByLaundryIdUseCaseProvider);
        final voucherResult =
            await getVouchersByLaundryIdUseCase(currentUser.uid);
        List<Voucher> laundryVouchers = voucherResult.fold(
          (failure) =>
              throw Exception('Failed to fetch vouchers: ${failure.message}'),
          (vouchers) => vouchers,
        );

        final List<String> assignedVoucherNames = [];
        for (final voucher in laundryVouchers) {
          if (voucher.validityPeriod != null &&
              voucher.validityPeriod!.isBefore(DateTime.now())) {
            continue;
          }

          final isEligible =
              await VoucherObtainMethodChecker.isOrderEligibleForVoucher(
            order: order,
            voucher: VoucherModel.fromEntity(voucher),
            userId: userId,
          );

          if (isEligible) {
            final result =
                await updateVoucherOwnerUseCase(voucher.id, userId, true);
            result.fold(
              (failure) => throw Exception(
                  'Failed to update voucher: ${failure.message}'),
              (_) {
                debugPrint(
                    'Added userId $userId to ownerVoucherIds for voucher ${voucher.id}');
                assignedVoucherNames.add(voucher.name);
              },
            );
          }
        }

        await ref
            .read(voucher_provider.voucherListProvider(userId).notifier)
            .refresh();

        if (mounted) {
          _weightController.removeListener(_debouncedUpdatePrediction);
          _clothesController.removeListener(_debouncedUpdatePrediction);
          _laundrySpeedController.removeListener(_debouncedUpdatePrediction);

          _uniqueNameController.clear();
          _weightController.clear();
          _clothesController.clear();
          _laundrySpeedController.clear();
          _vouchersController.clear();

          ref
              .read(order_provider.orderNotifierProvider.notifier)
              .resetPrediction();
          ref.read(order_provider.orderNotifierProvider);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Order successfully created${assignedVoucherNames.isNotEmpty ? ". Voucher(s) assigned: ${assignedVoucherNames.join(", ")}" : ""}',
              ),
              backgroundColor: BackgroundColors.success,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) {
            GoRouter.of(context).go('/manage-orders-screen');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create order: $e'),
              backgroundColor: BackgroundColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isConfirmButtonLocked = false;
          });
        }
      }
    }
  }

  void _debouncedUpdatePrediction() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _updatePrediction();
    });
  }

  void _updatePrediction() {
    final weightText = _weightController.text;
    final clothesText = _clothesController.text;
    final laundrySpeed = _laundrySpeedController.text;

    if (weightText.isEmpty || clothesText.isEmpty || laundrySpeed.isEmpty) {
      return;
    }

    final weight = double.tryParse(weightText) ?? 0.0;
    final clothes = int.tryParse(clothesText) ?? 0;
    if (weight > 0 && clothes > 0) {
      ref
          .read(order_provider.orderNotifierProvider.notifier)
          .predictCompletionTime(
            weight: weight,
            clothes: clothes,
            laundrySpeed: laundrySpeed,
          );
    }
  }

  double _calculateTotalPrice(
      dynamic user, double weight, String laundrySpeed, List<String> vouchers) {
    final regulerPrice = user.regulerPrice.toDouble();
    final expressPrice = user.expressPrice.toDouble();
    double basePrice = laundrySpeed == 'Express' ? expressPrice : regulerPrice;
    double calculatedPrice = weight * basePrice;

    if (vouchers.isNotEmpty && _selectedVoucherId != null) {
      final voucherAsync = ref.watch(voucherByIdProvider(_selectedVoucherId!));
      return voucherAsync.when(
        data: (voucher) {
          if (voucher.validityPeriod != null &&
              voucher.validityPeriod!.isBefore(DateTime.now())) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Selected voucher has expired'),
                  backgroundColor: BackgroundColors.error,
                ),
              );
              _vouchersController.clear();
              _selectedVoucherId = null;
            }
            return weight * basePrice;
          } else if (voucher.type == 'Free Laundry') {
            double effectiveWeight = weight - voucher.amount;
            if (effectiveWeight < 0) effectiveWeight = 0;
            return effectiveWeight * basePrice;
          } else if (voucher.type == 'Discount') {
            return calculatedPrice * (1 - (voucher.amount / 100));
          }
          return calculatedPrice;
        },
        error: (e, _) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load voucher: $e')),
            );
          }
          return weight * basePrice;
        },
        loading: () => weight * basePrice,
      );
    }
    return calculatedPrice;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _weightController.removeListener(_debouncedUpdatePrediction);
    _clothesController.removeListener(_debouncedUpdatePrediction);
    _laundrySpeedController.removeListener(_debouncedUpdatePrediction);
    _uniqueNameController.dispose();
    _weightController.dispose();
    _clothesController.dispose();
    _laundrySpeedController.dispose();
    _vouchersController.dispose();
    super.dispose();
  }

  void _showCustomerSelectionModal() async {
    if (_isUniqueNameFormLocked) return;

    setState(() {
      _isUniqueNameFormLocked = true;
    });

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => CustomerSelectionPanel(
        onCustomerSelected: (uniqueName, userId) {
          if (mounted) {
            setState(() {
              _uniqueNameController.text = uniqueName;
              _selectedUserId = userId;
              _vouchersController.clear();
              _selectedVoucherId = null;
            });
          }
        },
      ),
    );

    if (mounted) {
      setState(() {
        _isUniqueNameFormLocked = false;
      });
    }
  }

  void _showLaundrySpeedModal() async {
    if (_isLaundrySpeedFormLocked) return;

    final currentUser =
        ref.read(firebaseAuthProvider).currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
      }
      return;
    }

    final weightText = _weightController.text;
    final clothesText = _clothesController.text;

    if (weightText.isEmpty || clothesText.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Enter the weight and number of clothes first')),
        );
      }
      return;
    }

    final weight = double.tryParse(weightText) ?? 0.0;
    final clothes = int.tryParse(clothesText) ?? 0;

    if (weight <= 0 || clothes <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Weight and quantity of clothes must be more than 0')),
        );
      }
      return;
    }

    setState(() {
      _isLaundrySpeedFormLocked = true;
    });

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => LaundrySpeedPanel(
        weight: weight,
        clothes: clothes,
        onSpeedSelected: (speed) {
          if (mounted) {
            setState(() {
              _laundrySpeedController.text = speed;
              _updatePrediction();
            });
          }
        },
      ),
    );

    if (mounted) {
      setState(() {
        _isLaundrySpeedFormLocked = false;
      });
    }
  }

  void _showVoucherSelectionModal(String userId, double? weight) async {
    if (_isVoucherFormLocked) return;

    if (_uniqueNameController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a customer first')),
        );
      }
      return;
    }

    final weightText = _weightController.text;
    final clothesText = _clothesController.text;
    final laundrySpeed = _laundrySpeedController.text;
    if (weightText.isEmpty || clothesText.isEmpty || laundrySpeed.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Please fill in weight, clothes, and laundry speed first')),
        );
      }
      return;
    }

    final currentUser =
        ref.read(firebaseAuthProvider).currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
      }
      return;
    }

    setState(() {
      _isVoucherFormLocked = true;
    });

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => VoucherListPanel(
        userId: userId,
        weight: weight,
        laundryId: currentUser.uid,
        onVoucherSelected: (voucherName, voucherId) {
          if (mounted) {
            setState(() {
              _vouchersController.text = voucherName;
              _selectedVoucherId = voucherId;
              debugPrint('Voucher selected: name=$voucherName, id=$voucherId');
            });
          }
        },
        onClose: () {
          Navigator.pop(context);
        },
      ),
    );

    if (mounted) {
      setState(() {
        _isVoucherFormLocked = false;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    if (days > 0) {
      return '$days Days $hours Hours';
    }
    return '$hours Hours';
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(order_provider.orderNotifierProvider);
    final userState = ref.watch(user_provider.userProvider);

    double totalPrice = 0.0;
    if (userState.user != null) {
      final weightText = _weightController.text;
      final laundrySpeed = _laundrySpeedController.text;
      if (weightText.isNotEmpty && laundrySpeed.isNotEmpty) {
        final weight = double.tryParse(weightText) ?? 0.0;
        totalPrice = _calculateTotalPrice(
          userState.user,
          weight,
          laundrySpeed,
          _selectedVoucherId != null ? [_selectedVoucherId!] : [],
        );
      }
    }

    final numberFormat = NumberFormat("#,##0.00", "id_ID");
    final formattedTotalPrice = numberFormat.format(totalPrice);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: BackgroundColors.transparent,
        shadowColor: BackgroundColors.transparent,
        surfaceTintColor: BackgroundColors.transparent,
        title: Text('Create Order', style: AppTypography.darkAppBarTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: IconSizes.navigationIcon),
          onPressed: () {
            _weightController.removeListener(_debouncedUpdatePrediction);
            _clothesController.removeListener(_debouncedUpdatePrediction);
            _laundrySpeedController.removeListener(_debouncedUpdatePrediction);

            _uniqueNameController.clear();
            _weightController.clear();
            _clothesController.clear();
            _laundrySpeedController.clear();
            _vouchersController.clear();

            ref
                .read(order_provider.orderNotifierProvider.notifier)
                .resetPrediction();
            ref.read(order_provider.orderNotifierProvider);
            GoRouter.of(context).go('/admin-dashboard-screen');
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: PaddingSizes.sectionTitlePadding),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: MarginSizes.medium),
                Text('Let\'s make your order',
                    style: AppTypography.sectionTitle),
                const SizedBox(height: MarginSizes.sectionSpacing),
                Text('Enter customer details to place customer order',
                    style: AppTypography.formInstruction),
                const SizedBox(height: PaddingSizes.formSpacing),
                if (userState.isLoading || userState.user == null)
                  const Center(child: LoadingIndicator())
                else
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextFormField(
                          hintText: 'Select Unique Name',
                          labelText: 'Unique Name',
                          controller: _uniqueNameController,
                          readOnly: true,
                          enabled: !_isUniqueNameFormLocked,
                          onTap: () async {
                            if (mounted) {
                              _showCustomerSelectionModal();
                            }
                          },
                          validator: (value) => value!.isEmpty
                              ? 'Unique name cannot be empty'
                              : null,
                        ),
                        const SizedBox(height: MarginSizes.formFieldSpacing),
                        CustomTextFormField(
                          hintText: 'Input Clothes Weight (kg)',
                          labelText: 'Clothes Weight (kg)',
                          keyboardType: TextInputType.number,
                          controller: _weightController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*$')),
                            MaxValueInputFormatter(100),
                          ],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Clothing weight cannot be empty';
                            }
                            final weight = double.tryParse(value);
                            if (weight == null || weight <= 0) {
                              return 'Weight must be greater than 0';
                            }
                            if (weight > 100) {
                              return 'Weight cannot exceed 100 kg';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: MarginSizes.formFieldSpacing),
                        CustomTextFormField(
                          hintText: 'Input Clothes Quantity',
                          labelText: 'Clothes Quantity',
                          keyboardType: TextInputType.number,
                          controller: _clothesController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Clothing quantity cannot be empty';
                            }
                            final clothes = int.tryParse(value);
                            if (clothes == null || clothes <= 0) {
                              return 'Quantity must be greater than 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: MarginSizes.formFieldSpacing),
                        CustomTextFormField(
                          hintText: 'Select Laundry Speed',
                          labelText: 'Laundry Speed',
                          controller: _laundrySpeedController,
                          readOnly: true,
                          enabled: !_isLaundrySpeedFormLocked,
                          onTap: _showLaundrySpeedModal,
                          validator: (value) => value!.isEmpty
                              ? 'Laundry speed must be selected'
                              : null,
                        ),
                        const SizedBox(height: MarginSizes.formFieldSpacing),
                        CustomTextFormField(
                          hintText: 'Select Voucher',
                          labelText: 'Voucher',
                          controller: _vouchersController,
                          readOnly: true,
                          enabled: !_isVoucherFormLocked,
                          onTap: () async {
                            final weightText = _weightController.text;
                            final weight = double.tryParse(weightText);
                            if (_selectedUserId == null) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please select a customer first')),
                                );
                              }
                              return;
                            }
                            if (mounted) {
                              _showVoucherSelectionModal(
                                  _selectedUserId!, weight);
                            }
                          },
                          validator: (value) => null,
                        ),
                        const SizedBox(height: PaddingSizes.formSpacing),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: PaddingSizes.formSpacing),
                          child: Text(
                            'Total Price: Rp $formattedTotalPrice',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if (orderState.isLoadingPrediction)
                          const Padding(
                            padding: EdgeInsets.only(
                                bottom: PaddingSizes.formSpacing),
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: LoadingIndicator(),
                            ),
                          )
                        else if (orderState.predictedCompletion != null)
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: PaddingSizes.formSpacing),
                            child: Text(
                              'Estimated completion: ${_formatDuration(orderState.predictedCompletion!.difference(DateTime.now()))}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(
                                bottom: PaddingSizes.formSpacing),
                            child: Text(
                              'Estimated completion: Not available',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        CustomButton(
                          text: 'Confirm Order',
                          onPressed: _isConfirmButtonLocked
                              ? null
                              : () {
                                  _createOrder();
                                },
                          isLoading: _isConfirmButtonLocked,
                        ),
                        if (orderState.isLoading && !_isConfirmButtonLocked)
                          const Padding(
                            padding: EdgeInsets.only(
                                top: PaddingSizes.sectionTitlePadding),
                            child: LoadingIndicator(),
                          ),
                        if (orderState.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(
                                top: PaddingSizes.sectionTitlePadding),
                            child: Text(
                              orderState.errorMessage!,
                              style: AppTypography.errorText,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
