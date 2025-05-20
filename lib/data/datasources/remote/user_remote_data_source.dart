// File: user_remote_data_source.dart
// Berisi abstraksi dan implementasi untuk operasi terkait pengguna di Firestore.

// Mengimpor package dan file yang diperlukan.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_laundry_app/core/error/exceptions.dart';
import 'package:flutter_laundry_app/data/models/user_model.dart';

// Abstrak kelas untuk mendefinisikan kontrak operasi pengguna.
abstract class UserRemoteDataSource {
  // Method untuk mendapatkan data pengguna saat ini.
  Future<UserModel> getUser();
  // Method untuk mendapatkan data pengguna berdasarkan ID.
  Future<UserModel> getUserById(String userId);
  // Method untuk memperbarui harga laundry.
  Future<UserModel> updateLaundryPrice(int regulerPrice, int expressPrice);
  // Method untuk mendapatkan pengguna berdasarkan nama unik.
  Future<UserModel> getUserByUniqueName(String uniqueName);
  // Method untuk mendapatkan daftar pelanggan.
  Future<List<UserModel>> getCustomers();
}

// Implementasi dari UserRemoteDataSource.
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  // Properti untuk menyimpan instance Firestore dan FirebaseAuth.
  final FirebaseFirestore firestore;
  final firebase_auth.FirebaseAuth firebaseAuth;

  // Konstruktor yang menerima instance Firestore dan FirebaseAuth.
  UserRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<UserModel> getUser() async {
    try {
      // Periksa apakah pengguna saat ini terautentikasi.
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException(message: 'User not authenticated');
      }

      // Ambil data pengguna dari Firestore.
      final userDoc =
          await firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        throw ServerException(message: 'User document does not exist');
      }

      // Konversi data Firestore ke UserModel.
      final userData = userDoc.data() as Map<String, dynamic>;
      userData['id'] = currentUser.uid;
      return UserModel.fromJson(userData);
    } catch (e) {
      // Tangani error dan lempar ServerException.
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> getUserById(String userId) async {
    try {
      // Ambil data pengguna berdasarkan ID dari Firestore.
      final userDoc = await firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw ServerException(message: 'User document does not exist');
      }

      // Konversi data Firestore ke UserModel.
      final userData = userDoc.data() as Map<String, dynamic>;
      userData['id'] = userId;
      return UserModel.fromJson(userData);
    } catch (e) {
      // Tangani error dan lempar ServerException.
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> updateLaundryPrice(
      int regulerPrice, int expressPrice) async {
    try {
      // Periksa apakah pengguna saat ini terautentikasi.
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException(message: 'User not authenticated');
      }

      // Perbarui harga reguler dan express di Firestore.
      await firestore.collection('users').doc(currentUser.uid).update({
        'regulerPrice': regulerPrice,
        'expressPrice': expressPrice,
      });

      // Ambil data pengguna yang telah diperbarui.
      final userDoc =
          await firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        throw ServerException(message: 'User document does not exist');
      }

      // Konversi data Firestore ke UserModel.
      final userData = userDoc.data() as Map<String, dynamic>;
      userData['id'] = currentUser.uid;
      return UserModel.fromJson(userData);
    } catch (e) {
      // Tangani error dan lempar ServerException.
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> getUserByUniqueName(String uniqueName) async {
    try {
      // Cari pengguna berdasarkan uniqueName di Firestore.
      final snapshot = await firestore
          .collection('users')
          .where('uniqueName', isEqualTo: uniqueName)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        throw ServerException(message: 'User not found');
      }
      // Konversi data Firestore ke UserModel.
      final userData = snapshot.docs.first.data();
      userData['id'] = snapshot.docs.first.id;
      return UserModel.fromJson(userData);
    } catch (e) {
      // Tangani error dan lempar ServerException.
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<UserModel>> getCustomers() async {
    try {
      // Ambil daftar pengguna dengan role 'Customer' dari Firestore.
      final snapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'Customer')
          .get();

      // Konversi dokumen Firestore ke daftar UserModel.
      return snapshot.docs.map((doc) {
        final userData = doc.data();
        userData['id'] = doc.id;
        return UserModel.fromJson(userData);
      }).toList();
    } catch (e) {
      // Tangani error dan lempar ServerException.
      throw ServerException(message: e.toString());
    }
  }
}
