import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_laundry_app/core/error/exceptions.dart';
import 'package:flutter_laundry_app/data/models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUser();
  Future<UserModel> getUserById(String userId);
  Future<UserModel> updateLaundryPrice(int regulerPrice, int expressPrice);
  Future<UserModel> getUserByUniqueName(String uniqueName);
  Future<List<UserModel>> getCustomers();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;
  final firebase_auth.FirebaseAuth firebaseAuth;

  UserRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<UserModel> getUser() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException(message: 'User not authenticated');
      }

      final userDoc =
          await firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        throw ServerException(message: 'User document does not exist');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      userData['id'] = currentUser.uid;
      return UserModel.fromJson(userData);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> getUserById(String userId) async {
    try {
      final userDoc = await firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw ServerException(message: 'User document does not exist');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      userData['id'] = userId;
      return UserModel.fromJson(userData);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> updateLaundryPrice(
      int regulerPrice, int expressPrice) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException(message: 'User not authenticated');
      }

      await firestore.collection('users').doc(currentUser.uid).update({
        'regulerPrice': regulerPrice,
        'expressPrice': expressPrice,
      });

      final userDoc =
          await firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        throw ServerException(message: 'User document does not exist');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      userData['id'] = currentUser.uid;
      return UserModel.fromJson(userData);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> getUserByUniqueName(String uniqueName) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('uniqueName', isEqualTo: uniqueName)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        throw ServerException(message: 'User not found');
      }
      final userData = snapshot.docs.first.data();
      userData['id'] = snapshot.docs.first.id;
      return UserModel.fromJson(userData);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<UserModel>> getCustomers() async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'Customer')
          .get();

      return snapshot.docs.map((doc) {
        final userData = doc.data();
        userData['id'] = doc.id;
        return UserModel.fromJson(userData);
      }).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}