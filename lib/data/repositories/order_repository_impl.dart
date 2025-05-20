// File: order_repository_impl.dart
// Berisi implementasi OrderRepository untuk menangani operasi pesanan dengan Firestore.

// Mengimpor package dan file yang diperlukan.
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:dartz/dartz.dart';
import 'package:flutter_laundry_app/core/error/exceptions.dart';
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/core/network/network_info.dart';
import 'package:flutter_laundry_app/data/datasources/remote/order_remote_data_source.dart';
import 'package:flutter_laundry_app/data/models/order_model.dart';
import 'package:flutter_laundry_app/domain/entities/order.dart' as domain;
import 'package:flutter_laundry_app/domain/repositories/order_repository.dart';

// Implementasi dari OrderRepository.
class OrderRepositoryImpl implements OrderRepository {
  // Properti untuk menyimpan instance Firestore, remoteDataSource, dan networkInfo.
  final firestore.FirebaseFirestore _firestore;
  final OrderRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  // Konstruktor yang menerima Firestore, remoteDataSource, dan networkInfo.
  OrderRepositoryImpl({
    required firestore.FirebaseFirestore firestore,
    required this.remoteDataSource,
    required this.networkInfo,
  }) : _firestore = firestore;

  @override
  Future<Either<Failure, void>> createOrder(domain.Order order) async {
    // Periksa koneksi jaringan.
    if (await networkInfo.isConnected) {
      try {
        // Buat OrderModel dari entitas Order.
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
        // Buat pesanan melalui remoteDataSource.
        await remoteDataSource.createOrder(orderModel);
        // Kembalikan hasil sukses sebagai Right.
        return const Right(null);
      } catch (e) {
        // Tangani error dan kembalikan OrderFailure.
        return Left(OrderFailure(message: 'Failed to create order: $e'));
      }
    } else {
      // Tangani kegagalan jaringan.
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<domain.Order>>> getOrders() async {
    // Periksa koneksi jaringan.
    if (await networkInfo.isConnected) {
      try {
        // Ambil semua pesanan dari Firestore.
        final querySnapshot = await _firestore.collection('orders').get();
        // Konversi dokumen Firestore ke daftar OrderModel.
        final orders = querySnapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
            .toList();
        // Kembalikan hasil sukses sebagai Right.
        return Right(orders);
      } on firestore.FirebaseException catch (e) {
        // Tangani error Firebase.
        return Left(
            ServerFailure(message: e.message ?? 'Failed to fetch orders'));
      } catch (e) {
        // Tangani error umum.
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // Tangani kegagalan jaringan.
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<domain.Order>>> getOrdersByStatus(
      String status) async {
    // Periksa koneksi jaringan.
    if (await networkInfo.isConnected) {
      try {
        // Ambil pesanan berdasarkan status dari Firestore.
        final querySnapshot = await _firestore
            .collection('orders')
            .where('status', isEqualTo: status)
            .get();
        // Konversi dokumen Firestore ke daftar OrderModel.
        final orders = querySnapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
            .toList();
        // Kembalikan hasil sukses sebagai Right.
        return Right(orders);
      } on firestore.FirebaseException catch (e) {
        // Tangani error Firebase.
        return Left(
            ServerFailure(message: e.message ?? 'Failed to fetch orders'));
      } catch (e) {
        // Tangani error umum.
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // Tangani kegagalan jaringan.
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, domain.Order>> updateOrderStatus(
      String orderId, String newStatus) async {
    // Periksa koneksi jaringan.
    if (await networkInfo.isConnected) {
      try {
        // Perbarui status pesanan di Firestore.
        await _firestore.collection('orders').doc(orderId).update({
          'status': newStatus,
          'updatedAt': firestore.FieldValue.serverTimestamp(),
        });

        // Ambil data pesanan yang telah diperbarui.
        final docSnapshot =
            await _firestore.collection('orders').doc(orderId).get();
        if (!docSnapshot.exists) {
          return Left(ServerFailure(message: 'Order not found'));
        }

        // Konversi data Firestore ke OrderModel.
        final updatedOrder =
            OrderModel.fromJson(docSnapshot.data()!, docSnapshot.id);
        // Kembalikan hasil sukses sebagai Right.
        return Right(updatedOrder);
      } on firestore.FirebaseException catch (e) {
        // Tangani error Firebase.
        return Left(ServerFailure(
            message: e.message ?? 'Failed to update order status'));
      } catch (e) {
        // Tangani error umum.
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // Tangani kegagalan jaringan.
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatusAndCompletion(
      String orderId, String newStatus) async {
    // Periksa koneksi jaringan.
    if (await networkInfo.isConnected) {
      try {
        // Siapkan data untuk pembaruan status dan waktu penyelesaian/pembatalan.
        final updateData = {
          'status': newStatus,
          'updatedAt': firestore.FieldValue.serverTimestamp(),
          if (newStatus == 'completed')
            'completedAt': firestore.FieldValue.serverTimestamp(),
          if (newStatus == 'cancelled')
            'cancelledAt': firestore.FieldValue.serverTimestamp(),
        };

        // Perbarui data pesanan di Firestore.
        await _firestore.collection('orders').doc(orderId).update(updateData);
        // Kembalikan hasil sukses sebagai Right.
        return const Right(null);
      } catch (e) {
        // Tangani error umum.
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // Tangani kegagalan jaringan.
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteOrder(String orderId) async {
    // Periksa koneksi jaringan.
    if (await networkInfo.isConnected) {
      try {
        // Hapus pesanan dari Firestore.
        await _firestore.collection('orders').doc(orderId).delete();
        // Kembalikan hasil sukses sebagai Right.
        return const Right(null);
      } on firestore.FirebaseException catch (e) {
        // Tangani error Firebase.
        return Left(
            ServerFailure(message: e.message ?? 'Failed to delete order'));
      } catch (e) {
        // Tangani error umum.
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // Tangani kegagalan jaringan.
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<List<domain.Order>> getActiveOrders() async {
    // Periksa koneksi jaringan.
    if (await networkInfo.isConnected) {
      // Ambil pesanan aktif melalui remoteDataSource.
      return await remoteDataSource.getActiveOrders();
    } else {
      // Lempar NoInternetException jika tidak ada koneksi.
      throw NoInternetException();
    }
  }

  @override
  Future<Either<Failure, List<domain.Order>>>
      getOrdersByUserIdOrLaundryIdAndStatus(
          String userId, String status) async {
    // Periksa koneksi jaringan.
    if (await networkInfo.isConnected) {
      try {
        // Ambil pesanan berdasarkan userId dan status melalui remoteDataSource.
        final orders = await remoteDataSource
            .getOrdersByUserIdOrLaundryIdAndStatus(userId, status);
        final domainOrders = orders.map((orderModel) => orderModel).toList();
        // Kembalikan hasil sukses sebagai Right.
        return Right(domainOrders);
      } on ServerException catch (e) {
        // Tangani error server.
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        // Tangani error umum.
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // Tangani kegagalan jaringan.
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, void>> setOrderAsHistory(String orderId) async {
    // Periksa koneksi jaringan.
    if (await networkInfo.isConnected) {
      try {
        // Tandai pesanan sebagai riwayat di Firestore.
        await _firestore.collection('orders').doc(orderId).update({
          'isHistory': true,
          'updatedAt': firestore.FieldValue.serverTimestamp(),
        });
        // Kembalikan hasil sukses sebagai Right.
        return const Right(null);
      } on firestore.FirebaseException catch (e) {
        // Tangani error Firebase.
        return Left(ServerFailure(
            message: e.message ?? 'Failed to set order as history'));
      } catch (e) {
        // Tangani error umum.
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // Tangani kegagalan jaringan.
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<domain.Order>>> getHistoryOrdersByUserId(
      String userId) async {
    // Periksa koneksi jaringan.
    if (await networkInfo.isConnected) {
      try {
        // Ambil riwayat pesanan berdasarkan userId melalui remoteDataSource.
        final orders = await remoteDataSource.getHistoryOrdersByUserId(userId);
        final domainOrders = orders.map((orderModel) => orderModel).toList();
        // Kembalikan hasil sukses sebagai Right.
        return Right(domainOrders);
      } on ServerException catch (e) {
        // Tangani error server.
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        // Tangani error umum.
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // Tangani kegagalan jaringan.
      return Left(NoInternetFailure());
    }
  }
}