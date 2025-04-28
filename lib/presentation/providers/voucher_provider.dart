import 'package:dartz/dartz.dart';
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/data/datasources/remote/voucher_remote_data_source.dart';
import 'package:flutter_laundry_app/data/repositories/voucher_repository_impl.dart';
import 'package:flutter_laundry_app/domain/entities/user.dart';
import 'package:flutter_laundry_app/domain/entities/voucher.dart';
import 'package:flutter_laundry_app/domain/repositories/voucher_repository.dart';
import 'package:flutter_laundry_app/domain/usecases/user/get_user_by_id_usecase.dart';
import 'package:flutter_laundry_app/domain/usecases/voucher/create_voucher_usecase.dart';
import 'package:flutter_laundry_app/domain/usecases/voucher/delete_voucher_usecase.dart';
import 'package:flutter_laundry_app/domain/usecases/voucher/get_voucher_by_owner_and_laundry_ids.dart';
import 'package:flutter_laundry_app/domain/usecases/voucher/get_voucher_by_user_id_or_laundry_id_usecase.dart';
import 'package:flutter_laundry_app/domain/usecases/voucher/get_voucher_by_user_id_usecase.dart';
import 'package:flutter_laundry_app/domain/usecases/voucher/get_vouchers_by_laundry_id_usecase.dart';
import 'package:flutter_laundry_app/domain/usecases/voucher/update_voucher_owner_usecase.dart';
import 'package:flutter_laundry_app/domain/usecases/voucher/update_voucher_usecase.dart';
import 'package:flutter_laundry_app/presentation/providers/core_provider.dart';

