import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/providers/auth_provider.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/app_logo_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const routeName = '/splash-screen';
  final String? nextRoute;

  const SplashScreen({super.key, this.nextRoute});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
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
    _controller.forward();
    _navigateAfterDelay();
  }

  void _navigateAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _handleNavigation();
      }
    });
  }

  void _handleNavigation() {
    final authState = ref.read(authProvider);
    String destination;

    if (widget.nextRoute != null) {
      destination = widget.nextRoute!;
    } else if (authState.status == AuthStatus.success &&
        authState.user != null) {
      destination = authState.user!.role == 'Customer'
          ? '/user-dashboard-screen'
          : '/admin-dashboard-screen';
    } else {
      destination = '/login-screen';
    }

    if (mounted) {
      context.go(destination);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColors.splashBackground,
      body: Center(
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
