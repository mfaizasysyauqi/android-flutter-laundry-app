// File: exceptions.dart
// Berisi definisi kelas-kelas exception khusus untuk menangani berbagai jenis error dalam aplikasi.

// Kelas ServerException untuk menangani error dari server.
class ServerException implements Exception {
  // Properti message untuk menyimpan pesan error (opsional).
  final String? message;

  // Konstruktor dengan parameter opsional message.
  ServerException({this.message});

  // Override method toString untuk mengembalikan pesan error.
  // Jika message null, kembalikan pesan default 'Server error occurred'.
  @override
  String toString() => message ?? 'Server error occurred';
}

// Kelas CacheException untuk menangani error terkait cache.
// Tidak memiliki properti tambahan, hanya sebagai penanda error cache.
class CacheException implements Exception {}

// Kelas NetworkException untuk menangani error jaringan.
// Digunakan ketika aplikasi tidak dapat terhubung ke internet atau server.
class NetworkException implements Exception {}

// Kelas WeakPasswordException untuk menangani error ketika kata sandi terlalu lemah.
// Digunakan dalam proses validasi kata sandi.
class WeakPasswordException implements Exception {}

// Kelas EmailAlreadyInUseException untuk menangani error ketika email sudah digunakan.
// Digunakan saat registrasi pengguna baru.
class EmailAlreadyInUseException implements Exception {}

// Kelas InvalidCredentialsException untuk menangani error ketika kredensial tidak valid.
// Digunakan saat login dengan email atau kata sandi yang salah.
class InvalidCredentialsException implements Exception {}

// Kelas EmailNotFoundException untuk menangani error ketika email tidak ditemukan.
// Digunakan saat mencoba login atau mencari pengguna berdasarkan email.
class EmailNotFoundException implements Exception {}

// Kelas WrongPasswordException untuk menangani error ketika kata sandi salah.
// Digunakan dalam proses autentikasi.
class WrongPasswordException implements Exception {}

// Kelas UserNotFoundException untuk menangani error ketika pengguna tidak ditemukan.
// Digunakan saat mencari data pengguna di database.
class UserNotFoundException implements Exception {}

// Kelas UniqueNameAlreadyInUseException untuk menangani error ketika nama unik sudah digunakan.
// Digunakan saat mendaftarkan nama unik untuk pengguna atau entitas lain.
class UniqueNameAlreadyInUseException implements Exception {}

// Kelas NoInternetException untuk menangani error ketika tidak ada koneksi internet.
class NoInternetException implements Exception {
  // Properti message untuk menyimpan pesan error.
  final String message;

  // Konstruktor dengan pesan default 'No internet connection' jika tidak ada pesan yang diberikan.
  NoInternetException({this.message = 'No internet connection'});
}