// Add this import for logging
import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/button_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/margin_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/padding_sizes.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/app_logo_widget.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/custom_text.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/custom_text_form_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isPasswordVisible = false;

  // Add these state variables
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).resetState();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _submitLoginForm() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      final authState = ref.read(authProvider);

      if (authState.status == AuthStatus.success && mounted) {
        // Log the user's role
        final String role = authState.user!.role;
        debugPrint('Login successful! User role: $role');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login successful!'),
            backgroundColor: BackgroundColors.success,
          ),
        );

        if (mounted) {
          // Navigasi ke SplashScreen dengan parameter tujuan
          if (role == 'Customer') {
            context.go('/splash-screen?next=/user-dashboard-screen');
          } else if (role == 'Worker') {
            context.go('/splash-screen?next=/admin-dashboard-screen');
          } else {
            context.go('/splash-screen?next=/login-screen');
          }
        }
      } else if (authState.status == AuthStatus.error &&
          authState.failure != null &&
          mounted) {
        Validators.handleLoginErrors(
          authState.failure!.message,
          (error) => setState(() => _emailError = error),
          (error) => setState(() => _passwordError = error),
        );

        if (_emailError == null && _passwordError == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.failure!.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: MarginSizes.screenEdgeSpacing),
            const AppLogoWidget(),
            const Spacer(),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(PaddingSizes.formOuterPadding),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                          obscureText: !_isPasswordVisible,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: MarginSizes.logoSpacing),
                        authState.status == AuthStatus.loading
                            ? const LoadingIndicator()
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomButton(
                                    width: ButtonSizes.loginButtonWidth,
                                    text: 'Log in',
                                    onPressed:
                                        authState.status == AuthStatus.loading
                                            ? () {}
                                            : _submitLoginForm,
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            CustomText(
              normalText: 'Don\'t have an account? ',
              highlightedText: 'Register',
              onTap: () {
                context.push('/register-screen');
              },
            ),
            const SizedBox(height: MarginSizes.screenEdgeSpacing),
          ],
        ),
      ),
    );
  }
}
