// File: lib/presentation/screens/register_screen.dart
// Berisi tampilan untuk proses registrasi pengguna.
// Menyediakan formulir untuk memasukkan peran, nama, email, kata sandi, nomor telepon, dan alamat.

// Mengimpor package dan file yang diperlukan.
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

// Kelas utama untuk layar registrasi
class RegisterScreen extends ConsumerStatefulWidget {
  // Nama rute untuk navigasi
  static const routeName = '/register-screen';
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Kunci untuk validasi formulir
  final _formKey = GlobalKey<FormState>();
  // Kontroler untuk input formulir
  final TextEditingController _roleController =
      TextEditingController(text: "Customer");
  final _fullNameController = TextEditingController();
  final _uniqueNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  // Status visibilitas kata sandi
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Reset status autentikasi setelah widget dibuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).resetState();
    });
  }

  @override
  void dispose() {
    // Membersihkan kontroler
    _roleController.dispose();
    _fullNameController.dispose();
    _uniqueNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Mengubah visibilitas kata sandi
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  // Menangani proses registrasi
  void _submitRegisterForm() async {
    if (_formKey.currentState!.validate()) {
      // Memanggil fungsi registrasi dari provider
      await ref.read(authProvider.notifier).register(
            role: _roleController.text.trim(),
            fullName: _fullNameController.text.trim(),
            uniqueName: _uniqueNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            phoneNumber: _phoneNumberController.text.trim(),
            address: _addressController.text.trim(),
          );

      // Mengambil status autentikasi
      final authState = ref.read(authProvider);

      if (authState.status == AuthStatus.success && mounted) {
        // Menampilkan notifikasi registrasi berhasil
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

        // Navigasi ke layar login
        if (mounted) {
          context.go('/login-screen');
        }
      } else if (authState.status == AuthStatus.error &&
          authState.failure != null &&
          mounted) {
        // Menampilkan pesan error jika registrasi gagal
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

  // Menampilkan modal untuk memilih peran
  void _showRoleSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header modal
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
              // Opsi peran pelanggan
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
              // Opsi peran pekerja
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
    // Mengamati status autentikasi
    final authState = ref.watch(authProvider);

    return Scaffold(
      // Body utama dengan layout aman
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: MarginSizes.screenEdgeSpacing),
            // Menampilkan logo aplikasi
            const AppLogoWidget(),
            const SizedBox(height: MarginSizes.screenEdgeSpacing),
            // Formulir registrasi dalam scroll view
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(PaddingSizes.formPadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Input peran
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
                        // Input nama lengkap atau nama laundry
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
                        // Input nama unik
                        CustomTextFormField(
                          controller: _uniqueNameController,
                          hintText: 'Input Unique Name',
                          labelText: 'Unique Name',
                          prefixIcon: Icons.badge,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validateUniqueName,
                        ),
                        const SizedBox(height: MarginSizes.logoSpacing),
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
                              size: IconSizes.formIcon,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                          obscureText: !_isPasswordVisible,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: MarginSizes.logoSpacing),
                        // Input nomor WhatsApp
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
                        // Menampilkan indikator loading atau tombol registrasi
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
            // Tautan ke layar login
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
