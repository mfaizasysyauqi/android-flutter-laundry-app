import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:dartz/dartz.dart';
import 'package:flutter_laundry_app/core/error/exceptions.dart';
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/core/network/network_info.dart';
import 'package:flutter_laundry_app/data/datasources/remote/order_remote_data_source.dart';
import 'package:flutter_laundry_app/data/models/order_model.dart';
import 'package:flutter_laundry_app/domain/entities/order.dart' as domain;
import 'package:flutter_laundry_app/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final firestore.FirebaseFirestore _firestore;
  final OrderRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OrderRepositoryImpl({
    required firestore.FirebaseFirestore firestore,
    required this.remoteDataSource,
    required this.networkInfo,
  }) : _firestore = firestore;

  @override
  Future<Either<Failure, void>> createOrder(domain.Order order) async {
    if (await networkInfo.isConnected) {
      try {
        final orderModel = OrderModel(
          id: order.id,
          laundryUniqueName: order.laundryUniqueName,
          customerUniqueName: order.customerUniqueName,
          weight: order.weight,
          clothes: order.clothes,
          laundrySpeed: order.laundrySpeed,
          vouchers: order.vouchers,
          status: order.status,
          totalPrice: order.totalPrice,
          createdAt: order.createdAt,
          estimatedCompletion: order.estimatedCompletion,
          completedAt: order.completedAt,
          cancelledAt: order.cancelledAt,
          updatedAt: order.updatedAt,
          isHistory: order.isHistory,
        );
        await remoteDataSource.createOrder(orderModel);
        return const Right(null);
      } catch (e) {
        return Left(OrderFailure(message: 'Failed to create order: $e'));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<domain.Order>>> getOrders() async {
    if (await networkInfo.isConnected) {
      try {
        final querySnapshot = await _firestore.collection('orders').get();
        final orders = querySnapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
            .toList();
        return Right(orders);
      } on firestore.FirebaseException catch (e) {
        return Left(
            ServerFailure(message: e.message ?? 'Failed to fetch orders'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<domain.Order>>> getOrdersByStatus(
      String status) async {
    if (await networkInfo.isConnected) {
      try {
        final querySnapshot = await _firestore
            .collection('orders')
            .where('status', isEqualTo: status)
            .get();
        final orders = querySnapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
            .toList();
        return Right(orders);
      } on firestore.FirebaseException catch (e) {
        return Left(
            ServerFailure(message: e.message ?? 'Failed to fetch orders'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, domain.Order>> updateOrderStatus(
      String orderId, String newStatus) async {
    if (await networkInfo.isConnected) {
      try {
        await _firestore.collection('orders').doc(orderId).update({
          'status': newStatus,
          'updatedAt': firestore.FieldValue.serverTimestamp(),
        });

        final docSnapshot =
            await _firestore.collection('orders').doc(orderId).get();
        if (!docSnapshot.exists) {
          return Left(ServerFailure(message: 'Order not found'));
        }

        final updatedOrder =
            OrderModel.fromJson(docSnapshot.data()!, docSnapshot.id);
        return Right(updatedOrder);
      } on firestore.FirebaseException catch (e) {
        return Left(ServerFailure(
            message: e.message ?? 'Failed to update order status'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatusAndCompletion(
      String orderId, String newStatus) async {
    if (await networkInfo.isConnected) {
      try {
        final updateData = {
          'status': newStatus,
          'updatedAt': firestore.FieldValue.serverTimestamp(),
          if (newStatus == 'completed')
            'completedAt': firestore.FieldValue.serverTimestamp(),
          if (newStatus == 'cancelled')
            'cancelledAt': firestore.FieldValue.serverTimestamp(),
        };

        await _firestore.collection('orders').doc(orderId).update(updateData);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteOrder(String orderId) async {
    if (await networkInfo.isConnected) {
      try {
        await _firestore.collection('orders').doc(orderId).delete();
        return const Right(null);
      } on firestore.FirebaseException catch (e) {
        return Left(
            ServerFailure(message: e.message ?? 'Failed to delete order'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<List<domain.Order>> getActiveOrders() async {
    if (await networkInfo.isConnected) {
      return await remoteDataSource.getActiveOrders();
    } else {
      throw NoInternetException();
    }
  }

  @override
  Future<Either<Failure, List<domain.Order>>>
      getOrdersByUserIdOrLaundryIdAndStatus(
          String userId, String status) async {
    if (await networkInfo.isConnected) {
      try {
        final orders = await remoteDataSource
            .getOrdersByUserIdOrLaundryIdAndStatus(userId, status);
        final domainOrders = orders.map((orderModel) => orderModel).toList();
        return Right(domainOrders);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, void>> setOrderAsHistory(String orderId) async {
    if (await networkInfo.isConnected) {
      try {
        await _firestore.collection('orders').doc(orderId).update({
          'isHistory': true,
          'updatedAt': firestore.FieldValue.serverTimestamp(),
        });
        return const Right(null);
      } on firestore.FirebaseException catch (e) {
        return Left(ServerFailure(
            message: e.message ?? 'Failed to set order as history'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<domain.Order>>> getHistoryOrdersByUserId(
      String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final orders = await remoteDataSource.getHistoryOrdersByUserId(userId);
        final domainOrders = orders.map((orderModel) => orderModel).toList();
        return Right(domainOrders);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }
}
