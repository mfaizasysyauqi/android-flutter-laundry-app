// File: lib/domain/entities/user.dart
// Berisi kelas User untuk merepresentasikan entitas pengguna dalam domain layer.

// Kelas User untuk menyimpan data pengguna.
class User {
  // Properti untuk menyimpan data pengguna.
  final String id;
  final String role;
  final String fullName;
  final String uniqueName;
  final String email;
  final String phoneNumber;
  final String address;
  int regulerPrice; // Harga reguler untuk laundry.
  int expressPrice; // Harga express untuk laundry.
  final DateTime createdAt;

  // Konstruktor dengan parameter wajib dan opsional.
  User({
    required this.id,
    required this.role,
    required this.fullName,
    required this.uniqueName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    this.regulerPrice = 7000, // Default harga reguler.
    this.expressPrice = 10000, // Default harga express.
    required this.createdAt,
  });
}