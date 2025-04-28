import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/data/datasources/remote/user_remote_data_source.dart';
import 'package:flutter_laundry_app/data/repositories/user_repository_impl.dart';
import 'package:flutter_laundry_app/domain/entities/user.dart';
import 'package:flutter_laundry_app/domain/usecases/user/get_customer_usecase.dart';
import 'package:flutter_laundry_app/domain/usecases/user/get_user_by_id_usecase.dart';
import 'package:flutter_laundry_app/domain/usecases/user/get_user_by_unique_name_usecase.dart';
import 'package:flutter_laundry_app/domain/usecases/user/get_user_usecase.dart';
import 'package:flutter_laundry_app/domain/usecases/user/update_laundry_price_usecase.dart';
import 'package:flutter_laundry_app/presentation/providers/core_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data source
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

// Repository
final userRepositoryProvider = Provider<UserRepositoryImpl>((ref) {
  return UserRepositoryImpl(
    authRemoteDataSource: ref.watch(firebaseAuthRemoteDataSourceProvider),
    userRemoteDataSource: ref.watch(userRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// Use cases
final getUserUseCaseProvider = Provider<GetUserUseCase>((ref) {
  return GetUserUseCase(ref.watch(userRepositoryProvider));
});

final getCustomersUseCaseProvider = Provider<GetCustomersUseCase>((ref) {
  return GetCustomersUseCase(ref.watch(userRepositoryProvider));
});

final getUserByIdUseCaseProvider = Provider<GetUserByIdUseCase>((ref) {
  return GetUserByIdUseCase(ref.watch(userRepositoryProvider));
});

final getUserByUniqueNameUseCaseProvider =
    Provider<GetUserByUniqueNameUseCase>((ref) {
  return GetUserByUniqueNameUseCase(ref.watch(userRepositoryProvider));
});

final updateLaundryPriceUseCaseProvider =
    Provider<UpdateLaundryPriceUseCase>((ref) {
  return UpdateLaundryPriceUseCase(ref.watch(userRepositoryProvider));
});

// User state
class UserState {
  final User? user;
  final bool isLoading;
  final Failure? failure;

  UserState({
    this.user,
    this.isLoading = false,
    this.failure,
  });

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

// User notifier
class UserNotifier extends StateNotifier<UserState> {
  final GetUserUseCase _getUserUseCase;
  final UpdateLaundryPriceUseCase _updateLaundryPriceUseCase;

  UserNotifier({
    required GetUserUseCase getUserUseCase,
    required UpdateLaundryPriceUseCase updateLaundryPriceUseCase,
  })  : _getUserUseCase = getUserUseCase,
        _updateLaundryPriceUseCase = updateLaundryPriceUseCase,
        super(UserState());

  Future<void> getUser() async {
    state = state.copyWith(isLoading: true, failure: null);
    final result = await _getUserUseCase();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }

  Future<void> updateLaundryPrice(int regulerPrice, int expressPrice) async {
    state = state.copyWith(isLoading: true, failure: null);
    final result = await _updateLaundryPriceUseCase(regulerPrice, expressPrice);
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, failure: failure);
        throw Exception('Failed to update prices: ${failure.message}');
      },
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }
}

// Providers
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final getUserUseCase = ref.watch(getUserUseCaseProvider);
  final updateLaundryPriceUseCase =
      ref.watch(updateLaundryPriceUseCaseProvider);
  return UserNotifier(
    getUserUseCase: getUserUseCase,
    updateLaundryPriceUseCase: updateLaundryPriceUseCase,
  );
});

final customersProvider = FutureProvider<List<User>>((ref) async {
  final getCustomersUseCase = ref.watch(getCustomersUseCaseProvider);
  final result = await getCustomersUseCase();
  return result.fold(
    (failure) => throw Exception('Failed to fetch customers: $failure'),
    (customers) => customers,
  );
});

final laundryUniqueNameProvider =
    FutureProvider.family<String, String>((ref, laundryId) async {
  final getUserByIdUseCase = ref.watch(getUserByIdUseCaseProvider);
  final result = await getUserByIdUseCase(laundryId);
  return result.fold(
    (failure) => throw Exception('Failed to fetch laundry name: $failure'),
    (user) => user.uniqueName,
  );
});

final currentUserProvider = FutureProvider<User>((ref) async {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);

  final currentUser = firebaseAuth.currentUser;
  if (currentUser == null) {
    throw Exception('No user logged in');
  }

  final userDoc =
      await firestore.collection('users').doc(currentUser.uid).get();

  if (!userDoc.exists) {
    throw Exception('User data not found');
  }

  final data = userDoc.data()!;

  DateTime createdAt;
  if (data['createdAt'] is fs.Timestamp) {
    createdAt = (data['createdAt'] as fs.Timestamp).toDate();
  } else if (data['createdAt'] is String) {
    createdAt = DateTime.parse(data['createdAt'] as String);
  } else {
    createdAt = DateTime.now();
  }

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

final userRoleProvider = FutureProvider<String>((ref) async {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) throw Exception('No user logged in');

  final userDoc = await ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .get();
  if (!userDoc.exists) throw Exception('User data not found');
  return userDoc['role'] as String;
});

final currentUserUniqueNameProvider = FutureProvider<String>((ref) async {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) throw Exception('No user logged in');

  final userDoc = await ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .get();
  if (!userDoc.exists) throw Exception('User data not found');
  return userDoc['uniqueName'] as String;
});
