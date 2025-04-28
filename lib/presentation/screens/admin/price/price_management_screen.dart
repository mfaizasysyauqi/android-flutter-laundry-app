import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/margin_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/padding_sizes.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/custom_button.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/custom_text_form_field.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/loading_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../../providers/user_provider.dart';

class PriceManagementScreen extends ConsumerStatefulWidget {
  static const routeName = '/price-management-screen';
  const PriceManagementScreen({super.key});

  @override
  ConsumerState<PriceManagementScreen> createState() =>
      _PriceManagementScreenState();
}

class _PriceManagementScreenState extends ConsumerState<PriceManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _regulerPriceController = TextEditingController();
  final TextEditingController _expressPriceController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialPrice();
    });
  }

  Future<void> _loadInitialPrice() async {
    final userState = ref.read(userProvider);
    final firebaseAuth = FirebaseAuth.instance;
    if (firebaseAuth.currentUser == null) {
      setState(() {
        _errorMessage = 'Please log in to manage prices.';
      });
      return;
    }

    if (userState.user != null) {
      setState(() {
        _regulerPriceController.text = userState.user!.regulerPrice.toString();
        _expressPriceController.text = userState.user!.expressPrice.toString();
      });
    } else {
      setState(() => _isLoading = true);
      try {
        await ref.read(userProvider.notifier).getUser();
        final updatedUser = ref.read(userProvider).user;
        if (updatedUser != null) {
          setState(() {
            _regulerPriceController.text = updatedUser.regulerPrice.toString();
            _expressPriceController.text = updatedUser.expressPrice.toString();
          });
        } else {
          setState(() {
            _errorMessage = 'No user data found after fetch.';
          });
        }
      } catch (e) {
        developer.log('Error loading price: $e');
        setState(() {
          _errorMessage =
              'Failed to load current price. Please try again. Details: $e';
        });
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _regulerPriceController.dispose();
    _expressPriceController.dispose();
    super.dispose();
  }

  Future<void> _updatePrice() async {
    if (_formKey.currentState!.validate()) {
      final newRegulerPrice = int.parse(_regulerPriceController.text);
      final newExpressPrice = int.parse(_expressPriceController.text);

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await ref
            .read(userProvider.notifier)
            .updateLaundryPrice(newRegulerPrice, newExpressPrice);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Prices updated successfully'),
              backgroundColor: BackgroundColors.success,
            ),
          );
          context.go('/admin-dashboard-screen');
        }
      } catch (e) {
        developer.log('Error updating price: $e');
        setState(() {
          _errorMessage =
              'Failed to update prices. Please try again. Details: $e';
        });
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    if (int.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BackgroundColors.transparent,
        shadowColor: BackgroundColors.transparent,
        surfaceTintColor: BackgroundColors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/admin-dashboard-screen');
          },
        ),
        title: Text(
          'Edit Price',
          style: AppTypography.darkAppBarTitle,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(
              PaddingSizes.cardPadding), // Updated from medium
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Laundry Price Per Kg',
                  style: AppTypography.formTitle,
                ),
                const SizedBox(height: MarginSizes.small),
                Text(
                  'Easily adjust the laundry price per kilogram',
                  style: AppTypography.formSubtitle,
                ),
                const SizedBox(height: MarginSizes.formSpacing),
                CustomTextFormField(
                  hintText: 'Enter regular price per kg',
                  labelText: 'Regular Price Per Kg...',
                  controller: _regulerPriceController,
                  prefixIcon: Icons.monetization_on_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: _validatePrice,
                ),
                const SizedBox(height: MarginSizes.formFieldSpacing),
                CustomTextFormField(
                  hintText: 'Enter express price per kg',
                  labelText: 'Express Price Per Kg...',
                  controller: _expressPriceController,
                  prefixIcon: Icons.monetization_on_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: _validatePrice,
                ),
                const SizedBox(height: MarginSizes.formSpacing),
                if (_isLoading)
                  const Center(child: LoadingIndicator())
                else
                  CustomButton(
                    text: 'Edit Prices',
                    onPressed: _updatePrice,
                    width: double.infinity,
                  ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(
                        top: PaddingSizes
                            .sectionTitlePadding), // Updated from medium
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.errorText,
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
