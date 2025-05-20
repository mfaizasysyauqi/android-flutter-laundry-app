// File: lib/presentation/providers/auth_provider.dart
// Berisi definisi provider dan state management untuk autentikasi pengguna.
// Menyediakan logika login dan registrasi menggunakan Riverpod dan Firebase Authentication.

// Mengimpor package dan file yang diperlukan.
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/data/repositories/auth_repository_impl.dart';
import 'package:flutter_laundry_app/domain/entities/user.dart';
import 'package:flutter_laundry_app/domain/repositories/auth_repository.dart';
import 'package:flutter_laundry_app/domain/usecases/auth/login_use_case.dart';
import 'package:flutter_laundry_app/domain/usecases/auth/register_use_case.dart';
import 'package:flutter_laundry_app/presentation/providers/core_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

// Mendefinisikan provider untuk AuthRepository.
// Provider ini menyediakan instance AuthRepositoryImpl untuk digunakan di seluruh aplikasi.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Mengambil remoteDataSource dari firebaseAuthRemoteDataSourceProvider.
  final remoteDataSource = ref.watch(firebaseAuthRemoteDataSourceProvider);
  // Mengambil networkInfo dari networkInfoProvider untuk pemeriksaan koneksi jaringan.
  final networkInfo = ref.watch(networkInfoProvider);
  // Mengembalikan instance AuthRepositoryImpl dengan dependensi yang diperlukan.
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

// Mendefinisikan provider untuk use case registrasi.
// Provider ini menyediakan instance RegisterUseCase.
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  // Mengambil authRepository dari authRepositoryProvider.
  final authRepository = ref.watch(authRepositoryProvider);
  // Mengembalikan instance RegisterUseCase dengan authRepository sebagai dependensi.
  return RegisterUseCase(authRepository);
});

// Mendefinisikan provider untuk use case login.
// Provider ini menyediakan instance LoginUseCase.
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  // Mengambil authRepository dari authRepositoryProvider.
  final authRepository = ref.watch(authRepositoryProvider);
  // Mengembalikan instance LoginUseCase dengan authRepository sebagai dependensi.
  return LoginUseCase(authRepository);
});

// Mendefinisikan enum untuk status autentikasi.
// Enum ini digunakan untuk melacak status proses autentikasi (initial, loading, success, error).
enum AuthStatus { initial, loading, success, error }

// Kelas AuthState untuk menyimpan status autentikasi.
// Kelas ini digunakan untuk mengelola state autentikasi dalam AuthNotifier.
class AuthState {
  // Properti untuk menyimpan status autentikasi (default: initial).
  final AuthStatus status;
  // Properti untuk menyimpan data pengguna (nullable).
  final User? user;
  // Properti untuk menyimpan informasi kegagalan (nullable).
  final Failure? failure;
  // Properti untuk menyimpan jenis operasi (misalnya, 'register' atau 'login').
  final String operationType;

  // Konstruktor untuk AuthState dengan nilai default.
  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.failure,
    this.operationType = '',
  });

  // Getter untuk memeriksa apakah status sedang loading.
  bool get isLoading => status == AuthStatus.loading;

  // Method untuk membuat salinan AuthState dengan nilai baru.
  // Digunakan untuk memperbarui state tanpa mengubah objek asli.
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    Failure? failure,
    String? operationType,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      failure: failure ?? this.failure,
      operationType: operationType ?? this.operationType,
    );
  }
}

// Kelas AuthNotifier untuk mengelola logika autentikasi.
// Kelas ini memperluas StateNotifier untuk mengelola AuthState.
class AuthNotifier extends StateNotifier<AuthState> {
  // Properti untuk menyimpan instance RegisterUseCase.
  final RegisterUseCase _registerUseCase;
  // Properti untuk menyimpan instance LoginUseCase.
  final LoginUseCase _loginUseCase;
  // Flag untuk mencegah pemrosesan ganda selama operasi asinkronus.
  bool _isProcessing = false;

  // Konstruktor yang menginisialisasi AuthNotifier dengan use case dan state awal.
  AuthNotifier(this._registerUseCase, this._loginUseCase) : super(AuthState());

  // Method untuk mereset state ke kondisi awal.
  // Mengatur ulang state dan flag _isProcessing.
  void resetState() {
    state = AuthState();
    _isProcessing = false;
  }

  // Method untuk menangani registrasi pengguna.
  // Menerima parameter yang diperlukan untuk registrasi.
  Future<void> register({
    required String role,
    required String fullName,
    required String uniqueName,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
  }) async {
    // Cek apakah sedang memproses operasi lain; jika ya, keluar.
    if (_isProcessing) return;
    // Set flag pemrosesan ke true.
    _isProcessing = true;

    // Perbarui state ke loading dengan operasi registrasi.
    state =
        state.copyWith(status: AuthStatus.loading, operationType: 'register');

    // Panggil RegisterUseCase untuk melakukan registrasi.
    final result = await _registerUseCase(
      role: role,
      fullName: fullName,
      uniqueName: uniqueName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      address: address,
    );

    // Tangani hasil registrasi menggunakan fold dari Either.
    result.fold(
      // Jika gagal, perbarui state dengan status error dan informasi kegagalan.
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        failure: failure,
        user: null,
      ),
      // Jika sukses, perbarui state dengan status sukses dan data pengguna.
      (user) => state = state.copyWith(
        status: AuthStatus.success,
        failure: null,
        user: user,
      ),
    );

    // Reset flag pemrosesan setelah selesai.
    _isProcessing = false;
  }

  // Method untuk menangani login pengguna.
  // Menerima email dan password sebagai parameter.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    // Cek apakah sedang memproses operasi lain; jika ya, keluar.
    if (_isProcessing) return;
    // Set flag pemrosesan ke true.
    _isProcessing = true;

    // Perbarui state ke loading dengan operasi login.
    state = state.copyWith(status: AuthStatus.loading, operationType: 'login');

    // Panggil LoginUseCase untuk melakukan login.
    final result = await _loginUseCase(
      email: email,
      password: password,
    );

    // Tangani hasil login menggunakan fold dari Either.
    result.fold(
      // Jika gagal, perbarui state dengan status error dan informasi kegagalan.
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        failure: failure,
      ),
      // Jika sukses, perbarui state dengan status sukses dan data pengguna.
      (user) => state = state.copyWith(
        status: AuthStatus.success,
        user: user,
      ),
    );

    // Reset flag pemrosesan setelah selesai.
    _isProcessing = false;
  }
}

// Mendefinisikan provider untuk AuthNotifier.
// Provider ini menyediakan instance AuthNotifier untuk mengelola state autentikasi.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // Mengambil instance RegisterUseCase dari registerUseCaseProvider.
  final registerUseCase = ref.watch(registerUseCaseProvider);
  // Mengambil instance LoginUseCase dari loginUseCaseProvider.
  final loginUseCase = ref.watch(loginUseCaseProvider);
  // Mengembalikan instance AuthNotifier dengan use case yang diperlukan.
  return AuthNotifier(registerUseCase, loginUseCase);
});

// Mendefinisikan provider untuk memantau perubahan status autentikasi Firebase.
// Provider ini mengembalikan stream dari Firebase Auth untuk melacak status login pengguna.
final authStateProvider = StreamProvider<firebase_auth.User?>((ref) {
  // Mengambil instance FirebaseAuth dari firebaseAuthProvider.
  // Mengembalikan stream authStateChanges untuk memantau perubahan status autentikasi.
  return ref.watch(firebaseAuthProvider).authStateChanges();
});