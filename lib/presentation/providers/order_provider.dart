import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:dartz/dartz.dart' as dartz;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/core/utils/order_number_generator.dart';
import 'package:flutter_laundry_app/data/datasources/remote/order_remote_data_source.dart';
import 'package:flutter_laundry_app/data/models/order_model.dart';
import 'package:flutter_laundry_app/data/repositories/order_repository_impl.dart';
import 'package:flutter_laundry_app/domain/entities/order.dart' as domain;
import 'package:flutter_laundry_app/domain/repositories/order_repository.dart';
import 'package:flutter_laundry_app/domain/usecases/order/create_order_usecase.dart';
import 'package:flutter_laundry_app/domain/usecases/order/get_history_order_by_user_id_usecase.dart';
import 'package:flutter_laundry_app/domain/usecases/order/get_orders_by_user_id_and_status_usecase.dart';
import 'package:flutter_laundry_app/domain/usecases/order/predict_completion_time_usecase.dart';
import 'package:flutter_laundry_app/presentation/providers/auth_provider.dart';
import 'package:flutter_laundry_app/presentation/providers/core_provider.dart';
import 'package:flutter_laundry_app/presentation/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data source
final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return OrderRemoteDataSourceImpl(
    firestore: firestore,
    firebaseAuth: firebaseAuth,
  );
});

// Repository
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final remoteDataSource = ref.watch(orderRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return OrderRepositoryImpl(
    firestore: firestore,
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

// Use cases
final createOrderUseCaseProvider = Provider<CreateOrderUseCase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return CreateOrderUseCase(repository);
});

final predictCompletionTimeUseCaseProvider =
    Provider<PredictCompletionTimeUseCase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return PredictCompletionTimeUseCase(repository);
});

final getOrdersByUserIdOrLaundryIdAndStatusUseCaseProvider =
    Provider<GetOrdersByUserIdOrLaundryIdAndStatusUseCase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return GetOrdersByUserIdOrLaundryIdAndStatusUseCase(repository);
});

final getHistoryOrdersByUserIdUseCaseProvider =
    Provider<GetHistoryOrdersByUserIdUseCase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return GetHistoryOrdersByUserIdUseCase(repository);
});

// Order state
class OrderState {
  final bool isLoading;
  final bool isLoadingPrediction;
  final String? errorMessage;
  final DateTime? predictedCompletion;

  OrderState({
    this.isLoading = false,
    this.isLoadingPrediction = false,
    this.errorMessage,
    this.predictedCompletion,
  });

  OrderState copyWith({
    bool? isLoading,
    bool? isLoadingPrediction,
    String? errorMessage,
    DateTime? predictedCompletion,
  }) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingPrediction: isLoadingPrediction ?? this.isLoadingPrediction,
      errorMessage: errorMessage ?? this.errorMessage,
      predictedCompletion: predictedCompletion ?? this.predictedCompletion,
    );
  }
}

// Order notifier
class OrderNotifier extends StateNotifier<OrderState> {
  final CreateOrderUseCase createOrderUseCase;
  final PredictCompletionTimeUseCase predictCompletionTimeUseCase;
  final firebase_auth.FirebaseAuth firebaseAuth;
  final Ref ref;

  OrderNotifier({
    required this.createOrderUseCase,
    required this.predictCompletionTimeUseCase,
    required this.firebaseAuth,
    required this.ref,
  }) : super(OrderState());

  Future<void> createOrder(
    String customerUniqueName,
    double weight,
    int clothes,
    String laundrySpeed,
    List<String> vouchers,
    double totalPrice,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final id = OrderNumberGenerator.generateUniqueNumber();
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No user logged in',
      );
      return;
    }

    try {
      final user = await ref.read(currentUserProvider.future);
      final laundryUniqueName = user.uniqueName;

      final order = domain.Order(
        id: id,
        laundryUniqueName: laundryUniqueName,
        customerUniqueName: customerUniqueName,
        weight: weight,
        clothes: clothes,
        laundrySpeed: laundrySpeed,
        vouchers: vouchers,
        status: 'pending',
        totalPrice: totalPrice,
        createdAt: DateTime.now(),
        estimatedCompletion: state.predictedCompletion ?? DateTime.now(),
        isHistory: false,
      );

      final result = await createOrderUseCase(order);
      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (_) {
          state = state.copyWith(
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<dartz.Either<Failure, DateTime?>> predictCompletionTime({
    required double weight,
    required int clothes,
    required String laundrySpeed,
  }) async {
    state = state.copyWith(isLoadingPrediction: true, errorMessage: null);

    final orderModel = OrderModel(
      id: '',
      laundryUniqueName: '',
      customerUniqueName: '',
      weight: weight,
      clothes: clothes,
      laundrySpeed: laundrySpeed,
      vouchers: [],
      totalPrice: 0.0,
      status: 'pending',
      createdAt: DateTime.now(),
      estimatedCompletion: DateTime.now(),
      isHistory: false,
    );

    final result = await predictCompletionTimeUseCase(orderModel);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingPrediction: false,
          errorMessage: failure.message,
          predictedCompletion: null,
        );
      },
      (predictedCompletion) {
        state = state.copyWith(
          isLoadingPrediction: false,
          predictedCompletion: predictedCompletion,
        );
      },
    );

    return result;
  }

  void resetPrediction() {
    state = OrderState(
      isLoading: state.isLoading,
      isLoadingPrediction: false,
      errorMessage: state.errorMessage,
      predictedCompletion: null,
    );
  }
}

