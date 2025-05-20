// File: lib/domain/usecases/order/predict_completion_time_usecase.dart
// Berisi use case untuk memprediksi waktu penyelesaian pesanan.

// Mengimpor package dan file yang diperlukan.
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/core/utils/date_estimator.dart';
import 'package:flutter_laundry_app/data/models/order_model.dart';
import 'package:flutter_laundry_app/domain/repositories/order_repository.dart';

// Kelas PredictCompletionTimeUseCase untuk memprediksi waktu penyelesaian.
class PredictCompletionTimeUseCase {
  final OrderRepository repository;
  static bool _isProcessing = false;
  static List<dynamic>? _cachedActiveOrders;
  static final _lock = Completer<void>.sync();

  // Konstanta untuk normalisasi data (scaler).
  static const List<double> scalerMin = [5.0, 0.0, 0.0, 0.0, 5.0, 0.0];
  static const List<double> scalerMax = [100.0, 1.0, 15.0, 6.0, 100.0, 144.0];

  // Konstruktor yang menerima repository.
  PredictCompletionTimeUseCase(this.repository);

  // Method untuk menghitung rata-rata waktu penyelesaian berdasarkan pesanan selesai.
  Future<double> _getAverageCompletionTime(String laundryUniqueName) async {
    // Ambil pesanan selesai dari Firestore.
    final completedOrders = await FirebaseFirestore.instance
        .collection('orders')
        .where('laundryUniqueName', isEqualTo: laundryUniqueName)
        .where('status', isEqualTo: 'completed')
        .where('completedAt', isNotEqualTo: null)
        .get();

    if (completedOrders.docs.isEmpty) return 0.0;

    double totalHours = 0.0;
    int count = 0;
    for (var doc in completedOrders.docs) {
      final order = OrderModel.fromJson(doc.data(), doc.id);
      if (order.completedAt != null) {
        final duration = order.completedAt!.difference(order.createdAt);
        totalHours += duration.inHours.toDouble();
        count++;
      }
    }

    // Hitung rata-rata waktu penyelesaian.
    final averageHours = count > 0 ? totalHours / count : 0.0;
    return averageHours;
  }

  // Method untuk mendapatkan pesanan aktif dengan caching.
  Future<List<dynamic>> _getActiveOrdersWithCache() async {
    if (_cachedActiveOrders == null) {
      // Periksa apakah pengguna saat ini terautentikasi.
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user is signed in');

      // Ambil data pengguna dari Firestore.
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (!userDoc.exists) throw Exception('User document not found');

      final currentUserUniqueName = userDoc.data()?['uniqueName'];
      if (currentUserUniqueName == null) {
        throw Exception('User uniqueName not found');
      }

      // Ambil pesanan aktif dan simpan ke cache.
      var allOrders = await repository.getActiveOrders();
      _cachedActiveOrders = allOrders
          .where((order) => order.laundryUniqueName == currentUserUniqueName)
          .toList();
    }
    return _cachedActiveOrders!;
  }

  // Method utama untuk memprediksi waktu penyelesaian.
  Future<Either<Failure, DateTime>> call(OrderModel order) async {
    // Cegah pemrosesan bersamaan dengan lock.
    if (_isProcessing) {
      await _lock.future;
    }
    _isProcessing = true;
    final completer = Completer<void>();
    if (!_lock.isCompleted) _lock.complete(completer.future);

    try {
      // Ambil pesanan aktif dan rata-rata waktu penyelesaian.
      final activeOrders = await _getActiveOrdersWithCache();
      final avgCompletionHours =
          await _getAverageCompletionTime(order.laundryUniqueName);

      // Hitung estimasi waktu penyelesaian dengan AI.
      final estimatedCompletion =
          await DateEstimator.calculateEstimatedCompletionWithAI(
        order.laundrySpeed,
        order.weight,
        order.clothes.toDouble(),
        activeOrders.length,
        order.createdAt.weekday,
        avgCompletionHours,
      );

      // Kembalikan hasil sukses sebagai Right.
      return Right(estimatedCompletion);
    } catch (e) {
      // Jika gagal, hapus cache dan gunakan estimasi sederhana.
      _cachedActiveOrders = null;
      final estimatedCompletion = DateEstimator.calculateEstimatedCompletion(
        order.laundrySpeed,
        order.weight,
      );
      return Right(estimatedCompletion);
    } finally {
      // Selesaikan pemrosesan dan buka lock.
      _isProcessing = false;
      completer.complete();
    }
  }
}