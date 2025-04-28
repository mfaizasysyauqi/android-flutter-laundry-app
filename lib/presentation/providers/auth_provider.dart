import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/data/repositories/auth_repository_impl.dart';
import 'package:flutter_laundry_app/domain/entities/user.dart';
import 'package:flutter_laundry_app/domain/repositories/auth_repository.dart';
import 'package:flutter_laundry_app/domain/usecases/auth/login_usecase.dart';
import 'package:flutter_laundry_app/domain/usecases/auth/register_usecase.dart';
import 'package:flutter_laundry_app/presentation/providers/core_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

// Auth repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(firebaseAuthRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

// Use cases
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(authRepository);
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LoginUseCase(authRepository);
});

// Auth state
enum AuthStatus { initial, loading, success, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final Failure? failure;
  final String operationType;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.failure,
    this.operationType = '',
  });

  bool get isLoading => status == AuthStatus.loading;

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

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final RegisterUseCase _registerUseCase;
  final LoginUseCase _loginUseCase;
  bool _isProcessing = false;

  AuthNotifier(this._registerUseCase, this._loginUseCase) : super(AuthState());

  void resetState() {
    state = AuthState();
    _isProcessing = false;
  }

  Future<void> register({
    required String role,
    required String fullName,
    required String uniqueName,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
  }) async {
    if (_isProcessing) return;
    _isProcessing = true;

    state =
        state.copyWith(status: AuthStatus.loading, operationType: 'register');

    final result = await _registerUseCase(
      role: role,
      fullName: fullName,
      uniqueName: uniqueName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      address: address,
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        failure: failure,
        user: null,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.success,
        failure: null,
        user: user,
      ),
    );

    _isProcessing = false;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (_isProcessing) return;
    _isProcessing = true;

    state = state.copyWith(status: AuthStatus.loading, operationType: 'login');

    final result = await _loginUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        failure: failure,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.success,
        user: user,
      ),
    );

    _isProcessing = false;
  }
}

// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final registerUseCase = ref.watch(registerUseCaseProvider);
  final loginUseCase = ref.watch(loginUseCaseProvider);
  return AuthNotifier(registerUseCase, loginUseCase);
});

final authStateProvider = StreamProvider<firebase_auth.User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});
