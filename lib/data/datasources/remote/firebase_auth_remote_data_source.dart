// File: firebase_auth_remote_data_source.dart
// Berisi abstraksi dan implementasi untuk operasi autentikasi Firebase seperti registrasi, login, dan pembaruan harga laundry.

// Mengimpor package dan file yang diperlukan.
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';

// Abstrak kelas untuk mendefinisikan kontrak operasi autentikasi Firebase.
abstract class FirebaseAuthRemoteDataSource {
  // Method untuk mendaftarkan pengguna baru.
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

  // Method untuk login pengguna.
  Future<UserModel> login({
    required String email,
    required String password,
  });

  // Method untuk mendapatkan data pengguna saat ini.
  Future<UserModel> getUser();
  
  // Method untuk memperbarui harga laundry.
  Future<UserModel> updateLaundryPrice(int newPrice);
}

// Implementasi dari FirebaseAuthRemoteDataSource.
class FirebaseAuthRemoteDataSourceImpl implements FirebaseAuthRemoteDataSource {
  // Properti untuk menyimpan instance FirebaseAuth dan Firestore.
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  // Konstruktor yang menerima instance FirebaseAuth dan Firestore.
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
      // Periksa apakah uniqueName sudah digunakan.
      final uniqueNameQuery = await firestore
          .collection('users')
          .where('uniqueName', isEqualTo: uniqueName)
          .get();

      if (uniqueNameQuery.docs.isNotEmpty) {
        throw UniqueNameAlreadyInUseException();
      }

      // Buat akun baru menggunakan email dan kata sandi.
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Periksa apakah userCredential valid.
      if (userCredential.user == null) {
        throw ServerException();
      }

      // Ambil ID pengguna dan waktu saat ini.
      final userId = userCredential.user!.uid;
      final currentDateTime = DateTime.now();

      // Buat instance UserModel dengan data pengguna.
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

      // Simpan data pengguna ke Firestore.
      await firestore.collection('users').doc(userId).set(userData.toJson());
      // Perbarui profil pengguna dengan nama lengkap.
      await userCredential.user!.updateProfile(displayName: fullName);

      return userData;
    } on UniqueNameAlreadyInUseException {
      // Tangani error jika nama unik sudah digunakan.
      throw UniqueNameAlreadyInUseException();
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Tangani error autentikasi Firebase.
      if (e.code == 'weak-password') {
        throw WeakPasswordException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseException();
      } else {
        throw ServerException();
      }
    } catch (e) {
      // Tangani error umum lainnya.
      throw ServerException();
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // Lakukan login menggunakan email dan kata sandi.
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Periksa apakah userCredential valid.
      if (userCredential.user == null) {
        throw ServerException();
      }

      // Ambil data pengguna dari Firestore.
      final userId = userCredential.user!.uid;
      final userDoc = await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw UserNotFoundException();
      }

      // Konversi data Firestore ke UserModel.
      return UserModel.fromJson(userDoc.data()!..addAll({'id': userId}));
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Tangani error autentikasi Firebase.
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
      // Tangani error umum lainnya.
      throw ServerException();
    }
  }

  @override
  Future<UserModel> getUser() async {
    try {
      // Ambil pengguna saat ini dari FirebaseAuth.
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException();
      }

      // Ambil data pengguna dari Firestore.
      final userDoc =
          await firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        throw ServerException();
      }

      // Konversi data Firestore ke UserModel.
      final userData = userDoc.data() as Map<String, dynamic>;
      userData['id'] = currentUser.uid;
      return UserModel.fromJson(userData);
    } catch (e) {
      // Tangani error umum.
      throw ServerException();
    }
  }

  @override
  Future<UserModel> updateLaundryPrice(int newPrice) async {
    try {
      // Ambil pengguna saat ini dari FirebaseAuth.
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException();
      }

      // Perbarui harga reguler di Firestore.
      await firestore.collection('users').doc(currentUser.uid).update({
        'regulerPrice': newPrice,
      });

      // Ambil data pengguna yang telah diperbarui.
      final userDoc =
          await firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        throw ServerException();
      }

      // Konversi data Firestore ke UserModel.
      final userData = userDoc.data() as Map<String, dynamic>;
      userData['id'] = currentUser.uid;
      return UserModel.fromJson(userData);
    } catch (e) {
      // Tangani error umum.
      throw ServerException();
    }
  }
}