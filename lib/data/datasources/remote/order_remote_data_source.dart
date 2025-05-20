// File: order_remote_data_source.dart
// Berisi abstraksi dan implementasi untuk operasi terkait pesanan di Firestore.

// Mengimpor package dan file yang diperlukan.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_laundry_app/core/error/exceptions.dart';
import 'package:flutter_laundry_app/data/models/order_model.dart';

// Abstrak kelas untuk mendefinisikan kontrak operasi pesanan.
abstract class OrderRemoteDataSource {
  // Method untuk membuat pesanan baru.
  Future<OrderModel> createOrder(OrderModel order);
  // Method untuk mendapatkan daftar pesanan aktif.
  Future<List<OrderModel>> getActiveOrders();
  // Method untuk mendapatkan pesanan berdasarkan ID pengguna atau laundry dan status.
  Future<List<OrderModel>> getOrdersByUserIdOrLaundryIdAndStatus(
      String userId, String status);
  // Method untuk mendapatkan riwayat pesanan berdasarkan ID pengguna.
  Future<List<OrderModel>> getHistoryOrdersByUserId(String userId);
}

// Implementasi dari OrderRemoteDataSource.
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  // Properti untuk menyimpan instance Firestore dan FirebaseAuth.
  final FirebaseFirestore firestore;
  final firebase_auth.FirebaseAuth firebaseAuth;

  // Konstruktor yang menerima instance Firestore dan FirebaseAuth.
  OrderRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      // Periksa apakah pengguna saat ini terautentikasi.
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException(message: 'User not authenticated');
      }

      // Simpan data pesanan ke Firestore.
      final orderRef = firestore.collection('orders').doc(order.id);
      await orderRef.set(order.toMap());
      return order;
    } catch (e) {
      // Tangani error dan lempar ServerException.
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<OrderModel>> getActiveOrders() async {
    try {
      // Ambil pesanan dengan status 'active' dari Firestore.
      final snapshot = await firestore
          .collection('orders')
          .where('status', isEqualTo: 'active')
          .get();
      // Konversi dokumen Firestore ke daftar OrderModel.
      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Tangani error dan lempar ServerException.
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<OrderModel>> getOrdersByUserIdOrLaundryIdAndStatus(
      String userId, String status) async {
    try {
      // Ambil pesanan sebagai pelanggan dengan userId dan status tertentu.
      final customerSnapshot = await firestore
          .collection('orders')
          .where('customerUniqueName', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .get();

      // Ambil pesanan sebagai laundry dengan userId dan status tertentu.
      final laundrySnapshot = await firestore
          .collection('orders')
          .where('laundryUniqueName', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .get();

      // Gabungkan dokumen dari kedua snapshot dan konversi ke OrderModel.
      final allDocs = {...customerSnapshot.docs, ...laundrySnapshot.docs};
      return allDocs
          .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Tangani error dan lempar ServerException.
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<OrderModel>> getHistoryOrdersByUserId(String userId) async {
    try {
      // Ambil data pengguna untuk mendapatkan uniqueName.
      final userDoc = await firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw ServerException(message: 'User document does not exist');
      }
      final userData = userDoc.data() as Map<String, dynamic>;
      final uniqueName = userData['uniqueName'];

      // Buat query untuk pesanan dengan isHistory=true.
      Query<Map<String, dynamic>> query =
          firestore.collection('orders').where('isHistory', isEqualTo: true);

      // Ambil pesanan sebagai pelanggan.
      final customerSnapshot =
          await query.where('customerUniqueName', isEqualTo: uniqueName).get();

      // Ambil pesanan sebagai laundry.
      final laundrySnapshot =
          await query.where('laundryUniqueName', isEqualTo: uniqueName).get();

      // Gabungkan dokumen dan konversi ke OrderModel.
      final allDocs = {...customerSnapshot.docs, ...laundrySnapshot.docs};
      return allDocs
          .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Tangani error dan lempar ServerException.
      throw ServerException(message: e.toString());
    }
  }
}
