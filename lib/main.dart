// File: lib/main.dart
// Berisi titik masuk utama aplikasi Flutter.
// Menginisialisasi Firebase, App Check, dan menjalankan aplikasi dengan Riverpod.

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/core/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Fungsi utama aplikasi
void main() async {
  // Pastikan binding widget diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Firebase
  await Firebase.initializeApp();
  // Aktivasi Firebase App Check untuk keamanan
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity, // Gunakan Play Integrity untuk Android
    appleProvider: AppleProvider.deviceCheck, // Gunakan DeviceCheck untuk iOS
  );
  // Jalankan aplikasi dengan Riverpod
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Widget utama aplikasi
class MyApp extends ConsumerWidget {
  // Konstruktor
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil konfigurasi router dari provider
    final goRouter = ref.watch(routerProvider);

    // Bungkus aplikasi dengan ScaffoldMessenger untuk menampilkan snackbar
    return ScaffoldMessenger(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false, // Nonaktifkan banner debug
        title: 'Laundry App', // Judul aplikasi
        theme: ThemeData(
          primarySwatch: Colors.blue, // Tema warna utama
          visualDensity: VisualDensity.adaptivePlatformDensity, // Densitas visual adaptif
        ),
        routerConfig: goRouter, // Konfigurasi router
      ),
    );
  }
}