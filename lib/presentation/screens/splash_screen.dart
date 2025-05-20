// File: lib/presentation/screens/splash_screen.dart
// Berisi tampilan splash screen saat aplikasi dimulai.
// Menampilkan logo aplikasi dengan animasi dan menangani navigasi berdasarkan status autentikasi.

// Mengimpor package dan file yang diperlukan.
import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/providers/auth_provider.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/app_logo_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Kelas utama untuk layar splash
class SplashScreen extends ConsumerStatefulWidget {
  // Nama rute untuk navigasi
  static const routeName = '/splash-screen';
  // Rute tujuan setelah splash screen
  final String? nextRoute;

  const SplashScreen({super.key, this.nextRoute});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Kontroler untuk animasi
  late AnimationController _controller;
  // Animasi untuk efek fade
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Inisialisasi animasi
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    // Memulai animasi
    _controller.forward();
    // Menangani navigasi setelah penundaan
    _navigateAfterDelay();
  }

  // Menunda navigasi selama 2 detik
  void _navigateAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _handleNavigation();
      }
    });
  }

  // Menangani navigasi berdasarkan status autentikasi
  void _handleNavigation() {
    final authState = ref.read(authProvider);
    String destination;

    // Jika ada rute tujuan, gunakan rute tersebut
    if (widget.nextRoute != null) {
      destination = widget.nextRoute!;
    } else if (authState.status == AuthStatus.success &&
        authState.user != null) {
      // Navigasi berdasarkan peran pengguna
      destination = authState.user!.role == 'Customer'
          ? '/user-dashboard-screen'
          : '/admin-dashboard-screen';
    } else {
      // Jika tidak terautentikasi, arahkan ke layar login
      destination = '/login-screen';
    }

    if (mounted) {
      context.go(destination);
    }
  }

  @override
  void dispose() {
    // Membersihkan kontroler animasi
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Latar belakang splash screen
      backgroundColor: BackgroundColors.splashBackground,
      body: Center(
        // Animasi fade untuk logo
        child: FadeTransition(
          opacity: _animation,
          child: AppLogoWidget(
            size: 100,
            appName: 'LaundryGo',
          ),
        ),
      ),
    );
  }
}
