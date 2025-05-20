// File: voucher_remote_data_source.dart
// Berisi abstraksi dan implementasi untuk operasi terkait voucher di Firestore.

// Mengimpor package dan file yang diperlukan.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_laundry_app/core/error/exceptions.dart';
import 'package:flutter_laundry_app/data/models/voucher_model.dart';

// Abstrak kelas untuk mendefinisikan kontrak operasi voucher.
abstract class VoucherRemoteDataSource {
  // Method untuk membuat voucher baru.
  Future<VoucherModel> createVoucher(VoucherModel voucher);
  // Method untuk mendapatkan voucher berdasarkan ID laundry.
  Future<List<VoucherModel>> getVouchersByLaundryId(String laundryId);
  // Method untuk mendapatkan voucher berdasarkan ID pengguna.
  Future<List<VoucherModel>> getVouchersByUserId();
  // Method untuk mendapatkan voucher untuk ID pengguna tertentu.
  Future<List<VoucherModel>> getVouchersForUserId(String userId);
  // Method untuk mendapatkan voucher berdasarkan ID pengguna atau laundry.
  Future<List<VoucherModel>> getVouchersByUserIdOrLaundryId(
    String? userId, {
    bool includeLaundry = false,
    bool includeOwner = true,
  });
  // Method untuk memperbarui pemilik voucher.
  Future<void> updateVoucherOwner(String voucherId, String userId, bool add);
  // Method untuk memperbarui voucher.
  Future<VoucherModel> updateVoucher(VoucherModel voucher);
  // Method untuk menghapus voucher.
  Future<void> deleteVoucher(String voucherId);
  // Method untuk mendapatkan voucher berdasarkan pemilik dan ID laundry.
  Future<List<VoucherModel>> getVouchersByOwnerAndLaundryId(
      String ownerUserId, String laundryId);
}

// Implementasi dari VoucherRemoteDataSource.
class VoucherRemoteDataSourceImpl implements VoucherRemoteDataSource {
  // Properti untuk menyimpan instance Firestore dan FirebaseAuth.
  final FirebaseFirestore firestore;
  final firebase_auth.FirebaseAuth firebaseAuth;

