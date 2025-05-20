// File: order_number_generator.dart
// Berisi kelas OrderNumberGenerator untuk menghasilkan nomor pesanan unik.

// Mengimpor package dart:math untuk menghasilkan angka acak.
import 'dart:math';

// Kelas OrderNumberGenerator untuk menghasilkan nomor pesanan unik.
class OrderNumberGenerator {
  // Method statis untuk menghasilkan nomor unik.
  static String generateUniqueNumber() {
    // Inisialisasi objek Random untuk menghasilkan angka acak.
    final random = Random();
    
    // Ambil timestamp saat ini dan ambil 6 digit terakhir.
    final timestamp = DateTime.now().millisecondsSinceEpoch % 1000000;
    
    // Hasilkan angka acak 4 digit dan format dengan padding nol di depan.
    final randomNumber = random.nextInt(10000).toString().padLeft(4, '0');
    
    // Gabungkan timestamp dan angka acak untuk membuat nomor 10 digit.
    return '$timestamp$randomNumber';
  }
}