// File: lib/presentation/providers/user_provider.dart
// Berisi definisi provider dan state management untuk pengelolaan data pengguna.
// Menyediakan logika pengambilan data pengguna dan pembaruan harga laundry.

// Mengimpor package dan file yang diperlukan.
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/data/datasources/remote/user_remote_data_source.dart';
import 'package:flutter_laundry_app/data/repositories/user_repository_impl.dart';
import 'package:flutter_laundry_app/domain/entities/user.dart';
import 'package:flutter_laundry_app/domain/usecases/user/get_customer_use_case.dart';
import 'package:flutter_laundry_app/domain/usecases/user/get_user_by_id_use_case.dart';
import 'package:flutter_laundry_app/domain/usecases/user/get_user_by_unique_name_use_case.dart';
import 'package:flutter_laundry_app/domain/usecases/user/get_user_use_case.dart';
import 'package:flutter_laundry_app/domain/usecases/user/update_laundry_price_use_case.dart';
import 'package:flutter_laundry_app/presentation/providers/core_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mendefinisikan provider untuk UserRemoteDataSource.
// Provider ini menyediakan instance UserRemoteDataSource untuk operasi data pengguna.
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  // Mengembalikan instance UserRemoteDataSourceImpl dengan dependensi Firestore dan FirebaseAuth.
  return UserRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

