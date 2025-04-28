import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_laundry_app/core/error/exceptions.dart';
import 'package:flutter_laundry_app/data/models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder(OrderModel order);
  Future<List<OrderModel>> getActiveOrders();
  Future<List<OrderModel>> getOrdersByUserIdOrLaundryIdAndStatus(
      String userId, String status);
  Future<List<OrderModel>> getHistoryOrdersByUserId(String userId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseFirestore firestore;
  final firebase_auth.FirebaseAuth firebaseAuth;

  OrderRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException(message: 'User not authenticated');
      }

      final orderRef = firestore.collection('orders').doc(order.id);
      await orderRef.set(order.toMap());
      return order;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<OrderModel>> getActiveOrders() async {
    try {
      final snapshot = await firestore
          .collection('orders')
          .where('status', isEqualTo: 'active')
          .get();
      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<OrderModel>> getOrdersByUserIdOrLaundryIdAndStatus(
      String userId, String status) async {
    try {
      final customerSnapshot = await firestore
          .collection('orders')
          .where('customerUniqueName', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .get();

      final laundrySnapshot = await firestore
          .collection('orders')
          .where('laundryUniqueName', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .get();

      final allDocs = {...customerSnapshot.docs, ...laundrySnapshot.docs};
      return allDocs
          .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<OrderModel>> getHistoryOrdersByUserId(String userId) async {
    try {
      final userDoc = await firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw ServerException(message: 'User document does not exist');
      }
      final userData = userDoc.data() as Map<String, dynamic>;
      final uniqueName = userData['uniqueName'];

      Query<Map<String, dynamic>> query =
          firestore.collection('orders').where('isHistory', isEqualTo: true);

      final customerSnapshot =
          await query.where('customerUniqueName', isEqualTo: uniqueName).get();

      final laundrySnapshot =
          await query.where('laundryUniqueName', isEqualTo: uniqueName).get();

      final allDocs = {...customerSnapshot.docs, ...laundrySnapshot.docs};
      return allDocs
          .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}