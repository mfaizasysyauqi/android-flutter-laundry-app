class User {
  final String id;
  final String role;
  final String fullName;
  final String uniqueName;
  final String email;
  final String phoneNumber;
  final String address;
  int regulerPrice;
  int expressPrice;
  final DateTime createdAt;

  User({
    required this.id,
    required this.role,
    required this.fullName,
    required this.uniqueName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    this.regulerPrice = 7000,
    this.expressPrice = 10000,
    required this.createdAt,
  });
}
