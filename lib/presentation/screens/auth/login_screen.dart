// File: lib/presentation/screens/login_screen.dart
// Berisi tampilan untuk proses login pengguna.
// Menyediakan formulir untuk memasukkan email dan kata sandi, serta navigasi ke layar registrasi.

// Mengimpor package dan file yang diperlukan.
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

// Kelas utama untuk layar login
class LoginScreen extends ConsumerStatefulWidget {
  // Nama rute untuk navigasi
  static const routeName = '/login-screen';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Kunci untuk validasi formulir
  final _formKey = GlobalKey<FormState>();
  // Kontroler untuk input email dan kata sandi
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  // Status visibilitas kata sandi
  bool _isPasswordVisible = false;
  // Variabel untuk menyimpan pesan error
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    // Inisialisasi kontroler
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    // Reset status autentikasi setelah widget dibuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).resetState();
    });
  }

  @override
  void dispose() {
    // Membersihkan kontroler
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Mengubah visibilitas kata sandi
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  // Menangani proses login
  void _submitLoginForm() async {
    if (_formKey.currentState!.validate()) {
      // Memanggil fungsi login dari provider
      await ref.read(authProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      // Mengambil status autentikasi
      final authState = ref.read(authProvider);

      if (authState.status == AuthStatus.success && mounted) {
        // Mendapatkan peran pengguna
        final String role = authState.user!.role;

        // Menampilkan notifikasi login berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login successful!'),
            backgroundColor: BackgroundColors.success,
          ),
        );

        if (mounted) {
          // Navigasi berdasarkan peran pengguna
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
        // Menangani error login
        Validators.handleLoginErrors(
          authState.failure!.message,
          (error) => setState(() => _emailError = error),
          (error) => setState(() => _passwordError = error),
        );

        // Menampilkan pesan error umum jika tidak ada error spesifik
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
    // Mengamati status autentikasi
    final authState = ref.watch(authProvider);

    return Scaffold(
      // Body utama dengan layout aman
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: MarginSizes.screenEdgeSpacing),
            // Menampilkan logo aplikasi
            const AppLogoWidget(),
            const Spacer(),
            // Formulir login dalam scroll view
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(PaddingSizes.formOuterPadding),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Input email
                        CustomTextFormField(
                          controller: _emailController,
                          hintText: 'Input Email',
                          labelText: 'Email',
                          prefixIcon: Icons.email,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: MarginSizes.logoSpacing),
                        // Input kata sandi
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
                        // Menampilkan indikator loading atau tombol login
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
            // Tautan ke layar registrasi
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