import 'package:flutter_laundry_app/presentation/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data source
final voucherRemoteDataSourceProvider =
    Provider<VoucherRemoteDataSource>((ref) {
  return VoucherRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

// Repository
final voucherRepositoryProvider = Provider<VoucherRepository>((ref) {
  return VoucherRepositoryImpl(
    remoteDataSource: ref.watch(voucherRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// Use cases
final createVoucherUseCaseProvider = Provider<CreateVoucherUseCase>((ref) {
  return CreateVoucherUseCase(ref.watch(voucherRepositoryProvider));
});

final updateVoucherOwnerUseCaseProvider =
    Provider<UpdateVoucherOwnerUseCase>((ref) {
  return UpdateVoucherOwnerUseCase(ref.watch(voucherRepositoryProvider));
});

final getVouchersByUserIdUseCaseProvider =
    Provider<GetVouchersByUserIdUseCase>((ref) {
  return GetVouchersByUserIdUseCase(ref.watch(voucherRepositoryProvider));
});

final getVouchersByUserIdOrLaundryIdUseCaseProvider =
    Provider<GetVouchersByUserIdOrLaundryIdUseCase>((ref) {
  return GetVouchersByUserIdOrLaundryIdUseCase(
      ref.watch(voucherRepositoryProvider));
});

final getVouchersByLaundryIdUseCaseProvider =
    Provider<GetVouchersByLaundryIdUseCase>((ref) {
  return GetVouchersByLaundryIdUseCase(ref.watch(voucherRepositoryProvider));
});

final updateVoucherUseCaseProvider = Provider<UpdateVoucherUseCase>((ref) {
  return UpdateVoucherUseCase(ref.watch(voucherRepositoryProvider));
});

final deleteVoucherUseCaseProvider = Provider<DeleteVoucherUseCase>((ref) {
  return DeleteVoucherUseCase(ref.watch(voucherRepositoryProvider));
});

final getVouchersByOwnerAndLaundryIdUseCaseProvider =
    Provider<GetVouchersByOwnerAndLaundryIdUseCase>((ref) {
  return GetVouchersByOwnerAndLaundryIdUseCase(
      ref.watch(voucherRepositoryProvider));
});

// Voucher state
class VoucherNotifier extends StateNotifier<AsyncValue<Voucher?>> {
  final CreateVoucherUseCase createVoucherUseCase;

  VoucherNotifier(this.createVoucherUseCase)
      : super(const AsyncValue.data(null));

  Future<void> createVoucher(Voucher voucher) async {
    state = const AsyncValue.loading();
    try {
      final result = await createVoucherUseCase(voucher);
      result.fold(
        (failure) {
          state = AsyncValue.error(
            'Failed to create voucher: ${failure.toString()}',
            StackTrace.current,
          );
        },
        (voucher) {
          state = AsyncValue.data(voucher);
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        'Unexpected error while creating voucher: $e',
        stackTrace,
      );
    }
  }
}

// Voucher list state
class VoucherListState {
  final List<Voucher> vouchers;
  final Map<String, String> laundryNames;
  final bool isLoading;
  final String? error;

  VoucherListState({
    this.vouchers = const [],
    this.laundryNames = const {},
    this.isLoading = false,
    this.error,
  });

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

// Voucher list notifier
class VoucherListNotifier extends StateNotifier<VoucherListState> {
  final GetVouchersByUserIdUseCase getVouchersByUserIdUseCase;
  final GetVouchersByUserIdOrLaundryIdUseCase
      getVouchersByUserIdOrLaundryIdUseCase;
  final GetVouchersByLaundryIdUseCase getVouchersByLaundryIdUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;
  final String? userId;
  String? _laundryId; // Store laundryId for admin refresh

  VoucherListNotifier({
    required this.getVouchersByUserIdUseCase,
    required this.getVouchersByUserIdOrLaundryIdUseCase,
    required this.getVouchersByLaundryIdUseCase,
    required this.getUserByIdUseCase,
    this.userId,
  }) : super(VoucherListState(isLoading: true)) {
    fetchVouchers();
  }

  Future<void> fetchVouchers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final Either<Failure, List<Voucher>> result = userId != null
          ? await getVouchersByUserIdOrLaundryIdUseCase(
              userId: userId!,
              includeOwner: true,
            )
          : await getVouchersByUserIdUseCase();
      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: 'Failed to fetch vouchers: ${failure.toString()}',
          );
        },
        (vouchers) async {
          final laundryIds =
              vouchers.map((voucher) => voucher.laundryId).toSet().toList();

          final Map<String, String> laundryNames = {};
          for (final laundryId in laundryIds) {
            final Either<Failure, User> userResult =
                await getUserByIdUseCase(laundryId);
            userResult.fold(
              (failure) {
                laundryNames[laundryId] = 'Unknown Laundry';
              },
              (user) {
                laundryNames[laundryId] = user.uniqueName;
              },
            );
          }

          state = state.copyWith(
            vouchers: vouchers,
            laundryNames: laundryNames,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unexpected error while fetching vouchers: $e',
      );
    }
  }

  Future<void> fetchVouchersByLaundryId(String laundryId) async {
    _laundryId = laundryId; // Store laundryId for refresh
    state = state.copyWith(isLoading: true, error: null);
    try {
      final Either<Failure, List<Voucher>> result =
          await getVouchersByLaundryIdUseCase(laundryId);
      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: 'Failed to fetch vouchers: ${failure.toString()}',
          );
        },
        (vouchers) async {
          final laundryIds =
              vouchers.map((voucher) => voucher.laundryId).toSet().toList();

          final Map<String, String> laundryNames = {};
          for (final laundryId in laundryIds) {
            final Either<Failure, User> userResult =
                await getUserByIdUseCase(laundryId);
            userResult.fold(
              (failure) {
                laundryNames[laundryId] = 'Unknown Laundry';
              },
              (user) {
                laundryNames[laundryId] = user.uniqueName;
              },
            );
          }

          state = state.copyWith(
            vouchers: vouchers,
            laundryNames: laundryNames,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unexpected error while fetching vouchers: $e',
      );
    }
  }

  Future<void> refresh() async {
    if (userId != null) {
      await fetchVouchers();
    } else if (_laundryId != null) {
      await fetchVouchersByLaundryId(_laundryId!);
    } else {
      await fetchVouchers();
    }
  }
}

// Worker voucher list notifier
class WorkerVoucherListNotifier extends StateNotifier<VoucherListState> {
  final GetVouchersByOwnerAndLaundryIdUseCase
      getVouchersByOwnerAndLaundryIdUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;
  final String ownerUserId;
  final String laundryId;

  WorkerVoucherListNotifier({
    required this.getVouchersByOwnerAndLaundryIdUseCase,
    required this.getUserByIdUseCase,
    required this.ownerUserId,
    required this.laundryId,
  }) : super(VoucherListState(isLoading: true)) {
    fetchVouchers();
  }

  Future<void> fetchVouchers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final Either<Failure, List<Voucher>> result =
          await getVouchersByOwnerAndLaundryIdUseCase(ownerUserId, laundryId);
      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: 'Failed to fetch vouchers: ${failure.toString()}',
          );
        },
        (vouchers) async {
          final laundryIds =
              vouchers.map((voucher) => voucher.laundryId).toSet().toList();

          final Map<String, String> laundryNames = {};
          for (final laundryId in laundryIds) {
            final Either<Failure, User> userResult =
                await getUserByIdUseCase(laundryId);
            userResult.fold(
              (failure) {
                laundryNames[laundryId] = 'Unknown Laundry';
              },
              (user) {
                laundryNames[laundryId] = user.uniqueName;
              },
            );
          }

          state = state.copyWith(
            vouchers: vouchers,
            laundryNames: laundryNames,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unexpected error while fetching vouchers: $e',
      );
    }
  }

  Future<void> refresh() async {
    await fetchVouchers();
  }
}

// Edit voucher notifier
class EditVoucherNotifier extends StateNotifier<AsyncValue<Voucher?>> {
  final UpdateVoucherUseCase updateVoucherUseCase;
  final DeleteVoucherUseCase deleteVoucherUseCase;

  EditVoucherNotifier(this.updateVoucherUseCase, this.deleteVoucherUseCase)
      : super(const AsyncValue.data(null));

  Future<void> updateVoucher(Voucher voucher) async {
    state = const AsyncValue.loading();
    try {
      final result = await updateVoucherUseCase(voucher);
      result.fold(
        (failure) {
          state = AsyncValue.error(
            'Failed to update voucher: ${failure.toString()}',
            StackTrace.current,
          );
        },
        (updatedVoucher) {
          state = AsyncValue.data(updatedVoucher);
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        'Unexpected error while updating voucher: $e',
        stackTrace,
      );
    }
  }

  Future<void> deleteVoucher(String voucherId) async {
    state = const AsyncValue.loading();
    try {
      final result = await deleteVoucherUseCase(voucherId);
      result.fold(
        (failure) {
          state = AsyncValue.error(
            'Failed to delete voucher: ${failure.toString()}',
            StackTrace.current,
          );
        },
        (_) {
          state = const AsyncValue.data(null);
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        'Unexpected error while deleting voucher: $e',
        stackTrace,
      );
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Providers
final voucherProvider =
    StateNotifierProvider<VoucherNotifier, AsyncValue<Voucher?>>((ref) {
  final createVoucherUseCase = ref.read(createVoucherUseCaseProvider);
  return VoucherNotifier(createVoucherUseCase);
});

final voucherListProvider = StateNotifierProvider.family<VoucherListNotifier,
    VoucherListState, String?>((ref, userId) {
  final getVouchersByUserIdUseCase =
      ref.read(getVouchersByUserIdUseCaseProvider);
  final getVouchersByUserIdOrLaundryIdUseCase =
      ref.read(getVouchersByUserIdOrLaundryIdUseCaseProvider);
  final getVouchersByLaundryIdUseCase =
      ref.read(getVouchersByLaundryIdUseCaseProvider);
  final getUserByIdUseCase = ref.read(getUserByIdUseCaseProvider);
  return VoucherListNotifier(
    getVouchersByUserIdUseCase: getVouchersByUserIdUseCase,
    getVouchersByUserIdOrLaundryIdUseCase:
        getVouchersByUserIdOrLaundryIdUseCase,
    getVouchersByLaundryIdUseCase: getVouchersByLaundryIdUseCase,
    getUserByIdUseCase: getUserByIdUseCase,
    userId: userId,
  );
});

final workerVoucherListProvider = StateNotifierProvider.family<
    WorkerVoucherListNotifier,
    VoucherListState,
    WorkerVoucherParams>((ref, params) {
  final getVouchersByOwnerAndLaundryIdUseCase =
      ref.read(getVouchersByOwnerAndLaundryIdUseCaseProvider);
  final getUserByIdUseCase = ref.read(getUserByIdUseCaseProvider);
  return WorkerVoucherListNotifier(
    getVouchersByOwnerAndLaundryIdUseCase:
        getVouchersByOwnerAndLaundryIdUseCase,
    getUserByIdUseCase: getUserByIdUseCase,
    ownerUserId: params.ownerUserId,
    laundryId: params.laundryId,
  );
});

final adminVoucherListProvider =
    StateNotifierProvider.family<VoucherListNotifier, VoucherListState, String>(
        (ref, laundryId) {
  final getVouchersByUserIdUseCase =
      ref.read(getVouchersByUserIdUseCaseProvider);
  final getVouchersByUserIdOrLaundryIdUseCase =
      ref.read(getVouchersByUserIdOrLaundryIdUseCaseProvider);
  final getVouchersByLaundryIdUseCase =
      ref.read(getVouchersByLaundryIdUseCaseProvider);
  final getUserByIdUseCase = ref.read(getUserByIdUseCaseProvider);
  return VoucherListNotifier(
    getVouchersByUserIdUseCase: getVouchersByUserIdUseCase,
    getVouchersByUserIdOrLaundryIdUseCase:
        getVouchersByUserIdOrLaundryIdUseCase,
    getVouchersByLaundryIdUseCase: getVouchersByLaundryIdUseCase,
    getUserByIdUseCase: getUserByIdUseCase,
    userId: null,
  )..fetchVouchersByLaundryId(laundryId);
});

final editVoucherProvider =
    StateNotifierProvider<EditVoucherNotifier, AsyncValue<Voucher?>>((ref) {
  final updateVoucherUseCase = ref.read(updateVoucherUseCaseProvider);
  final deleteVoucherUseCase = ref.read(deleteVoucherUseCaseProvider);
  return EditVoucherNotifier(updateVoucherUseCase, deleteVoucherUseCase);
});

// Parameters for workerVoucherListProvider
class WorkerVoucherParams {
  final String ownerUserId;
  final String laundryId;

  WorkerVoucherParams({
    required this.ownerUserId,
    required this.laundryId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkerVoucherParams &&
          runtimeType == other.runtimeType &&
          ownerUserId == other.ownerUserId &&
          laundryId == other.laundryId;

  @override
  int get hashCode => ownerUserId.hashCode ^ laundryId.hashCode;
}
