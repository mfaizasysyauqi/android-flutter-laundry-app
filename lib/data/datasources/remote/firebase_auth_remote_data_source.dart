import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';

abstract class FirebaseAuthRemoteDataSource {
  Future<UserModel> register({
    required String role,
    required String fullName,
    required String uniqueName,
    required String email,
    required String password,
    required String phoneNumber,
    int regulerPrice = 7000,
    int expressPrice = 10000,
    required String address,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> getUser();
  Future<UserModel> updateLaundryPrice(int newPrice);
}

class FirebaseAuthRemoteDataSourceImpl implements FirebaseAuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  FirebaseAuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> register({
    required String role,
    required String fullName,
    required String uniqueName,
    required String email,
    required String password,
    required String phoneNumber,
    int regulerPrice = 7000,
    int expressPrice = 10000,
    required String address,
  }) async {
    try {
      // Check if uniqueName already exists
      final uniqueNameQuery = await firestore
          .collection('users')
          .where('uniqueName', isEqualTo: uniqueName)
          .get();

      if (uniqueNameQuery.docs.isNotEmpty) {
        throw UniqueNameAlreadyInUseException();
      }

      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw ServerException();
      }

      final userId = userCredential.user!.uid;
      final currentDateTime = DateTime.now();

      final userData = UserModel(
        id: userId,
        role: role,
        fullName: fullName,
        uniqueName: uniqueName,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        regulerPrice: regulerPrice,
        expressPrice: expressPrice,
        createdAt: currentDateTime,
      );

      await firestore.collection('users').doc(userId).set(userData.toJson());
      await userCredential.user!.updateProfile(displayName: fullName);

      return userData;
    } on UniqueNameAlreadyInUseException {
      throw UniqueNameAlreadyInUseException();
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseException();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw ServerException();
      }

      final userId = userCredential.user!.uid;
      final userDoc = await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw UserNotFoundException();
      }

      return UserModel.fromJson(userDoc.data()!..addAll({'id': userId}));
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw EmailNotFoundException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordException();
      } else if (e.code == 'invalid-credential') {
        throw InvalidCredentialsException();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<UserModel> getUser() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException();
      }

      final userDoc =
          await firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        throw ServerException();
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      userData['id'] = currentUser.uid;
      return UserModel.fromJson(userData);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<UserModel> updateLaundryPrice(int newPrice) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException();
      }

      await firestore.collection('users').doc(currentUser.uid).update({
        'regulerPrice': newPrice,
      });

      final userDoc =
          await firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        throw ServerException();
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      userData['id'] = currentUser.uid;
      return UserModel.fromJson(userData);
    } catch (e) {
      throw ServerException();
    }
  }
}
