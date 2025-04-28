import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_laundry_app/core/error/exceptions.dart';
import 'package:flutter_laundry_app/data/models/voucher_model.dart';

abstract class VoucherRemoteDataSource {
  Future<VoucherModel> createVoucher(VoucherModel voucher);
  Future<List<VoucherModel>> getVouchersByLaundryId(String laundryId);
  Future<List<VoucherModel>> getVouchersByUserId();
  Future<List<VoucherModel>> getVouchersForUserId(String userId);
  Future<List<VoucherModel>> getVouchersByUserIdOrLaundryId(
    String? userId, {
    bool includeLaundry = false,
    bool includeOwner = true,
  });
  Future<void> updateVoucherOwner(String voucherId, String userId, bool add);
  Future<VoucherModel> updateVoucher(VoucherModel voucher);
  Future<void> deleteVoucher(String voucherId);
  Future<List<VoucherModel>> getVouchersByOwnerAndLaundryId(
      String ownerUserId, String laundryId);
}

class VoucherRemoteDataSourceImpl implements VoucherRemoteDataSource {
  final FirebaseFirestore firestore;
  final firebase_auth.FirebaseAuth firebaseAuth;

  VoucherRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<VoucherModel> createVoucher(VoucherModel voucher) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException(message: 'User not authenticated');
      }

      if (voucher.laundryId != currentUser.uid) {
        throw ServerException(message: 'Invalid laundryId');
      }

      final voucherRef = firestore.collection('vouchers').doc(voucher.id);
      await voucherRef.set(voucher.toMap());
      return voucher;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<VoucherModel>> getVouchersByLaundryId(String laundryId) async {
    try {
      final snapshot = await firestore
          .collection('vouchers')
          .where('laundryId', isEqualTo: laundryId)
          .get();

      return snapshot.docs
          .map((doc) => VoucherModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<VoucherModel>> getVouchersByUserId() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException(message: 'User not authenticated');
      }

      final laundrySnapshot = await firestore
          .collection('vouchers')
          .where('laundryId', isEqualTo: currentUser.uid)
          .get();

      final ownerSnapshot = await firestore
          .collection('vouchers')
          .where('ownerVoucherIds', arrayContains: currentUser.uid)
          .get();

      final allDocs = {...laundrySnapshot.docs, ...ownerSnapshot.docs};
      return allDocs
          .map((doc) => VoucherModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<VoucherModel>> getVouchersForUserId(String userId) async {
    try {
      final ownerSnapshot = await firestore
          .collection('vouchers')
          .where('ownerVoucherIds', arrayContains: userId)
          .get();

      return ownerSnapshot.docs
          .map((doc) => VoucherModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
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
      final currentUser = firebaseAuth.currentUser;
      final effectiveUserId = userId ?? currentUser?.uid;
      if (effectiveUserId == null) {
        throw ServerException(message: 'User not authenticated');
      }

      final List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs = [];

      if (includeLaundry) {
        final laundrySnapshot = await firestore
            .collection('vouchers')
            .where('laundryId', isEqualTo: effectiveUserId)
            .get();
        allDocs.addAll(laundrySnapshot.docs);
      }

      if (includeOwner) {
        final ownerSnapshot = await firestore
            .collection('vouchers')
            .where('ownerVoucherIds', arrayContains: effectiveUserId)
            .get();
        allDocs.addAll(ownerSnapshot.docs);
      }

      return allDocs
          .map((doc) => VoucherModel.fromJson(doc.data(), doc.id))
          .toSet()
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateVoucherOwner(
      String voucherId, String userId, bool add) async {
    try {
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
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VoucherModel> updateVoucher(VoucherModel voucher) async {
    try {
      final voucherRef = firestore.collection('vouchers').doc(voucher.id);
      await voucherRef.update(voucher.toMap());
      return voucher;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteVoucher(String voucherId) async {
    try {
      final voucherRef = firestore.collection('vouchers').doc(voucherId);
      await voucherRef.delete();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<VoucherModel>> getVouchersByOwnerAndLaundryId(
      String ownerUserId, String laundryId) async {
    try {
      final snapshot = await firestore
          .collection('vouchers')
          .where('ownerVoucherIds', arrayContains: ownerUserId)
          .where('laundryId', isEqualTo: laundryId)
          .get();

      return snapshot.docs
          .map((doc) => VoucherModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}