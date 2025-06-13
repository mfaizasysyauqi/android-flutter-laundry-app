import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_laundry_app/domain/usecases/order/predict_order_usecase.dart';
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/icon_sizes.dart';

class PredictLaundryScreen extends ConsumerStatefulWidget {
  static const routeName = '/predict-laundry-screen';
  const PredictLaundryScreen({super.key});

  @override
  ConsumerState<PredictLaundryScreen> createState() =>
      _PredictLaundryScreenState();
}

class _PredictLaundryScreenState extends ConsumerState<PredictLaundryScreen> {
  final List<TextEditingController> _controllers =
      List.generate(7, (_) => TextEditingController());

  bool _isLoading = false;
  double? _prediction;

  Future<void> _predict() async {
    setState(() => _isLoading = true);

    try {
      final input = _controllers
          .map((c) => double.tryParse(c.text.trim()) ?? 0.0)
          .toList();

      final usecase = ref.read(predictOrderUseCaseProvider);
      final result = await usecase.predict(input);

      setState(() => _prediction = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Prediksi gagal: $e"),
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BackgroundColors.transparent,
        shadowColor: BackgroundColors.transparent,
        surfaceTintColor: BackgroundColors.transparent,
        title: Text('Predict Order', style: AppTypography.darkAppBarTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: IconSizes.navigationIcon),
          onPressed: () {
            if (mounted) {
              GoRouter.of(context).go('/admin-dashboard-screen');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Let's predict your order",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2227)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Enter the last 7 days orders",
              style: TextStyle(fontSize: 16, color: Color(0xFF606060)),
            ),
            const SizedBox(height: 12),
            for (int i = 0; i < 7; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: _controllers[i],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Hari ke-${i + 1}",
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _predict,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Predict Order for Tomorrow"),
            ),
            const SizedBox(height: 20),
            if (_prediction != null)
              Text(
                "Predict for tomorrow: ${_prediction!.toStringAsFixed(2)} order",
                style: const TextStyle(fontSize: 20),
              ),
          ],
        ),
      ),
    );
  }
}
