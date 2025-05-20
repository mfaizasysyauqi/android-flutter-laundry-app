// File: lib/presentation/providers/voucher_provider.dart
// Berisi definisi provider dan state management untuk pengelolaan voucher.
// Menyediakan logika pembuatan, pembaruan, penghapusan, dan pengambilan daftar voucher.

// Mengimpor package dan file yang diperlukan.
import 'package:dartz/dartz.dart';
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/data/datasources/remote/voucher_remote_data_source.dart';
import 'package:flutter_laundry_app/data/repositories/voucher_repository_impl.dart';
import 'package:flutter_laundry_app/domain/entities/user.dart';
import 'package:flutter_laundry_app/domain/entities/voucher.dart';
import 'package:flutter_laundry_app/domain/repositories/voucher_repository.dart';
import 'package:flutter_laundry_app/domain/usecases/user/get_user_by_id_use_case.dart';
import 'package:flutter_laundry_app/domain/usecases/voucher/create_voucher_use_case.dart';
import 'package:flutter_laundry_app/domain/usecases/voucher/delete_voucher_use_case.dart';
import 'package:flutter_laundry_app/domain/usecases/voucher/get_vouchers_by_owner_and_laundry_ids_use_case.dart';
import 'package:flutter_laundry_app/domain/usecases/voucher/get_vouchers_by_user_id_or_laundry_id_use_case.dart';
import 'package:flutter_laundry_app/domain/usecases/voucher/get_vouchers_by_user_id_use_case.dart';
import 'package:flutter_laundry_app/domain/usecases/voucher/get_vouchers_by_laundry_id_use_case.dart';
import 'package:flutter_laundry_app/domain/usecases/voucher/update_voucher_owner_use_case.dart';
import 'package:flutter_laundry_app/domain/usecases/voucher/update_voucher_use_case.dart';
import 'package:flutter_laundry_app/presentation/providers/core_provider.dart';
import 'package:flutter_laundry_app/presentation/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mendefinisikan provider untuk VoucherRemoteDataSource.
// Provider ini menyediakan instance VoucherRemoteDataSource untuk operasi data voucher.
final voucherRemoteDataSourceProvider =
    Provider<VoucherRemoteDataSource>((ref) {
  // Mengembalikan instance VoucherRemoteDataSourceImpl dengan dependensi Firestore dan FirebaseAuth.
  return VoucherRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

// Mendefinisikan provider untuk VoucherRepository.
// Provider ini menyediakan instance VoucherRepository untuk operasi voucher.
final voucherRepositoryProvider = Provider<VoucherRepository>((ref) {
  // Mengembalikan instance VoucherRepositoryImpl dengan dependensi yang diperlukan.
  return VoucherRepositoryImpl(
    remoteDataSource: ref.watch(voucherRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// Mendefinisikan provider untuk CreateVoucherUseCase.
// Provider ini menyediakan instance CreateVoucherUseCase untuk membuat voucher.
final createVoucherUseCaseProvider = Provider<CreateVoucherUseCase>((ref) {
  // Mengembalikan instance CreateVoucherUseCase dengan VoucherRepository sebagai dependensi.
  return CreateVoucherUseCase(ref.watch(voucherRepositoryProvider));
});

// Mendefinisikan provider untuk UpdateVoucherOwnerUseCase.
// Provider ini menyediakan instance UpdateVoucherOwnerUseCase untuk memperbarui pemilik voucher.
final updateVoucherOwnerUseCaseProvider =
    Provider<UpdateVoucherOwnerUseCase>((ref) {
  // Mengembalikan instance UpdateVoucherOwnerUseCase dengan VoucherRepository.
  return UpdateVoucherOwnerUseCase(ref.watch(voucherRepositoryProvider));
});

// Mendefinisikan provider untuk GetVouchersByUserIdUseCase.
// Provider ini menyediakan instance GetVouchersByUserIdUseCase untuk mengambil voucher berdasarkan ID pengguna.
final getVouchersByUserIdUseCaseProvider =
    Provider<GetVouchersByUserIdUseCase>((ref) {
  // Mengembalikan instance GetVouchersByUserIdUseCase dengan VoucherRepository.
  return GetVouchersByUserIdUseCase(ref.watch(voucherRepositoryProvider));
});

// Mendefinisikan provider untuk GetVouchersByUserIdOrLaundryIdUseCase.
// Provider ini menyediakan instance untuk mengambil voucher berdasarkan ID pengguna atau laundry.
final getVouchersByUserIdOrLaundryIdUseCaseProvider =
    Provider<GetVouchersByUserIdOrLaundryIdUseCase>((ref) {
  // Mengembalikan instance GetVouchersByUserIdOrLaundryIdUseCase dengan VoucherRepository.
  return GetVouchersByUserIdOrLaundryIdUseCase(
      ref.watch(voucherRepositoryProvider));
});

// Mendefinisikan provider untuk GetVouchersByLaundryIdUseCase.
// Provider ini menyediakan instance GetVouchersByLaundryIdUseCase untuk mengambil voucher berdasarkan ID laundry.
final getVouchersByLaundryIdUseCaseProvider =
    Provider<GetVouchersByLaundryIdUseCase>((ref) {
  // Mengembalikan instance GetVouchersByLaundryIdUseCase dengan VoucherRepository.
  return GetVouchersByLaundryIdUseCase(ref.watch(voucherRepositoryProvider));
});

// Mendefinisikan provider untuk UpdateVoucherUseCase.
// Provider ini menyediakan instance UpdateVoucherUseCase untuk memperbarui voucher.
final updateVoucherUseCaseProvider = Provider<UpdateVoucherUseCase>((ref) {
  // Mengembalikan instance UpdateVoucherUseCase dengan VoucherRepository.
  return UpdateVoucherUseCase(ref.watch(voucherRepositoryProvider));
});

// Mendefinisikan provider untuk DeleteVoucherUseCase.
// Provider ini menyediakan instance DeleteVoucherUseCase untuk menghapus voucher.
final deleteVoucherUseCaseProvider = Provider<DeleteVoucherUseCase>((ref) {
  // Mengembalikan instance DeleteVoucherUseCase dengan VoucherRepository.
  return DeleteVoucherUseCase(ref.watch(voucherRepositoryProvider));
});

// Mendefinisikan provider untuk GetVouchersByOwnerAndLaundryIdUseCase.
// Provider ini menyediakan instance untuk mengambil voucher berdasarkan pemilik dan ID laundry.
final getVouchersByOwnerAndLaundryIdUseCaseProvider =
    Provider<GetVouchersByOwnerAndLaundryIdUseCase>((ref) {
  // Mengembalikan instance GetVouchersByOwnerAndLaundryIdUseCase dengan VoucherRepository.
  return GetVouchersByOwnerAndLaundryIdUseCase(
      ref.watch(voucherRepositoryProvider));
});

// Kelas VoucherNotifier untuk mengelola pembuatan voucher.
// Kelas ini memperluas StateNotifier untuk mengelola state AsyncValue<Voucher?>.
class VoucherNotifier extends StateNotifier<AsyncValue<Voucher?>> {
  // Properti untuk menyimpan instance CreateVoucherUseCase.
  final CreateVoucherUseCase createVoucherUseCase;

  // Konstruktor yang menginisialisasi VoucherNotifier dengan use case dan state awal.
  VoucherNotifier(this.createVoucherUseCase)
      : super(const AsyncValue.data(null));

  // Method untuk membuat voucher baru.
  // Menerima instance Voucher sebagai parameter.
  Future<void> createVoucher(Voucher voucher) async {
    // Perbarui state ke loading.
    state = const AsyncValue.loading();
    try {
      // Panggil CreateVoucherUseCase untuk membuat voucher.
      final result = await createVoucherUseCase(voucher);
      // Tangani hasil menggunakan fold dari Either.
      result.fold(
        // Jika gagal, perbarui state ke error dengan pesan kegagalan.
        (failure) {
          state = AsyncValue.error(
            'Failed to create voucher: ${failure.toString()}',
            StackTrace.current,
          );
        },
        // Jika sukses, perbarui state dengan voucher yang dibuat.
        (voucher) {
          state = AsyncValue.data(voucher);
        },
      );
    } catch (e, stackTrace) {
      // Tangani error tak terduga dan perbarui state ke error.
      state = AsyncValue.error(
        'Unexpected error while creating voucher: $e',
        stackTrace,
      );
    }
  }
}

// Kelas VoucherListState untuk menyimpan status daftar voucher.
// Kelas ini digunakan untuk mengelola state dalam VoucherListNotifier.
class VoucherListState {
  // Properti untuk menyimpan daftar voucher.
  final List<Voucher> vouchers;
  // Properti untuk menyimpan nama laundry berdasarkan ID.
  final Map<String, String> laundryNames;
  // Properti untuk menandakan apakah sedang memuat data.
  final bool isLoading;
  // Properti untuk menyimpan pesan error (nullable).
  final String? error;

  // Konstruktor untuk VoucherListState dengan nilai default.
  VoucherListState({
    this.vouchers = const [],
    this.laundryNames = const {},
    this.isLoading = false,
    this.error,
  });

  // Method untuk membuat salinan VoucherListState dengan nilai baru.
  // Digunakan untuk memperbarui state tanpa mengubah objek asli.
  VoucherListState copyWith({
    List<Voucher>? vouchers,
    Map<String, String>? laundryNames,
    bool? isLoading,
    String? error,
  }) {
    return VoucherListState(
      vouchers: vouchers ?? this.vouchers,
      laundryNames: laundryNames ?? this.laundryNames,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Kelas VoucherListNotifier untuk mengelola daftar voucher.
// Kelas ini memperluas StateNotifier untuk mengelola VoucherListState.
class VoucherListNotifier extends StateNotifier<VoucherListState> {
  // Properti untuk menyimpan instance GetVouchersByUserIdUseCase.
  final GetVouchersByUserIdUseCase getVouchersByUserIdUseCase;
  // Properti untuk menyimpan instance GetVouchersByUserIdOrLaundryIdUseCase.
  final GetVouchersByUserIdOrLaundryIdUseCase
      getVouchersByUserIdOrLaundryIdUseCase;
  // Properti untuk menyimpan instance GetVouchersByLaundryIdUseCase.
  final GetVouchersByLaundryIdUseCase getVouchersByLaundryIdUseCase;
  // Properti untuk menyimpan instance GetUserByIdUseCase.
  final GetUserByIdUseCase getUserByIdUseCase;
  // Properti untuk menyimpan ID pengguna (nullable).
  final String? userId;
  // Properti untuk menyimpan ID laundry untuk refresh admin (nullable).
  String? _laundryId;

  // Konstruktor yang menginisialisasi VoucherListNotifier dan memulai pengambilan voucher.
  VoucherListNotifier({
    required this.getVouchersByUserIdUseCase,
    required this.getVouchersByUserIdOrLaundryIdUseCase,
    required this.getVouchersByLaundryIdUseCase,
    required this.getUserByIdUseCase,
    this.userId,
  }) : super(VoucherListState(isLoading: true)) {
    // Panggil method fetchVouchers untuk mengambil voucher saat inisialisasi.
    fetchVouchers();
  }

  // Method untuk mengambil voucher berdasarkan ID pengguna atau tanpa ID.
  Future<void> fetchVouchers() async {
    // Perbarui state ke loading dan hapus error sebelumnya.
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Pilih use case berdasarkan ada atau tidaknya userId.
      final Either<Failure, List<Voucher>> result = userId != null
          ? await getVouchersByUserIdOrLaundryIdUseCase(
              userId: userId!,
              includeOwner: true,
            )
          : await getVouchersByUserIdUseCase();
      // Tangani hasil menggunakan fold dari Either.
      result.fold(
        // Jika gagal, perbarui state dengan pesan error.
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: 'Failed to fetch vouchers: ${failure.toString()}',
          );
        },
        // Jika sukses, ambil nama laundry untuk setiap voucher.
        (vouchers) async {
          // Dapatkan daftar ID laundry unik dari voucher.
          final laundryIds =
              vouchers.map((voucher) => voucher.laundryId).toSet().toList();

          // Buat map untuk menyimpan nama laundry.
          final Map<String, String> laundryNames = {};
          for (final laundryId in laundryIds) {
            // Panggil GetUserByIdUseCase untuk mendapatkan nama laundry.
            final Either<Failure, User> userResult =
                await getUserByIdUseCase(laundryId);
            userResult.fold(
              // Jika gagal, set nama default 'Unknown Laundry'.
              (failure) {
                laundryNames[laundryId] = 'Unknown Laundry';
              },
              // Jika sukses, simpan nama unik laundry.
              (user) {
                laundryNames[laundryId] = user.uniqueName;
              },
            );
          }

          // Perbarui state dengan daftar voucher dan nama laundry.
          state = state.copyWith(
            vouchers: vouchers,
            laundryNames: laundryNames,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      // Tangani error tak terduga dan perbarui state dengan pesan error.
      state = state.copyWith(
        isLoading: false,
        error: 'Unexpected error while fetching vouchers: $e',
      );
    }
  }

  // Method untuk mengambil voucher berdasarkan ID laundry.
  // Digunakan untuk admin atau konteks tertentu.
  Future<void> fetchVouchersByLaundryId(String laundryId) async {
    // Simpan ID laundry untuk keperluan refresh.
    _laundryId = laundryId;
    // Perbarui state ke loading dan hapus error sebelumnya.
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Panggil GetVouchersByLaundryIdUseCase untuk mengambil voucher.
      final Either<Failure, List<Voucher>> result =
          await getVouchersByLaundryIdUseCase(laundryId);
      // Tangani hasil menggunakan fold dari Either.
      result.fold(
        // Jika gagal, perbarui state dengan pesan error.
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: 'Failed to fetch vouchers: ${failure.toString()}',
          );
        },
        // Jika sukses, ambil nama laundry untuk setiap voucher.
        (vouchers) async {
          // Dapatkan daftar ID laundry unik dari voucher.
          final laundryIds =
              vouchers.map((voucher) => voucher.laundryId).toSet().toList();

          // Buat map untuk menyimpan nama laundry.
          final Map<String, String> laundryNames = {};
          for (final laundryId in laundryIds) {
            // Panggil GetUserByIdUseCase untuk mendapatkan nama laundry.
            final Either<Failure, User> userResult =
                await getUserByIdUseCase(laundryId);
            userResult.fold(
              // Jika gagal, set nama default 'Unknown Laundry'.
              (failure) {
                laundryNames[laundryId] = 'Unknown Laundry';
              },
              // Jika sukses, simpan nama unik laundry.
              (user) {
                laundryNames[laundryId] = user.uniqueName;
              },
            );
          }

          // Perbarui state dengan daftar voucher dan nama laundry.
          state = state.copyWith(
            vouchers: vouchers,
            laundryNames: laundryNames,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      // Tangani error tak terduga dan perbarui state dengan pesan error.
      state = state.copyWith(
        isLoading: false,
        error: 'Unexpected error while fetching vouchers: $e',
      );
    }
  }

  // Method untuk menyegarkan daftar voucher.
  // Memilih method pengambilan berdasarkan userId atau laundryId.
  Future<void> refresh() async {
    if (userId != null) {
      // Jika ada userId, ambil voucher berdasarkan pengguna.
      await fetchVouchers();
    } else if (_laundryId != null) {
      // Jika ada laundryId, ambil voucher berdasarkan laundry.
      await fetchVouchersByLaundryId(_laundryId!);
    } else {
      // Jika tidak ada userId atau laundryId, ambil voucher default.
      await fetchVouchers();
    }
  }
}

// Kelas WorkerVoucherListNotifier untuk mengelola daftar voucher pekerja.
// Kelas ini memperluas StateNotifier untuk mengelola VoucherListState.
class WorkerVoucherListNotifier extends StateNotifier<VoucherListState> {
  // Properti untuk menyimpan instance GetVouchersByOwnerAndLaundryIdUseCase.
  final GetVouchersByOwnerAndLaundryIdUseCase
      getVouchersByOwnerAndLaundryIdUseCase;
  // Properti untuk menyimpan instance GetUserByIdUseCase.
  final GetUserByIdUseCase getUserByIdUseCase;
  // Properti untuk menyimpan ID pemilik voucher.
  final String ownerUserId;
  // Properti untuk menyimpan ID laundry.
  final String laundryId;

  // Konstruktor yang menginisialisasi WorkerVoucherListNotifier dan memulai pengambilan voucher.
  WorkerVoucherListNotifier({
    required this.getVouchersByOwnerAndLaundryIdUseCase,
    required this.getUserByIdUseCase,
    required this.ownerUserId,
    required this.laundryId,
  }) : super(VoucherListState(isLoading: true)) {
    // Panggil method fetchVouchers untuk mengambil voucher saat inisialisasi.
    fetchVouchers();
  }

  // Method untuk mengambil voucher berdasarkan pemilik dan ID laundry.
  Future<void> fetchVouchers() async {
    // Perbarui state ke loading dan hapus error sebelumnya.
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Panggil GetVouchersByOwnerAndLaundryIdUseCase untuk mengambil voucher.
      final Either<Failure, List<Voucher>> result =
          await getVouchersByOwnerAndLaundryIdUseCase(ownerUserId, laundryId);
      // Tangani hasil menggunakan fold dari Either.
      result.fold(
        // Jika gagal, perbarui state dengan pesan error.
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: 'Failed to fetch vouchers: ${failure.toString()}',
          );
        },
        // Jika sukses, ambil nama laundry untuk setiap voucher.
        (vouchers) async {
          // Dapatkan daftar ID laundry unik dari voucher.
          final laundryIds =
              vouchers.map((voucher) => voucher.laundryId).toSet().toList();

          // Buat map untuk menyimpan nama laundry.
          final Map<String, String> laundryNames = {};
          for (final laundryId in laundryIds) {
            // Panggil GetUserByIdUseCase untuk mendapatkan nama laundry.
            final Either<Failure, User> userResult =
                await getUserByIdUseCase(laundryId);
            userResult.fold(
              // Jika gagal, set nama default 'Unknown Laundry'.
              (failure) {
                laundryNames[laundryId] = 'Unknown Laundry';
              },
              // Jika sukses, simpan nama unik laundry.
              (user) {
                laundryNames[laundryId] = user.uniqueName;
              },
            );
          }

          // Perbarui state dengan daftar voucher dan nama laundry.
          state = state.copyWith(
            vouchers: vouchers,
            laundryNames: laundryNames,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      // Tangani error tak terduga dan perbarui state dengan pesan error.
      state = state.copyWith(
        isLoading: false,
        error: 'Unexpected error while fetching vouchers: $e',
      );
    }
  }

  // Method untuk menyegarkan daftar voucher pekerja.
  Future<void> refresh() async {
    // Panggil fetchVouchers untuk memperbarui daftar voucher.
    await fetchVouchers();
  }
}

// Kelas EditVoucherNotifier untuk mengelola pembaruan dan penghapusan voucher.
// Kelas ini memperluas StateNotifier untuk mengelola state AsyncValue<Voucher?>.
class EditVoucherNotifier extends StateNotifier<AsyncValue<Voucher?>> {
  // Properti untuk menyimpan instance UpdateVoucherUseCase.
  final UpdateVoucherUseCase updateVoucherUseCase;
  // Properti untuk menyimpan instance DeleteVoucherUseCase.
  final DeleteVoucherUseCase deleteVoucherUseCase;

  // Konstruktor yang menginisialisasi EditVoucherNotifier dengan use case dan state awal.
  EditVoucherNotifier(this.updateVoucherUseCase, this.deleteVoucherUseCase)
      : super(const AsyncValue.data(null));

  // Method untuk memperbarui voucher.
  // Menerima instance Voucher sebagai parameter.
  Future<void> updateVoucher(Voucher voucher) async {
    // Perbarui state ke loading.
    state = const AsyncValue.loading();
    try {
      // Panggil UpdateVoucherUseCase untuk memperbarui voucher.
      final result = await updateVoucherUseCase(voucher);
      // Tangani hasil menggunakan fold dari Either.
      result.fold(
        // Jika gagal, perbarui state ke error dengan pesan kegagalan.
        (failure) {
          state = AsyncValue.error(
            'Failed to update voucher: ${failure.toString()}',
            StackTrace.current,
          );
        },
        // Jika sukses, perbarui state dengan voucher yang diperbarui.
        (updatedVoucher) {
          state = AsyncValue.data(updatedVoucher);
        },
      );
    } catch (e, stackTrace) {
      // Tangani error tak terduga dan perbarui state ke error.
      state = AsyncValue.error(
        'Unexpected error while updating voucher: $e',
        stackTrace,
      );
    }
  }

  // Method untuk menghapus voucher.
  // Menerima ID voucher sebagai parameter.
  Future<void> deleteVoucher(String voucherId) async {
    // Perbarui state ke loading.
    state = const AsyncValue.loading();
    try {
      // Panggil DeleteVoucherUseCase untuk menghapus voucher.
      final result = await deleteVoucherUseCase(voucherId);
      // Tangani hasil menggunakan fold dari Either.
      result.fold(
        // Jika gagal, perbarui state ke error dengan pesan kegagalan.
        (failure) {
          state = AsyncValue.error(
            'Failed to delete voucher: ${failure.toString()}',
            StackTrace.current,
          );
        },
        // Jika sukses, perbarui state ke null (voucher dihapus).
        (_) {
          state = const AsyncValue.data(null);
        },
      );
    } catch (e, stackTrace) {
      // Tangani error tak terduga dan perbarui state ke error.
      state = AsyncValue.error(
        'Unexpected error while deleting voucher: $e',
        stackTrace,
      );
    }
  }

  // Method untuk mereset state ke nilai awal.
  void reset() {
    // Perbarui state ke data null.
    state = const AsyncValue.data(null);
  }
}

// Mendefinisikan provider untuk VoucherNotifier.
// Provider ini menyediakan instance VoucherNotifier untuk mengelola pembuatan voucher.
final voucherProvider =
    StateNotifierProvider<VoucherNotifier, AsyncValue<Voucher?>>((ref) {
  // Mengambil instance CreateVoucherUseCase dari createVoucherUseCaseProvider.
  final createVoucherUseCase = ref.read(createVoucherUseCaseProvider);
  // Mengembalikan instance VoucherNotifier dengan use case yang diperlukan.
  return VoucherNotifier(createVoucherUseCase);
});

// Mendefinisikan provider untuk VoucherListNotifier dengan parameter userId.
// Provider ini menyediakan instance VoucherListNotifier untuk mengelola daftar voucher.
final voucherListProvider = StateNotifierProvider.family<VoucherListNotifier,
    VoucherListState, String?>((ref, userId) {
  // Mengambil instance GetVouchersByUserIdUseCase dari provider.
  final getVouchersByUserIdUseCase =
      ref.read(getVouchersByUserIdUseCaseProvider);
  // Mengambil instance GetVouchersByUserIdOrLaundryIdUseCase dari provider.
  final getVouchersByUserIdOrLaundryIdUseCase =
      ref.read(getVouchersByUserIdOrLaundryIdUseCaseProvider);
  // Mengambil instance GetVouchersByLaundryIdUseCase dari provider.
  final getVouchersByLaundryIdUseCase =
      ref.read(getVouchersByLaundryIdUseCaseProvider);
  // Mengambil instance GetUserByIdUseCase dari provider.
  final getUserByIdUseCase = ref.read(getUserByIdUseCaseProvider);
  // Mengembalikan instance VoucherListNotifier dengan dependensi dan userId.
  return VoucherListNotifier(
    getVouchersByUserIdUseCase: getVouchersByUserIdUseCase,
    getVouchersByUserIdOrLaundryIdUseCase:
        getVouchersByUserIdOrLaundryIdUseCase,
    getVouchersByLaundryIdUseCase: getVouchersByLaundryIdUseCase,
    getUserByIdUseCase: getUserByIdUseCase,
    userId: userId,
  );
});

// Mendefinisikan provider untuk WorkerVoucherListNotifier dengan parameter WorkerVoucherParams.
// Provider ini menyediakan instance WorkerVoucherListNotifier untuk daftar voucher pekerja.
final workerVoucherListProvider = StateNotifierProvider.family<
    WorkerVoucherListNotifier,
    VoucherListState,
    WorkerVoucherParams>((ref, params) {
  // Mengambil instance GetVouchersByOwnerAndLaundryIdUseCase dari provider.
  final getVouchersByOwnerAndLaundryIdUseCase =
      ref.read(getVouchersByOwnerAndLaundryIdUseCaseProvider);
  // Mengambil instance GetUserByIdUseCase dari provider.
  final getUserByIdUseCase = ref.read(getUserByIdUseCaseProvider);
  // Mengembalikan instance WorkerVoucherListNotifier dengan dependensi dan parameter.
  return WorkerVoucherListNotifier(
    getVouchersByOwnerAndLaundryIdUseCase:
        getVouchersByOwnerAndLaundryIdUseCase,
    getUserByIdUseCase: getUserByIdUseCase,
    ownerUserId: params.ownerUserId,
    laundryId: params.laundryId,
  );
});

// Mendefinisikan provider untuk VoucherListNotifier dengan parameter laundryId untuk admin.
// Provider ini menyediakan instance VoucherListNotifier untuk daftar voucher admin.
final adminVoucherListProvider =
    StateNotifierProvider.family<VoucherListNotifier, VoucherListState, String>(
        (ref, laundryId) {
  // Mengambil instance GetVouchersByUserIdUseCase dari provider.
  final getVouchersByUserIdUseCase =
      ref.read(getVouchersByUserIdUseCaseProvider);
  // Mengambil instance GetVouchersByUserIdOrLaundryIdUseCase dari provider.
  final getVouchersByUserIdOrLaundryIdUseCase =
      ref.read(getVouchersByUserIdOrLaundryIdUseCaseProvider);
  // Mengambil instance GetVouchersByLaundryIdUseCase dari provider.
  final getVouchersByLaundryIdUseCase =
      ref.read(getVouchersByLaundryIdUseCaseProvider);
  // Mengambil instance GetUserByIdUseCase dari provider.
  final getUserByIdUseCase = ref.read(getUserByIdUseCaseProvider);
  // Mengembalikan instance VoucherListNotifier dan langsung panggil fetchVouchersByLaundryId.
  return VoucherListNotifier(
    getVouchersByUserIdUseCase: getVouchersByUserIdUseCase,
    getVouchersByUserIdOrLaundryIdUseCase:
        getVouchersByUserIdOrLaundryIdUseCase,
    getVouchersByLaundryIdUseCase: getVouchersByLaundryIdUseCase,
    getUserByIdUseCase: getUserByIdUseCase,
    userId: null,
  )..fetchVouchersByLaundryId(laundryId);
});

// Mendefinisikan provider untuk EditVoucherNotifier.
// Provider ini menyediakan instance EditVoucherNotifier untuk mengelola pembaruan dan penghapusan voucher.
final editVoucherProvider =
    StateNotifierProvider<EditVoucherNotifier, AsyncValue<Voucher?>>((ref) {
  // Mengambil instance UpdateVoucherUseCase dari provider.
  final updateVoucherUseCase = ref.read(updateVoucherUseCaseProvider);
  // Mengambil instance DeleteVoucherUseCase dari provider.
  final deleteVoucherUseCase = ref.read(deleteVoucherUseCaseProvider);
  // Mengembalikan instance EditVoucherNotifier dengan use case yang diperlukan.
  return EditVoucherNotifier(updateVoucherUseCase, deleteVoucherUseCase);
});

// Kelas WorkerVoucherParams untuk menyimpan parameter provider workerVoucherListProvider.
// Kelas ini digunakan untuk menyimpan ownerUserId dan laundryId.
class WorkerVoucherParams {
  // Properti untuk menyimpan ID pemilik voucher.
  final String ownerUserId;
  // Properti untuk menyimpan ID laundry.
  final String laundryId;

  // Konstruktor untuk WorkerVoucherParams dengan parameter wajib.
  WorkerVoucherParams({
    required this.ownerUserId,
    required this.laundryId,
  });

  // Override operator == untuk membandingkan instance WorkerVoucherParams.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkerVoucherParams &&
          runtimeType == other.runtimeType &&
          ownerUserId == other.ownerUserId &&
          laundryId == other.laundryId;

  // Override hashCode untuk menghasilkan hash berdasarkan ownerUserId dan laundryId.
  @override
  int get hashCode => ownerUserId.hashCode ^ laundryId.hashCode;
}