// File: validators.dart
// Berisi kelas Validators untuk memvalidasi input pengguna seperti email, kata sandi, dan nomor telepon.

// Kelas Validators berisi method-method statis untuk validasi input.
class Validators {
  // Method untuk memvalidasi peran (role).
  static String? validateRole(String? value) {
    // Periksa jika nilai kosong atau null.
    if (value == null || value.isEmpty) {
      return 'Role cannot be empty';
    }
    return null; // Kembalikan null jika valid.
  }

  // Method untuk memvalidasi nama lengkap.
  static String? validateFullName(String? value) {
    // Periksa jika nama kosong atau null.
    if (value == null || value.isEmpty) {
      return 'Full name cannot be empty';
    }
    return null; // Kembalikan null jika valid.
  }

  // Method untuk memvalidasi nama unik.
  static String? validateUniqueName(String? value) {
    // Periksa jika nama unik kosong atau null.
    if (value == null || value.isEmpty) {
      return 'Unique name cannot be empty';
    }
    return null; // Kembalikan null jika valid.
  }

  // Method untuk memvalidasi email.
  static String? validateEmail(String? value) {
    // Periksa jika email kosong atau null.
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }

    // Gunakan regular expression untuk memeriksa format email.
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Email is not valid';
    }
    return null; // Kembalikan null jika valid.
  }

  // Method untuk memvalidasi kata sandi.
  static String? validatePassword(String? value) {
    // Periksa jika kata sandi kosong atau null.
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }

    // Periksa panjang kata sandi minimal 6 karakter.
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null; // Kembalikan null jika valid.
  }

  // Method untuk memvalidasi nomor telepon.
  static String? validatePhoneNumber(String? value) {
    // Periksa jika nomor telepon kosong atau null.
    if (value == null || value.isEmpty) {
      return 'Phone number cannot be empty';
    }

    // Gunakan regular expression untuk memeriksa format nomor telepon (10-13 digit).
    final phoneRegExp = RegExp(r'^[0-9]{10,13}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Phone number is not valid';
    }
    return null; // Kembalikan null jika valid.
  }

  // Method untuk memvalidasi alamat.
  static String? validateAddress(String? value) {
    // Periksa jika alamat kosong atau null.
    if (value == null || value.isEmpty) {
      return 'Address cannot be empty';
    }
    return null; // Kembalikan null jika valid.
  }

  // Method untuk memvalidasi input numerik.
  static String? validateNumeric(String? value, String errorMessage) {
    // Periksa jika nilai kosong atau null.
    if (value == null || value.isEmpty) {
      return errorMessage;
    }

    // Periksa jika nilai dapat diubah menjadi integer.
    if (int.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null; // Kembalikan null jika valid.
  }

  // Method untuk menangani error login dan menetapkan pesan error ke field email atau kata sandi.
  static void handleLoginErrors(
    String errorMessage,
    Function(String?) setEmailError,
    Function(String?) setPasswordError,
  ) {
    // Periksa jenis error berdasarkan pesan error.
    if (errorMessage.contains("User not found") ||
        errorMessage.contains("Email not found") ||
        errorMessage.contains("user-not-found") ||
        errorMessage.contains("EmailNotFoundException")) {
      // Jika pengguna tidak ditemukan, set pesan error untuk email.
      setEmailError('User not found. Please check your email.');
      setPasswordError(null);
    } else if (errorMessage.contains("incorrect") ||
        errorMessage.contains("wrong") ||
        errorMessage.contains("wrong-password") ||
        errorMessage.contains("WrongPasswordException")) {
      // Jika kata sandi salah, set pesan error untuk kata sandi.
      setEmailError(null);
      setPasswordError('Password is incorrect. Please try again.');
    } else {
      // Jika error tidak dikenali, kosongkan kedua pesan error.
      setEmailError(null);
      setPasswordError(null);
    }
  }
}