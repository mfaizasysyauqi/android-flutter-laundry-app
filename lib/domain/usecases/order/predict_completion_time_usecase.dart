import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/core/utils/date_estimator.dart';
import 'package:flutter_laundry_app/data/models/order_model.dart';
import 'package:flutter_laundry_app/domain/repositories/order_repository.dart';

class PredictCompletionTimeUseCase {
  final OrderRepository repository;
  static bool _isProcessing = false;
  static List<dynamic>? _cachedActiveOrders;
  static final _lock = Completer<void>.sync();

  static const List<double> scalerMin = [5.0, 0.0, 0.0, 0.0, 5.0, 0.0];
  static const List<double> scalerMax = [100.0, 1.0, 15.0, 6.0, 100.0, 144.0];

  PredictCompletionTimeUseCase(this.repository);

  Future<double> _getAverageCompletionTime(String laundryUniqueName) async {
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

    final averageHours = count > 0 ? totalHours / count : 0.0;
    return averageHours;
  }

  Future<List<dynamic>> _getActiveOrdersWithCache() async {
    if (_cachedActiveOrders == null) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user is signed in');

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (!userDoc.exists) throw Exception('User document not found');

      final currentUserUniqueName = userDoc.data()?['uniqueName'];
      if (currentUserUniqueName == null) {
        throw Exception('User uniqueName not found');
      }

      var allOrders = await repository.getActiveOrders();
      _cachedActiveOrders = allOrders
          .where((order) => order.laundryUniqueName == currentUserUniqueName)
          .toList();
    }
    return _cachedActiveOrders!;
  }

  Future<Either<Failure, DateTime>> call(OrderModel order) async {
    if (_isProcessing) {
      await _lock.future;
    }
    _isProcessing = true;
    final completer = Completer<void>();
    if (!_lock.isCompleted) _lock.complete(completer.future);

    try {
      final activeOrders = await _getActiveOrdersWithCache();
      final avgCompletionHours =
          await _getAverageCompletionTime(order.laundryUniqueName);

      final estimatedCompletion =
          await DateEstimator.calculateEstimatedCompletionWithAI(
        order.laundrySpeed,
        order.weight,
        order.clothes.toDouble(),
        activeOrders.length,
        order.createdAt.weekday,
        avgCompletionHours,
      );

      return Right(estimatedCompletion);
    } catch (e) {
      _cachedActiveOrders = null;
      final estimatedCompletion = DateEstimator.calculateEstimatedCompletion(
        order.laundrySpeed,
        order.weight,
      );
      return Right(estimatedCompletion);
    } finally {
      _isProcessing = false;
      completer.complete();
    }
  }
}