// Mendefinisikan provider untuk UserRepositoryImpl.
// Provider ini menyediakan instance UserRepositoryImpl untuk operasi pengguna.
final userRepositoryProvider = Provider<UserRepositoryImpl>((ref) {
  // Mengembalikan instance UserRepositoryImpl dengan dependensi yang diperlukan.
  return UserRepositoryImpl(
    authRemoteDataSource: ref.watch(firebaseAuthRemoteDataSourceProvider),
    userRemoteDataSource: ref.watch(userRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// Mendefinisikan provider untuk GetUserUseCase.
// Provider ini menyediakan instance GetUserUseCase untuk mengambil data pengguna saat ini.
final getUserUseCaseProvider = Provider<GetUserUseCase>((ref) {
  // Mengembalikan instance GetUserUseCase dengan UserRepositoryImpl sebagai dependensi.
  return GetUserUseCase(ref.watch(userRepositoryProvider));
});

// Mendefinisikan provider untuk GetCustomersUseCase.
// Provider ini menyediakan instance GetCustomersUseCase untuk mengambil daftar pelanggan.
final getCustomersUseCaseProvider = Provider<GetCustomersUseCase>((ref) {
  // Mengembalikan instance GetCustomersUseCase dengan UserRepositoryImpl sebagai dependensi.
  return GetCustomersUseCase(ref.watch(userRepositoryProvider));
});

// Mendefinisikan provider untuk GetUserByIdUseCase.
// Provider ini menyediakan instance GetUserByIdUseCase untuk mengambil pengguna berdasarkan ID.
final getUserByIdUseCaseProvider = Provider<GetUserByIdUseCase>((ref) {
  // Mengembalikan instance GetUserByIdUseCase dengan UserRepositoryImpl sebagai dependensi.
  return GetUserByIdUseCase(ref.watch(userRepositoryProvider));
});

// Mendefinisikan provider untuk GetUserByUniqueNameUseCase.
// Provider ini menyediakan instance GetUserByUniqueNameUseCase untuk mengambil pengguna berdasarkan nama unik.
final getUserByUniqueNameUseCaseProvider =
    Provider<GetUserByUniqueNameUseCase>((ref) {
  // Mengembalikan instance GetUserByUniqueNameUseCase dengan UserRepositoryImpl.
  return GetUserByUniqueNameUseCase(ref.watch(userRepositoryProvider));
});

// Mendefinisikan provider untuk UpdateLaundryPriceUseCase.
// Provider ini menyediakan instance UpdateLaundryPriceUseCase untuk memperbarui harga laundry.
final updateLaundryPriceUseCaseProvider =
    Provider<UpdateLaundryPriceUseCase>((ref) {
  // Mengembalikan instance UpdateLaundryPriceUseCase dengan UserRepositoryImpl.
  return UpdateLaundryPriceUseCase(ref.watch(userRepositoryProvider));
});

// Kelas UserState untuk menyimpan status pengguna.
// Kelas ini digunakan untuk mengelola state dalam UserNotifier.
class UserState {
  // Properti untuk menyimpan data pengguna (nullable).
  final User? user;
  // Properti untuk menandakan apakah sedang memuat data.
  final bool isLoading;
  // Properti untuk menyimpan informasi kegagalan (nullable).
  final Failure? failure;

  // Konstruktor untuk UserState dengan nilai default.
  UserState({
    this.user,
    this.isLoading = false,
    this.failure,
  });

  // Method untuk membuat salinan UserState dengan nilai baru.
  // Digunakan untuk memperbarui state tanpa mengubah objek asli.
  UserState copyWith({
    User? user,
    bool? isLoading,
    Failure? failure,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      failure: failure ?? this.failure,
    );
  }
}

// Kelas UserNotifier untuk mengelola logika pengguna.
// Kelas ini memperluas StateNotifier untuk mengelola UserState.
class UserNotifier extends StateNotifier<UserState> {
  // Properti untuk menyimpan instance GetUserUseCase.
  final GetUserUseCase _getUserUseCase;
  // Properti untuk menyimpan instance UpdateLaundryPriceUseCase.
  final UpdateLaundryPriceUseCase _updateLaundryPriceUseCase;

  // Konstruktor yang menginisialisasi UserNotifier dengan use case dan state awal.
  UserNotifier({
    required GetUserUseCase getUserUseCase,
    required UpdateLaundryPriceUseCase updateLaundryPriceUseCase,
  })  : _getUserUseCase = getUserUseCase,
        _updateLaundryPriceUseCase = updateLaundryPriceUseCase,
        super(UserState());

  // Method untuk mengambil data pengguna saat ini.
  Future<void> getUser() async {
    // Perbarui state ke loading dan hapus kegagalan sebelumnya.
    state = state.copyWith(isLoading: true, failure: null);
    // Panggil GetUserUseCase untuk mengambil data pengguna.
    final result = await _getUserUseCase();
    // Tangani hasil menggunakan fold dari Either.
    result.fold(
      // Jika gagal, perbarui state dengan informasi kegagalan.
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      // Jika sukses, perbarui state dengan data pengguna.
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }

  // Method untuk memperbarui harga laundry.
  // Menerima harga reguler dan express sebagai parameter.
  Future<void> updateLaundryPrice(int regulerPrice, int expressPrice) async {
    // Perbarui state ke loading dan hapus kegagalan sebelumnya.
    state = state.copyWith(isLoading: true, failure: null);
    // Panggil UpdateLaundryPriceUseCase untuk memperbarui harga.
    final result = await _updateLaundryPriceUseCase(regulerPrice, expressPrice);
    // Tangani hasil menggunakan fold dari Either.
    result.fold(
      // Jika gagal, perbarui state dan lempar exception.
      (failure) {
        state = state.copyWith(isLoading: false, failure: failure);
        throw Exception('Failed to update prices: ${failure.message}');
      },
      // Jika sukses, perbarui state dengan data pengguna yang diperbarui.
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }
}

// Mendefinisikan provider untuk UserNotifier.
// Provider ini menyediakan instance UserNotifier untuk mengelola state pengguna.
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  // Mengambil instance GetUserUseCase dari getUserUseCaseProvider.
  final getUserUseCase = ref.watch(getUserUseCaseProvider);
  // Mengambil instance UpdateLaundryPriceUseCase dari updateLaundryPriceUseCaseProvider.
  final updateLaundryPriceUseCase =
      ref.watch(updateLaundryPriceUseCaseProvider);
  // Mengembalikan instance UserNotifier dengan use case yang diperlukan.
  return UserNotifier(
    getUserUseCase: getUserUseCase,
    updateLaundryPriceUseCase: updateLaundryPriceUseCase,
  );
});

// Mendefinisikan provider untuk daftar pelanggan.
// Provider ini menyediakan future daftar pelanggan menggunakan GetCustomersUseCase.
final customersProvider = FutureProvider<List<User>>((ref) async {
  // Mengambil instance GetCustomersUseCase dari getCustomersUseCaseProvider.
  final getCustomersUseCase = ref.watch(getCustomersUseCaseProvider);
  // Panggil use case untuk mengambil daftar pelanggan.
  final result = await getCustomersUseCase();
  // Tangani hasil menggunakan fold dari Either.
  return result.fold(
    // Jika gagal, lempar exception dengan pesan error.
    (failure) => throw Exception('Failed to fetch customers: $failure'),
    // Jika sukses, kembalikan daftar pelanggan.
    (customers) => customers,
  );
});

// Mendefinisikan provider untuk nama unik laundry berdasarkan ID laundry.
// Provider ini menggunakan GetUserByIdUseCase untuk mendapatkan nama unik.
final laundryUniqueNameProvider =
    FutureProvider.family<String, String>((ref, laundryId) async {
  // Mengambil instance GetUserByIdUseCase dari getUserByIdUseCaseProvider.
  final getUserByIdUseCase = ref.watch(getUserByIdUseCaseProvider);
  // Panggil use case untuk mengambil pengguna berdasarkan ID.
  final result = await getUserByIdUseCase(laundryId);
  // Tangani hasil menggunakan fold dari Either.
  return result.fold(
    // Jika gagal, lempar exception dengan pesan error.
    (failure) => throw Exception('Failed to fetch laundry name: $failure'),
    // Jika sukses, kembalikan nama unik pengguna.
    (user) => user.uniqueName,
  );
});

// Mendefinisikan provider untuk data pengguna saat ini.
// Provider ini mengambil data pengguna dari Firestore berdasarkan ID pengguna saat ini.
final currentUserProvider = FutureProvider<User>((ref) async {
  // Mengambil instance FirebaseAuth dari firebaseAuthProvider.
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  // Mengambil instance FirebaseFirestore dari firestoreProvider.
  final firestore = ref.watch(firestoreProvider);

  // Ambil pengguna saat ini dari FirebaseAuth.
  final currentUser = firebaseAuth.currentUser;
  // Periksa apakah pengguna sudah login; jika tidak, lempar exception.
  if (currentUser == null) {
    throw Exception('No user logged in');
  }

  // Ambil dokumen pengguna dari Firestore berdasarkan ID pengguna.
  final userDoc =
      await firestore.collection('users').doc(currentUser.uid).get();

  // Periksa apakah dokumen pengguna ada; jika tidak, lempar exception.
  if (!userDoc.exists) {
    throw Exception('User data not found');
  }

  // Ambil data dari dokumen pengguna.
  final data = userDoc.data()!;

  // Konversi createdAt ke DateTime, menangani format Timestamp atau String.
  DateTime createdAt;
  if (data['createdAt'] is fs.Timestamp) {
    createdAt = (data['createdAt'] as fs.Timestamp).toDate();
  } else if (data['createdAt'] is String) {
    createdAt = DateTime.parse(data['createdAt'] as String);
  } else {
    createdAt = DateTime.now();
  }

  // Kembalikan instance User dengan data dari Firestore.
  return User(
    id: currentUser.uid,
    role: data['role'] as String,
    fullName: data['fullName'] as String,
    uniqueName: data['uniqueName'] as String,
    email: data['email'] as String,
    phoneNumber: data['phoneNumber'] as String,
    address: data['address'] as String,
    regulerPrice: data['regulerPrice'] as int? ?? 7000,
    expressPrice: data['expressPrice'] as int? ?? 10000,
    createdAt: createdAt,
  );
});

// Mendefinisikan provider untuk peran pengguna saat ini.
// Provider ini mengambil peran pengguna dari Firestore berdasarkan ID pengguna.
final userRoleProvider = FutureProvider<String>((ref) async {
  // Ambil pengguna saat ini dari FirebaseAuth.
  final user = ref.watch(firebaseAuthProvider).currentUser;
  // Periksa apakah pengguna sudah login; jika tidak, lempar exception.
  if (user == null) throw Exception('No user logged in');

  // Ambil dokumen pengguna dari Firestore.
  final userDoc = await ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .get();
  // Periksa apakah dokumen pengguna ada; jika tidak, lempar exception.
  if (!userDoc.exists) throw Exception('User data not found');
  // Kembalikan peran pengguna dari data dokumen.
  return userDoc['role'] as String;
});

// Mendefinisikan provider untuk nama unik pengguna saat ini.
// Provider ini mengambil nama unik dari Firestore berdasarkan ID pengguna.
final currentUserUniqueNameProvider = FutureProvider<String>((ref) async {
  // Ambil pengguna saat ini dari FirebaseAuth.
  final user = ref.watch(firebaseAuthProvider).currentUser;
  // Periksa apakah pengguna sudah login; jika tidak, lempar exception.
  if (user == null) throw Exception('No user logged in');

  // Ambil dokumen pengguna dari Firestore.
  final userDoc = await ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .get();
  // Periksa apakah dokumen pengguna ada; jika tidak, lempar exception.
  if (!userDoc.exists) throw Exception('User data not found');
  // Kembalikan nama unik pengguna dari data dokumen.
  return userDoc['uniqueName'] as String;
});