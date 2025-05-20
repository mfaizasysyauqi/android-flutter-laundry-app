// File: lib/presentation/widgets/panel/laundry_speed_panel.dart
// Berisi panel untuk memilih kecepatan laundry dengan prediksi waktu selesai.
// Digunakan pada proses pembuatan pesanan.

// Mengimpor package dan file yang diperlukan.
import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/data/models/order_model.dart';
import 'package:flutter_laundry_app/presentation/providers/order_provider.dart'
    as order_provider;
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/icon_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/margin_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/padding_sizes.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/loading_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Widget panel untuk memilih kecepatan laundry
class LaundrySpeedPanel extends ConsumerWidget {
  // Berat pakaian
  final double weight;
  // Jumlah pakaian
  final int clothes;
  // Fungsi saat kecepatan dipilih
  final Function(String) onSpeedSelected;

  // Konstruktor dengan parameter wajib
  const LaundrySpeedPanel({
    super.key,
    required this.weight,
    required this.clothes,
    required this.onSpeedSelected,
  });

  // Mendapatkan prediksi waktu selesai
  Future<Map<String, DateTime?>> _getRealTimePredictions(
      WidgetRef ref, double weight, int clothes) async {
    final predictUseCase =
        ref.read(order_provider.predictCompletionTimeUseCaseProvider);

    // Model pesanan untuk Express
    final expressOrder = OrderModel(
      id: '',
      laundryUniqueName: '',
      customerUniqueName: '',
      weight: weight,
      clothes: clothes,
      laundrySpeed: 'Express',
      vouchers: [],
      totalPrice: 0.0,
      status: 'pending',
      createdAt: DateTime.now(),
      estimatedCompletion: DateTime.now(),
      isHistory: false,
    );

    // Model pesanan untuk Reguler
    final regulerOrder = expressOrder.copyWith(laundrySpeed: 'Reguler');

    final expressResult = await predictUseCase(expressOrder);
    final regulerResult = await predictUseCase(regulerOrder);

    return {
      'Express': expressResult.fold((l) => null, (r) => r),
      'Reguler': regulerResult.fold((l) => null, (r) => r),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(PaddingSizes.formOuterPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header panel
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left,
                        size: IconSizes.navigationIcon),
                    onPressed: () {
                      Navigator.pop(context); // Tutup panel
                    },
                  ),
                  Text('Select Laundry Speed', style: AppTypography.modalTitle),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: MarginSizes.medium),
              // Konten prediksi
              FutureBuilder<Map<String, DateTime?>>(
                future: _getRealTimePredictions(ref, weight, clothes),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: LoadingIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Text('Failed to load estimated time');
                  }

                  final predictions = snapshot.data ?? {};
                  final expressTime = predictions['Express'];
                  final regulerTime = predictions['Reguler'];

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Express (High Priority)'),
                        subtitle: Text(expressTime != null
                            ? 'AI Estimate: ${expressTime.difference(DateTime.now()).inHours} Hours'
                            : 'AI Cannot predict'),
                        onTap: () {
                          onSpeedSelected('Express');
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: MarginSizes.small),
                      ListTile(
                        title: const Text('Regular (Standard)'),
                        subtitle: Text(regulerTime != null
                            ? 'AI Estimate: ${regulerTime.difference(DateTime.now()).inHours} Hours'
                            : 'AI Cannot predict'),
                        onTap: () {
                          onSpeedSelected('Reguler');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}