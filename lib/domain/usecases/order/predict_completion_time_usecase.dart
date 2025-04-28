import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/data/models/order_model.dart';
import 'package:flutter_laundry_app/domain/repositories/order_repository.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class PredictCompletionTimeUseCase {
  final OrderRepository repository;
  static bool _isProcessing = false;
  static List<dynamic>? _cachedActiveOrders;
  static final _lock = Completer<void>.sync();

  // Scaler disesuaikan dengan rentang data Python
  static const List<double> scalerMin = [5.0, 0.0, 0.0, 0.0, 5.0, 0.0];
  static const List<double> scalerMax = [
    100.0,
    1.0,
    15.0,
    6.0,
    100.0,
    144.0
  ]; // Max avgCompletionHours = 144

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

  List<List<double>> _normalizeInput(List<List<double>> input) {
    List<List<double>> normalizedInput = [];
    for (var row in input) {
      List<double> normalizedRow = [];
      for (int i = 0; i < row.length; i++) {
        double normalizedValue =
            (row[i] - scalerMin[i]) / (scalerMax[i] - scalerMin[i]);
        normalizedValue = normalizedValue.clamp(0.0, 1.0);
        normalizedRow.add(normalizedValue);
      }
      normalizedInput.add(normalizedRow);
    }
    return normalizedInput;
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

      final input = [
        [
          order.weight,
          order.laundrySpeed.toLowerCase() == 'express' ? 1.0 : 0.0,
          activeOrders.length.toDouble(),
          order.createdAt.weekday.toDouble(),
          order.clothes.toDouble(),
          avgCompletionHours,
        ]
      ];

      final normalizedInput = _normalizeInput(input);

      final customModel = await FirebaseModelDownloader.instance.getModel(
        'laundry_completion_model',
        FirebaseModelDownloadType.latestModel,
      );

      final interpreter = Interpreter.fromFile(customModel.file);

      final output = List.filled(1, 0.0).reshape([1, 1]);
      interpreter.run(normalizedInput, output);

      final predictedDays = output[0][0];

      final predictedHours = (predictedDays * 24).toInt();

      if (predictedHours < 0) {
        throw Exception('Negative prediction from model');
      }

      final result = order.createdAt.add(Duration(hours: predictedHours));
      return Right(result);
    } catch (e) {
      _cachedActiveOrders = null;
      final activeOrders = await repository.getActiveOrders();

      int days = 1;
      if (order.laundrySpeed.toLowerCase() == 'express') {
        days += (order.weight / 20).ceil();
      } else {
        days += (order.weight / 10).ceil();
      }
      days += (activeOrders.length / 5).ceil();

      final result = order.createdAt.add(Duration(days: days));
      return Right(result);
    } finally {
      _isProcessing = false;
      completer.complete();
    }
  }
}