// Providers
final orderNotifierProvider =
    StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final createOrderUseCase = ref.read(createOrderUseCaseProvider);
  final predictCompletionTimeUseCase =
      ref.read(predictCompletionTimeUseCaseProvider);
  final firebaseAuth = ref.read(firebaseAuthProvider);
  return OrderNotifier(
    createOrderUseCase: createOrderUseCase,
    predictCompletionTimeUseCase: predictCompletionTimeUseCase,
    firebaseAuth: firebaseAuth,
    ref: ref,
  );
});

final historyOrdersProvider = StreamProvider<List<domain.Order>>((ref) async* {
  final authState = ref.watch(authStateProvider);
  if (authState.value == null) {
    yield [];
    return;
  }

  final userId = authState.value!.uid;
  final filter = ref.watch(orderFilterProvider);

  final useCase = ref.read(getHistoryOrdersByUserIdUseCaseProvider);
  final result = await useCase(userId);

  yield* Stream.fromFuture(result.fold(
    (failure) async => [],
    (orders) async {
      List<domain.Order> filteredOrders = orders;
      if (filter == OrderFilter.completed) {
        filteredOrders =
            orders.where((order) => order.status == 'completed').toList();
      } else if (filter == OrderFilter.cancelled) {
        filteredOrders =
            orders.where((order) => order.status == 'cancelled').toList();
      } else {
        filteredOrders = orders
            .where((order) =>
                order.status == 'completed' || order.status == 'cancelled')
            .toList();
      }
      return filteredOrders;
    },
  ));
});

final customerOrdersProvider = StreamProvider<List<domain.Order>>((ref) async* {
  final authState = ref.watch(authStateProvider);
  if (authState.value == null) {
    yield [];
    return;
  }

  final uniqueName = await ref.watch(currentUserUniqueNameProvider.future);
  final filter = ref.watch(orderFilterProvider);

  firestore.Query<Map<String, dynamic>> query = firestore
      .FirebaseFirestore.instance
      .collection('orders')
      .where('customerUniqueName', isEqualTo: uniqueName);

  query = query.where('isHistory', isEqualTo: false);

  if (filter != OrderFilter.all) {
    query = query.where('status', isEqualTo: filter.name);
  }

  yield* query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return OrderModel.fromJson(data, doc.id);
      }).toList());
});

final laundryOrdersProvider = StreamProvider<List<domain.Order>>((ref) async* {
  final authState = ref.watch(authStateProvider);
  if (authState.value == null) {
    yield [];
    return;
  }

  final uniqueName = await ref.watch(currentUserUniqueNameProvider.future);
  final filter = ref.watch(orderFilterProvider);

  firestore.Query<Map<String, dynamic>> query = firestore
      .FirebaseFirestore.instance
      .collection('orders')
      .where('laundryUniqueName', isEqualTo: uniqueName);

  query = query.where('isHistory', isEqualTo: false);

  if (filter == OrderFilter.all) {
    query =
        query.where('status', whereIn: ['pending', 'processing', 'completed']);
  } else {
    query = query.where('status', isEqualTo: filter.name);
  }

  yield* query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return OrderModel.fromJson(data, doc.id);
      }).toList());
});

final orderActionsProvider = Provider<OrderActions>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrderActions(repository: repository, ref: ref);
});

enum OrderFilter { all, pending, processing, completed, cancelled }

final orderFilterProvider = StateProvider<OrderFilter>((ref) {
  return OrderFilter.all;
});

class OrderActions {
  final OrderRepository repository;
  final Ref ref;

  OrderActions({required this.repository, required this.ref});

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final result =
        await repository.updateOrderStatusAndCompletion(orderId, newStatus);
    await result.fold(
      (failure) async => throw Exception(failure.message),
      (_) async {
        final userRoleAsync = ref.read(userRoleProvider);
        if (userRoleAsync.hasValue) {
          final userRole = userRoleAsync.value;
          if (userRole == 'Worker') {
            var _ = ref.refresh(laundryOrdersProvider);
          } else {
            var _ = ref.refresh(customerOrdersProvider);
          }
        }
      },
    );
  }

  Future<void> setOrderAsHistory(String orderId) async {
    final result = await repository.setOrderAsHistory(orderId);
    await result.fold(
      (failure) async => throw Exception(failure.message),
      (_) async {
        final userRoleAsync = ref.read(userRoleProvider);
        if (userRoleAsync.hasValue) {
          final userRole = userRoleAsync.value;
          if (userRole == 'Worker') {
            var _ = ref.refresh(laundryOrdersProvider);
          } else {
            var _ = ref.refresh(customerOrdersProvider);
          }
          var _ = ref.refresh(historyOrdersProvider);
        }
      },
    );
  }

  Future<void> deleteOrder(String orderId) async {
    final result = await repository.deleteOrder(orderId);
    await result.fold(
      (failure) async => throw Exception(failure.message),
      (_) async {
        final userRoleAsync = ref.read(userRoleProvider);
        if (userRoleAsync.hasValue) {
          final userRole = userRoleAsync.value;
          if (userRole == 'Worker') {
            var _ = ref.refresh(laundryOrdersProvider);
          } else {
            var _ = ref.refresh(customerOrdersProvider);
          }
        }
      },
    );
  }
}
