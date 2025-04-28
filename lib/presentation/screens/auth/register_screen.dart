import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/style/colors/text_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/button_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/icon_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/padding_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/margin_sizes.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/app_logo_widget.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/custom_text.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/custom_text_form_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  static const routeName = '/register-screen';
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _roleController =
      TextEditingController(text: "Customer");
  final _fullNameController = TextEditingController();
  final _uniqueNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).resetState();
    });
  }

  @override
  void dispose() {
    _roleController.dispose();
    _fullNameController.dispose();
    _uniqueNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _submitRegisterForm() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).register(
            role: _roleController.text.trim(),
            fullName: _fullNameController.text.trim(),
            uniqueName: _uniqueNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            phoneNumber: _phoneNumberController.text.trim(),
            address: _addressController.text.trim(),
          );

      final authState = ref.read(authProvider);

      if (authState.status == AuthStatus.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration successful! Please log in.',
              style: AppTypography.buttonText
                  .copyWith(color: TextColors.lightText),
            ),
            backgroundColor: BackgroundColors.success,
          ),
        );

        if (mounted) {
          // Navigate to LoginScreen after successful registration
          context.go('/login-screen');
        }
      } else if (authState.status == AuthStatus.error &&
          authState.failure != null &&
          mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.failure!.message,
                style: AppTypography.errorText),
            backgroundColor: BackgroundColors.error,
          ),
        );
      }
    }
  }

  void _showRoleSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      size: IconSizes.navigationIcon,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Select Role',
                    style: AppTypography.modalTitle,
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              ListTile(
                leading: Icon(Icons.person, size: IconSizes.formIcon),
                title: Text('Customer', style: AppTypography.label),
                onTap: () {
                  setState(() {
                    _roleController.text = 'Customer';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.work, size: IconSizes.formIcon),
                title: Text('Worker', style: AppTypography.label),
                onTap: () {
                  setState(() {
                    _roleController.text = 'Worker';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: MarginSizes.screenEdgeSpacing),
            const AppLogoWidget(),
            const SizedBox(height: MarginSizes.screenEdgeSpacing),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(PaddingSizes.formPadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextFormField(
                          controller: _roleController,
                          hintText: 'Select Role',
                          labelText: 'Role',
                          prefixIcon: Icons.manage_accounts,
                          suffixIcon: Icon(Icons.arrow_drop_down,
                              size: IconSizes.formIcon),
                          readOnly: true,
                          onTap: _showRoleSelection,
                          validator: Validators.validateRole,
                        ),
                        const SizedBox(height: MarginSizes.logoSpacing),
                        CustomTextFormField(
                          controller: _fullNameController,
                          hintText: _roleController.text == 'Worker'
                              ? 'Input Laundry Name'
                              : 'Input Full Name',
                          labelText: _roleController.text == 'Worker'
                              ? 'Laundry Name'
                              : 'Full Name',
                          prefixIcon: Icons.person,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validateFullName,
                        ),
                        const SizedBox(height: MarginSizes.logoSpacing),
                        CustomTextFormField(
                          controller: _uniqueNameController,
                          hintText: 'Input Unique Name',
                          labelText: 'Unique Name',
                          prefixIcon: Icons.badge,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validateUniqueName,
                        ),
                        const SizedBox(height: MarginSizes.logoSpacing),
                        CustomTextFormField(
                          controller: _emailController,
                          hintText: 'Input Email',
                          labelText: 'Email',
                          prefixIcon: Icons.email,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: MarginSizes.logoSpacing),
                        CustomTextFormField(
                          controller: _passwordController,
                          hintText: 'Input Password',
                          labelText: 'Password',
                          prefixIcon: Icons.password,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: IconSizes.formIcon,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                          obscureText: !_isPasswordVisible,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: MarginSizes.logoSpacing),
                        CustomTextFormField(
                          controller: _phoneNumberController,
                          hintText: 'Input WhatsApp Number',
                          labelText: 'WhatsApp Number',
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          validator: Validators.validatePhoneNumber,
                        ),
                        const SizedBox(height: MarginSizes.logoSpacing),
                        authState.status == AuthStatus.loading
                            ? const LoadingIndicator()
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomButton(
                                    width: ButtonSizes.registerButtonWidth,
                                    text: 'Register',
                                    onPressed: _submitRegisterForm,
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: MarginSizes.screenEdgeSpacing),
            CustomText(
              normalText: 'Already have an account? ',
              highlightedText: 'Log in',
              onTap: () {
                context.push('/login-screen');
              },
            ),
            const SizedBox(height: MarginSizes.screenEdgeSpacing),
          ],
        ),
      ),
    );
  }
}
