// File: failures.dart
// Berisi definisi kelas Failure dan turunannya untuk menangani kegagalan dalam aplikasi secara terstruktur.

// Kelas abstrak Failure sebagai dasar untuk semua jenis kegagalan.
abstract class Failure {
  // Properti message untuk menyimpan pesan kegagalan.
  final String message;

  // Konstruktor yang membutuhkan parameter message.
  Failure({required this.message});
}

// Kelas ServerFailure untuk menangani kegagalan dari server.
class ServerFailure extends Failure {
  // Konstruktor dengan parameter opsional message.
  // Jika message tidak diberikan, gunakan pesan default 'Server error occurred'.
  ServerFailure({String? message})
      : super(message: message ?? 'Server error occurred');
}

// Kelas NetworkFailure untuk menangani kegagalan jaringan.
class NetworkFailure extends Failure {
  // Konstruktor dengan parameter opsional message.
  // Jika message tidak diberikan, gunakan pesan default 'No internet connection'.
  NetworkFailure({String? message})
      : super(message: message ?? 'No internet connection');
}

// Kelas WeakPasswordFailure untuk menangani kegagalan karena kata sandi lemah.
class WeakPasswordFailure extends Failure {
  // Konstruktor dengan parameter opsional message.
  // Jika message tidak diberikan, gunakan pesan default 'Password is too weak'.
  WeakPasswordFailure({String? message})
      : super(message: message ?? 'Password is too weak');
}

// Kelas UserNotFoundFailure untuk menangani kegagalan ketika pengguna tidak ditemukan.
class UserNotFoundFailure extends Failure {
  // Konstruktor dengan parameter opsional message.
  // Jika message tidak diberikan, gunakan pesan default 'User not found'.
  UserNotFoundFailure({String? message})
      : super(message: message ?? 'User not found');
}

// Kelas EmailAlreadyInUseFailure untuk menangani kegagalan karena email sudah digunakan.
class EmailAlreadyInUseFailure extends Failure {
  // Konstruktor dengan parameter opsional message.
  // Jika message tidak diberikan, gunakan pesan default 'Email already in use'.
  EmailAlreadyInUseFailure({String? message})
      : super(message: message ?? 'Email already in use');
}

// Kelas InvalidCredentialsFailure untuk menangani kegagalan karena kredensial tidak valid.
class InvalidCredentialsFailure extends Failure {
  // Konstruktor dengan parameter opsional message.
  // Jika message tidak diberikan, gunakan pesan default 'Invalid email or password'.
  InvalidCredentialsFailure({String? message})
      : super(message: message ?? 'Invalid email or password');
}

// Kelas OrderFailure untuk menangani kegagalan terkait pesanan.
class OrderFailure extends Failure {
  // Konstruktor yang membutuhkan parameter message.
  OrderFailure({required super.message});
}

// Kelas UniqueNameAlreadyInUseFailure untuk menangani kegagalan karena nama unik sudah digunakan.
class UniqueNameAlreadyInUseFailure extends Failure {
  // Konstruktor dengan parameter opsional message.
  // Jika message tidak diberikan, gunakan pesan default 'This unique name is already taken'.
  UniqueNameAlreadyInUseFailure({String? message})
      : super(message: message ?? 'This unique name is already taken');
}

// Kelas EmailNotFoundFailure untuk menangani kegagalan ketika email tidak ditemukan.
class EmailNotFoundFailure extends Failure {
  // Konstruktor dengan parameter opsional message.
  // Jika message tidak diberikan, gunakan pesan default 'User not found'.
  EmailNotFoundFailure({String? message})
      : super(message: message ?? 'User not found');
}

// Kelas WrongPasswordFailure untuk menangani kegagalan karena kata sandi salah.
class WrongPasswordFailure extends Failure {
  // Konstruktor dengan parameter opsional message.
  // Jika message tidak diberikan, gunakan pesan default 'Password is incorrect'.
  WrongPasswordFailure({String? message})
      : super(message: message ?? 'Password is incorrect');
}

// Kelas NoInternetFailure untuk menangani kegagalan karena tidak ada koneksi internet.
class NoInternetFailure extends Failure {
  // Konstruktor tanpa parameter message, menggunakan pesan default 'No internet connection'.
  NoInternetFailure() : super(message: 'No internet connection');
}