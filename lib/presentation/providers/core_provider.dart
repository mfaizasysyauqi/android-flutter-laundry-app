// File: lib/presentation/providers/core_provider.dart
// Berisi definisi provider untuk dependensi inti aplikasi.
// Menyediakan instance Firebase, konektivitas jaringan, dan data source autentikasi.

// Mengimpor package dan file yang diperlukan.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_laundry_app/core/network/network_info.dart';
import 'package:flutter_laundry_app/data/datasources/remote/firebase_auth_remote_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

// Mendefinisikan provider untuk Firebase Firestore.
// Provider ini menyediakan instance FirebaseFirestore untuk akses database.
final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// Mendefinisikan provider untuk Firebase Authentication.
// Provider ini menyediakan instance FirebaseAuth untuk autentikasi pengguna.
final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>(
    (ref) => firebase_auth.FirebaseAuth.instance);

// Mendefinisikan provider untuk InternetConnectionChecker.
// Provider ini menyediakan instance InternetConnectionChecker untuk memeriksa koneksi jaringan.
final connectionCheckerProvider = Provider<InternetConnectionChecker>((ref) {
  // Mengembalikan instance InternetConnectionChecker dengan konfigurasi default.
  return InternetConnectionChecker.createInstance();
});

// Mendefinisikan provider untuk NetworkInfo.
// Provider ini menyediakan instance NetworkInfo untuk memeriksa status konektivitas.
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  // Mengambil instance InternetConnectionChecker dari connectionCheckerProvider.
  final connectionChecker = ref.watch(connectionCheckerProvider);
  // Mengembalikan instance NetworkInfoImpl dengan connectionChecker sebagai dependensi.
  return NetworkInfoImpl(connectionChecker);
});

// Mendefinisikan provider untuk FirebaseAuthRemoteDataSource.
// Provider ini menyediakan instance FirebaseAuthRemoteDataSource untuk operasi autentikasi.
final firebaseAuthRemoteDataSourceProvider =
    Provider<FirebaseAuthRemoteDataSource>((ref) {
  // Mengambil instance FirebaseAuth dari firebaseAuthProvider.
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  // Mengambil instance FirebaseFirestore dari firestoreProvider.
  final firestore = ref.watch(firestoreProvider);
  // Mengembalikan instance FirebaseAuthRemoteDataSourceImpl dengan dependensi yang diperlukan.
  return FirebaseAuthRemoteDataSourceImpl(
    firebaseAuth: firebaseAuth,
    firestore: firestore,
  );
});