  // Konstruktor yang menerima instance Firestore dan FirebaseAuth.
  VoucherRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<VoucherModel> createVoucher(VoucherModel voucher) async {
    try {
      // Periksa apakah pengguna saat ini terautentikasi.
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException(message: 'User not authenticated');
      }

      // Validasi bahwa laundryId sesuai dengan pengguna saat ini.
      if (voucher.laundryId != currentUser.uid) {
        throw ServerException(message: 'Invalid laundryId');
      }

      // Simpan data voucher ke Firestore.
      final voucherRef = firestore.collection('vouchers').doc(voucher.id);
      await voucherRef.set(voucher.toMap());
      return voucher;
    } catch (e) {
      // Tangani error dan lempar ServerException.
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<VoucherModel>> getVouchersByLaundryId(String laundryId) async {
    try {
      // Ambil voucher berdasarkan laundryId dari Firestore.
      final snapshot = await firestore
          .collection('vouchers')
          .where('laundryId', isEqualTo: laundryId)
          .get();

      // Konversi dokumen Firestore ke daftar VoucherModel.
      return snapshot.docs
          .map((doc) => VoucherModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Tangani error dan lempar ServerException.
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<VoucherModel>> getVouchersByUserId() async {
    try {
      // Periksa apakah pengguna saat ini terautentikasi.
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException(message: 'User not authenticated');
      }

      // Ambil voucher berdasarkan laundryId pengguna.
      final laundrySnapshot = await firestore
          .collection('vouchers')
          .where('laundryId', isEqualTo: currentUser.uid)
          .get();

      // Ambil voucher yang dimiliki oleh pengguna.
      final ownerSnapshot = await firestore
          .collection('vouchers')
          .where('ownerVoucherIds', arrayContains: currentUser.uid)
          .get();

      // Gabungkan dokumen dan konversi ke VoucherModel.
      final allDocs = {...laundrySnapshot.docs, ...ownerSnapshot.docs};
      return allDocs
          .map((doc) => VoucherModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Tangani error dan lempar ServerException.
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<VoucherModel>> getVouchersForUserId(String userId) async {
    try {
      // Ambil voucher yang dimiliki oleh userId tertentu.
      final ownerSnapshot = await firestore
          .collection('vouchers')
          .where('ownerVoucherIds', arrayContains: userId)
          .get();

      // Konversi dokumen Firestore ke daftar VoucherModel.
      return ownerSnapshot.docs
          .map((doc) => VoucherModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Tangani error dan lempar ServerException.
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<VoucherModel>> getVouchersByUserIdOrLaundryId(
    String? userId, {
    bool includeLaundry = false,
    bool includeOwner = true,
  }) async {
    try {
      // Tentukan userId efektif (jika null, gunakan pengguna saat ini).
      final currentUser = firebaseAuth.currentUser;
      final effectiveUserId = userId ?? currentUser?.uid;
      if (effectiveUserId == null) {
        throw ServerException(message: 'User not authenticated');
      }

      final List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs = [];

      // Ambil voucher berdasarkan laundryId jika includeLaundry true.
      if (includeLaundry) {
        final laundrySnapshot = await firestore
            .collection('vouchers')
            .where('laundryId', isEqualTo: effectiveUserId)
            .get();
        allDocs.addAll(laundrySnapshot.docs);
      }

      // Ambil voucher berdasarkan ownerVoucherIds jika includeOwner true.
      if (includeOwner) {
        final ownerSnapshot = await firestore
            .collection('vouchers')
            .where('ownerVoucherIds', arrayContains: effectiveUserId)
            .get();
        allDocs.addAll(ownerSnapshot.docs);
      }

      // Konversi dokumen Firestore ke daftar VoucherModel, hilangkan duplikat.
      return allDocs
          .map((doc) => VoucherModel.fromJson(doc.data(), doc.id))
          .toSet()
          .toList();
    } catch (e) {
      // Tangani error dan lempar ServerException.
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateVoucherOwner(
      String voucherId, String userId, bool add) async {
    try {
      // Perbarui array ownerVoucherIds di Firestore.
      final voucherRef = firestore.collection('vouchers').doc(voucherId);
      if (add) {
        await voucherRef.update({
          'ownerVoucherIds': FieldValue.arrayUnion([userId]),
        });
      } else {
        await voucherRef.update({
          'ownerVoucherIds': FieldValue.arrayRemove([userId]),
        });
      }
    } catch (e) {
      // Tangani error dan lempar ServerException.
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VoucherModel> updateVoucher(VoucherModel voucher) async {
    try {
      // Perbarui data voucher di Firestore.
      final voucherRef = firestore.collection('vouchers').doc(voucher.id);
      await voucherRef.update(voucher.toMap());
      return voucher;
    } catch (e) {
      // Tangani error dan lempar ServerException.
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteVoucher(String voucherId) async {
    try {
      // Hapus voucher dari Firestore.
      final voucherRef = firestore.collection('vouchers').doc(voucherId);
      await voucherRef.delete();
    } catch (e) {
      // Tangani error dan lempar ServerException.
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<VoucherModel>> getVouchersByOwnerAndLaundryId(
      String ownerUserId, String laundryId) async {
    try {
      // Ambil voucher berdasarkan ownerUserId dan laundryId.
      final snapshot = await firestore
          .collection('vouchers')
          .where('ownerVoucherIds', arrayContains: ownerUserId)
          .where('laundryId', isEqualTo: laundryId)
          .get();

      // Konversi dokumen Firestore ke daftar VoucherModel.
      return snapshot.docs
          .map((doc) => VoucherModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Tangani error dan lempar ServerException.
      throw ServerException(message: e.toString());
    }
  }
}
