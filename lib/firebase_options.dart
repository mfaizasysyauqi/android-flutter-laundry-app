// File: lib/firebase_options.dart
// Berisi konfigurasi Firebase untuk berbagai platform.
// Digunakan untuk menginisialisasi Firebase dalam aplikasi.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Kelas untuk menyediakan opsi Firebase default berdasarkan platform.
class DefaultFirebaseOptions {
  // Mendapatkan opsi Firebase untuk platform saat ini
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web; // Kembalikan opsi untuk web
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android; // Kembalikan opsi untuk Android
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk iOS - '
          'Anda dapat mengkonfigurasi ulang dengan menjalankan FlutterFire CLI lagi.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk macOS - '
          'Anda dapat mengkonfigurasi ulang dengan menjalankan FlutterFire CLI lagi.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk Windows - '
          'Anda dapat mengkonfigurasi ulang dengan menjalankan FlutterFire CLI lagi.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk Linux - '
          'Anda dapat mengkonfigurasi ulang dengan menjalankan FlutterFire CLI lagi.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions tidak didukung untuk platform ini.',
        );
    }
  }

  // Konfigurasi Firebase untuk Android
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAzY9jDD1SpnN7-QIe07ynO9MOe_PPdOrw',
    appId: '1:1039249932081:android:b5651715e68129038aba10',
    messagingSenderId: '1039249932081',
    projectId: 'flutter-laundry-app-6eee2',
    storageBucket: 'flutter-laundry-app-6eee2.firebasestorage.app',
  );

  // Konfigurasi Firebase untuk Web
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCLCx47TfVfS9CAZtbzwhlfDCY1N1OrCyk',
    appId: '1:410440240900:web:d1ee7f0934b622c6c78a51',
    messagingSenderId: '410440240900',
    projectId: 'yolo-kasir',
    authDomain: 'yolo-kasir.firebaseapp.com',
    storageBucket: 'yolo-kasir.firebasestorage.app',
  );
}