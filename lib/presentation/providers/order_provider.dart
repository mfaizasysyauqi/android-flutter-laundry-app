// File: lib/presentation/providers/order_provider.dart
// Berisi definisi provider dan state management untuk pengelolaan pesanan.
// Menyediakan logika pembuatan pesanan, prediksi waktu penyelesaian, dan pengambilan riwayat pesanan.

// Mengimpor package dan file yang diperlukan.
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/core/utils/order_number_generator.dart';
import 'package:flutter_laundry_app/data/datasources/remote/order_remote_data_source.dart';
import 'package:flutter_laundry_app/data/models/order_model.dart';
import 'package:flutter_laundry_app/data/repositories/order_repository_impl.dart';
import 'package:flutter_laundry_app/domain/entities/order.dart' as domain;
import 'package:flutter_laundry_app/domain/repositories/order_repository.dart';
import 'package:flutter_laundry_app/domain/usecases/order/create_order_use_case.dart';
import 'package:flutter_laundry_app/domain/usecases/order/get_history_order_by_user_id_use_case.dart';
import 'package:flutter_laundry_app/domain/usecases/order/get_orders_by_user_id_and_status_use_case.dart';
import 'package:flutter_laundry_app/domain/usecases/order/predict_completion_time_use_case.dart';
import 'package:flutter_laundry_app/presentation/providers/auth_provider.dart';
import 'package:flutter_laundry_app/presentation/providers/core_provider.dart';
import 'package:flutter_laundry_app/presentation/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mendefinisikan provider untuk OrderRemoteDataSource.
// Provider ini menyediakan instance OrderRemoteDataSource untuk operasi data pesanan.
final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  // Mengambil instance FirebaseFirestore dari firestoreProvider.
  final firestore = ref.watch(firestoreProvider);
  // Mengambil instance FirebaseAuth dari firebaseAuthProvider.
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  // Mengembalikan instance OrderRemoteDataSourceImpl dengan dependensi yang diperlukan.
  return OrderRemoteDataSourceImpl(
    firestore: firestore,
    firebaseAuth: firebaseAuth,
  );
});

// Mendefinisikan provider untuk OrderRepository.
// Provider ini menyediakan instance OrderRepository untuk operasi pesanan.
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  // Mengambil instance FirebaseFirestore dari firestoreProvider.
  final firestore = ref.watch(firestoreProvider);
  // Mengambil instance OrderRemoteDataSource dari orderRemoteDataSourceProvider.
  final remoteDataSource = ref.watch(orderRemoteDataSourceProvider);
  // Mengambil instance NetworkInfo dari networkInfoProvider.
  final networkInfo = ref.watch(networkInfoProvider);
  // Mengembalikan instance OrderRepositoryImpl dengan dependensi yang diperlukan.
  return OrderRepositoryImpl(
    firestore: firestore,
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

// Mendefinisikan provider untuk CreateOrderUseCase.
// Provider ini menyediakan instance CreateOrderUseCase untuk membuat pesanan.
final createOrderUseCaseProvider = Provider<CreateOrderUseCase>((ref) {
  // Mengambil instance OrderRepository dari orderRepositoryProvider.
  final repository = ref.read(orderRepositoryProvider);
  // Mengembalikan instance CreateOrderUseCase dengan repository sebagai dependensi.
  return CreateOrderUseCase(repository);
});

// Mendefinisikan provider untuk PredictCompletionTimeUseCase.
// Provider ini menyediakan instance PredictCompletionTimeUseCase untuk memprediksi waktu penyelesaian.
final predictCompletionTimeUseCaseProvider =
    Provider<PredictCompletionTimeUseCase>((ref) {
  // Mengambil instance OrderRepository dari orderRepositoryProvider.
  final repository = ref.read(orderRepositoryProvider);
  // Mengembalikan instance PredictCompletionTimeUseCase dengan repository sebagai dependensi.
  return PredictCompletionTimeUseCase(repository);
});

// Mendefinisikan provider untuk GetOrdersByUserIdOrLaundryIdAndStatusUseCase.
// Provider ini menyediakan instance untuk mengambil pesanan berdasarkan ID pengguna atau laundry dan status.
final getOrdersByUserIdOrLaundryIdAndStatusUseCaseProvider =
    Provider<GetOrdersByUserIdOrLaundryIdAndStatusUseCase>((ref) {
  // Mengambil instance OrderRepository dari orderRepositoryProvider.
  final repository = ref.read(orderRepositoryProvider);
  // Mengembalikan instance GetOrdersByUserIdOrLaundryIdAndStatusUseCase dengan repository.
  return GetOrdersByUserIdOrLaundryIdAndStatusUseCase(repository);
});

// Mendefinisikan provider untuk GetHistoryOrdersByUserIdUseCase.
// Provider ini menyediakan instance untuk mengambil riwayat pesanan berdasarkan ID pengguna.
final getHistoryOrdersByUserIdUseCaseProvider =
    Provider<GetHistoryOrdersByUserIdUseCase>((ref) {
  // Mengambil instance OrderRepository dari orderRepositoryProvider.
  final repository = ref.read(orderRepositoryProvider);
  // Mengembalikan instance GetHistoryOrdersByUserIdUseCase dengan repository.
  return GetHistoryOrdersByUserIdUseCase(repository);
});

// Kelas OrderState untuk menyimpan status pesanan.
// Kelas ini digunakan untuk mengelola state dalam OrderNotifier.
class OrderState {
  // Properti untuk menandakan apakah sedang memuat data.
  final bool isLoading;
  // Properti untuk menandakan apakah sedang memuat prediksi waktu penyelesaian.
  final bool isLoadingPrediction;
  // Properti untuk menyimpan pesan error (nullable).
  final String? errorMessage;
  // Properti untuk menyimpan waktu penyelesaian yang diprediksi (nullable).
  final DateTime? predictedCompletion;

  // Konstruktor untuk OrderState dengan nilai default.
  OrderState({
    this.isLoading = false,
    this.isLoadingPrediction = false,
    this.errorMessage,
    this.predictedCompletion,
  });

  // Method untuk membuat salinan OrderState dengan nilai baru.
  // Digunakan untuk memperbarui state tanpa mengubah objek asli.
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

// Kelas OrderNotifier untuk mengelola logika pesanan.
// Kelas ini memperluas StateNotifier untuk mengelola OrderState.
class OrderNotifier extends StateNotifier<OrderState> {
  // Properti untuk menyimpan instance CreateOrderUseCase.
  final CreateOrderUseCase createOrderUseCase;
  // Properti untuk menyimpan instance PredictCompletionTimeUseCase.
  final PredictCompletionTimeUseCase predictCompletionTimeUseCase;
  // Properti untuk menyimpan instance FirebaseAuth.
  final firebase_auth.FirebaseAuth firebaseAuth;
  // Properti untuk menyimpan referensi Riverpod.
  final Ref ref;

  // Konstruktor yang menginisialisasi OrderNotifier dengan dependensi dan state awal.
  OrderNotifier({
    required this.createOrderUseCase,
    required this.predictCompletionTimeUseCase,
    required this.firebaseAuth,
    required this.ref,
  }) : super(OrderState());

  // Method untuk membuat pesanan baru.
  // Menerima parameter yang diperlukan untuk membuat pesanan.
  Future<void> createOrder(
    String customerUniqueName,
    double weight,
    int clothes,
    String laundrySpeed,
    List<String> vouchers,
    double totalPrice,
  ) async {
    // Perbarui state ke loading dan hapus pesan error.
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Buat ID unik untuk pesanan menggunakan OrderNumberGenerator.
    final id = OrderNumberGenerator.generateUniqueNumber();
    // Ambil pengguna saat ini dari FirebaseAuth.
    final currentUser = firebaseAuth.currentUser;
    // Periksa apakah pengguna sudah login; jika tidak, set error.
    if (currentUser == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No user logged in',
      );
      return;
    }

    try {
      // Ambil data pengguna saat ini dari currentUserProvider.
      final user = await ref.read(currentUserProvider.future);
      // Dapatkan nama unik laundry dari data pengguna.
      final laundryUniqueName = user.uniqueName;

      // Buat instance domain.Order dengan data pesanan.
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

      // Panggil CreateOrderUseCase untuk membuat pesanan.
      final result = await createOrderUseCase(order);
      // Tangani hasil menggunakan fold dari Either.
      result.fold(
        // Jika gagal, perbarui state dengan pesan error.
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        // Jika sukses, perbarui state untuk menghentikan loading.
        (_) {
          state = state.copyWith(
            isLoading: false,
          );
        },
      );
    } catch (e) {
      // Tangani error tak terduga dan perbarui state dengan pesan error.
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Method untuk memprediksi waktu penyelesaian pesanan.
  // Menerima parameter berat, jumlah pakaian, dan kecepatan laundry.
  Future<Either<Failure, DateTime?>> predictCompletionTime({
    required double weight,
    required int clothes,
    required String laundrySpeed,
  }) async {
    // Perbarui state ke loading untuk prediksi.
    state = state.copyWith(isLoadingPrediction: true, errorMessage: null);

    // Buat instance OrderModel untuk prediksi.
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

    // Panggil PredictCompletionTimeUseCase untuk memprediksi waktu penyelesaian.
    final result = await predictCompletionTimeUseCase(orderModel);

    // Tangani hasil menggunakan fold dari Either.
    result.fold(
      // Jika gagal, perbarui state dengan pesan error.
      (failure) {
        state = state.copyWith(
          isLoadingPrediction: false,
          errorMessage: failure.message,
          predictedCompletion: null,
        );
      },
      // Jika sukses, perbarui state dengan waktu prediksi.
      (predictedCompletion) {
        state = state.copyWith(
          isLoadingPrediction: false,
          predictedCompletion: predictedCompletion,
        );
      },
    );

    // Kembalikan hasil prediksi.
    return result;
  }

  // Method untuk mereset state prediksi.
  // Mengatur ulang prediksi tanpa mengubah status loading lainnya.
  void resetPrediction() {
    state = OrderState(
      isLoading: state.isLoading,
      isLoadingPrediction: false,
      errorMessage: state.errorMessage,
      predictedCompletion: null,
    );
  }
}

// Mendefinisikan provider untuk OrderNotifier.
// Provider ini menyediakan instance OrderNotifier untuk mengelola state pesanan.
final orderNotifierProvider =
    StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  // Mengambil instance CreateOrderUseCase dari createOrderUseCaseProvider.
  final createOrderUseCase = ref.read(createOrderUseCaseProvider);
  // Mengambil instance PredictCompletionTimeUseCase dari predictCompletionTimeUseCaseProvider.
  final predictCompletionTimeUseCase =
      ref.read(predictCompletionTimeUseCaseProvider);
  // Mengambil instance FirebaseAuth dari firebaseAuthProvider.
  final firebaseAuth = ref.read(firebaseAuthProvider);
  // Mengembalikan instance OrderNotifier dengan dependensi yang diperlukan.
  return OrderNotifier(
    createOrderUseCase: createOrderUseCase,
    predictCompletionTimeUseCase: predictCompletionTimeUseCase,
    firebaseAuth: firebaseAuth,
    ref: ref,
  );
});

// Mendefinisikan provider untuk riwayat pesanan.
// Provider ini menyediakan stream daftar pesanan riwayat berdasarkan ID pengguna.
final historyOrdersProvider = StreamProvider<List<domain.Order>>((ref) async* {
  // Memantau status autentikasi dari authStateProvider.
  final authState = ref.watch(authStateProvider);
  // Jika tidak ada pengguna yang login, kembalikan daftar kosong.
  if (authState.value == null) {
    yield [];
    return;
  }

  // Dapatkan ID pengguna dari authState.
  final userId = authState.value!.uid;
  // Ambil filter pesanan dari orderFilterProvider.
  final filter = ref.watch(orderFilterProvider);

  // Mengambil instance GetHistoryOrdersByUserIdUseCase dari provider.
  final useCase = ref.read(getHistoryOrdersByUserIdUseCaseProvider);
  // Panggil use case untuk mendapatkan riwayat pesanan.
  final result = await useCase(userId);

  // Mengembalikan stream dari hasil riwayat pesanan.
  yield* Stream.fromFuture(result.fold(
    // Jika gagal, kembalikan daftar kosong.
    (failure) async => [],
    // Jika sukses, filter pesanan berdasarkan status.
    (orders) async {
      List<domain.Order> filteredOrders = orders;
      if (filter == OrderFilter.completed) {
        // Filter hanya pesanan dengan status 'completed'.
        filteredOrders =
            orders.where((order) => order.status == 'completed').toList();
      } else if (filter == OrderFilter.cancelled) {
        // Filter hanya pesanan dengan status 'cancelled'.
        filteredOrders =
            orders.where((order) => order.status == 'cancelled').toList();
      } else {
        // Filter pesanan dengan status 'completed' atau 'cancelled'.
        filteredOrders = orders
            .where((order) =>
                order.status == 'completed' || order.status == 'cancelled')
            .toList();
      }
      return filteredOrders;
    },
  ));
});

// Mendefinisikan provider untuk pesanan pelanggan.
// Provider ini menyediakan stream daftar pesanan pelanggan berdasarkan nama unik.
final customerOrdersProvider = StreamProvider<List<domain.Order>>((ref) async* {
  // Memantau status autentikasi dari authStateProvider.
  final authState = ref.watch(authStateProvider);
  // Jika tidak ada pengguna yang login, kembalikan daftar kosong.
  if (authState.value == null) {
    yield [];
    return;
  }

  // Ambil nama unik pengguna dari currentUserUniqueNameProvider.
  final uniqueName = await ref.watch(currentUserUniqueNameProvider.future);
  // Ambil filter pesanan dari orderFilterProvider.
  final filter = ref.watch(orderFilterProvider);

  // Buat query Firestore untuk koleksi 'orders' dengan filter nama unik pelanggan.
  firestore.Query<Map<String, dynamic>> query = firestore
      .FirebaseFirestore.instance
      .collection('orders')
      .where('customerUniqueName', isEqualTo: uniqueName);

  // Tambahkan filter untuk pesanan yang bukan riwayat.
  query = query.where('isHistory', isEqualTo: false);

  // Tambahkan filter status jika bukan 'all'.
  if (filter != OrderFilter.all) {
    query = query.where('status', isEqualTo: filter.name);
  }

  // Mengembalikan stream dari snapshot Firestore, diubah menjadi daftar OrderModel.
  yield* query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return OrderModel.fromJson(data, doc.id);
      }).toList());
});

// Mendefinisikan provider untuk pesanan laundry.
// Provider ini menyediakan stream daftar pesanan laundry berdasarkan nama unik.
final laundryOrdersProvider = StreamProvider<List<domain.Order>>((ref) async* {
  // Memantau status autentikasi dari authStateProvider.
  final authState = ref.watch(authStateProvider);
  // Jika tidak ada pengguna yang login, kembalikan daftar kosong.
  if (authState.value == null) {
    yield [];
    return;
  }

  // Ambil nama unik pengguna dari currentUserUniqueNameProvider.
  final uniqueName = await ref.watch(currentUserUniqueNameProvider.future);
  // Ambil filter pesanan dari orderFilterProvider.
  final filter = ref.watch(orderFilterProvider);

  // Buat query Firestore untuk koleksi 'orders' dengan filter nama unik laundry.
  firestore.Query<Map<String, dynamic>> query = firestore
      .FirebaseFirestore.instance
      .collection('orders')
      .where('laundryUniqueName', isEqualTo: uniqueName);

  // Tambahkan filter untuk pesanan yang bukan riwayat.
  query = query.where('isHistory', isEqualTo: false);

  // Tambahkan filter status berdasarkan filter yang dipilih.
  if (filter == OrderFilter.all) {
    // Filter status 'pending', 'processing', atau 'completed'.
    query =
        query.where('status', whereIn: ['pending', 'processing', 'completed']);
  } else {
    // Filter berdasarkan status tertentu.
    query = query.where('status', isEqualTo: filter.name);
  }

  // Mengembalikan stream dari snapshot Firestore, diubah menjadi daftar OrderModel.
  yield* query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return OrderModel.fromJson(data, doc.id);
      }).toList());
});

// Mendefinisikan provider untuk OrderActions.
// Provider ini menyediakan instance OrderActions untuk operasi pesanan.
final orderActionsProvider = Provider<OrderActions>((ref) {
  // Mengambil instance OrderRepository dari orderRepositoryProvider.
  final repository = ref.watch(orderRepositoryProvider);
  // Mengembalikan instance OrderActions dengan repository dan referensi Riverpod.
  return OrderActions(repository: repository, ref: ref);
});

// Mendefinisikan enum untuk filter pesanan.
// Enum ini digunakan untuk memfilter pesanan berdasarkan status.
enum OrderFilter { all, pending, processing, completed, cancelled }

// Mendefinisikan provider untuk filter pesanan.
// Provider ini menyimpan status filter saat ini (default: all).
final orderFilterProvider = StateProvider<OrderFilter>((ref) {
  return OrderFilter.all;
});

// Kelas OrderActions untuk menangani operasi pesanan.
// Kelas ini menyediakan method untuk memperbarui, menghapus, dan menandai pesanan sebagai riwayat.
class OrderActions {
  // Properti untuk menyimpan instance OrderRepository.
  final OrderRepository repository;
  // Properti untuk menyimpan referensi Riverpod.
  final Ref ref;

  // Konstruktor yang menginisialisasi OrderActions dengan dependensi.
  OrderActions({required this.repository, required this.ref});

  // Method untuk memperbarui status pesanan.
  // Menerima ID pesanan dan status baru.
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    // Panggil repository untuk memperbarui status dan waktu penyelesaian/pembatalan.
    final result =
        await repository.updateOrderStatusAndCompletion(orderId, newStatus);
    // Tangani hasil menggunakan fold dari Either.
    await result.fold(
      // Jika gagal, lempar exception dengan pesan error.
      (failure) async => throw Exception(failure.message),
      // Jika sukses, perbarui provider yang sesuai berdasarkan peran pengguna.
      (_) async {
        final userRoleAsync = ref.read(userRoleProvider);
        if (userRoleAsync.hasValue) {
          final userRole = userRoleAsync.value;
          if (userRole == 'Worker') {
            // Refresh laundryOrdersProvider untuk pekerja.
            var _ = ref.refresh(laundryOrdersProvider);
          } else {
            // Refresh customerOrdersProvider untuk pelanggan.
            var _ = ref.refresh(customerOrdersProvider);
          }
        }
      },
    );
  }

  // Method untuk menandai pesanan sebagai riwayat.
  // Menerima ID pesanan.
  Future<void> setOrderAsHistory(String orderId) async {
    // Panggil repository untuk menandai pesanan sebagai riwayat.
    final result = await repository.setOrderAsHistory(orderId);
    // Tangani hasil menggunakan fold dari Either.
    await result.fold(
      // Jika gagal, lempar exception dengan pesan error.
      (failure) async => throw Exception(failure.message),
      // Jika sukses, perbarui provider yang sesuai berdasarkan peran pengguna.
      (_) async {
        final userRoleAsync = ref.read(userRoleProvider);
        if (userRoleAsync.hasValue) {
          final userRole = userRoleAsync.value;
          if (userRole == 'Worker') {
            // Refresh laundryOrdersProvider untuk pekerja.
            var _ = ref.refresh(laundryOrdersProvider);
          } else {
            // Refresh customerOrdersProvider untuk pelanggan.
            var _ = ref.refresh(customerOrdersProvider);
          }
          // Refresh historyOrdersProvider untuk memperbarui riwayat.
          var _ = ref.refresh(historyOrdersProvider);
        }
      },
    );
  }

  // Method untuk menghapus pesanan.
  // Menerima ID pesanan.
  Future<void> deleteOrder(String orderId) async {
    // Panggil repository untuk menghapus pesanan.
    final result = await repository.deleteOrder(orderId);
    // Tangani hasil menggunakan fold dari Either.
    await result.fold(
      // Jika gagal, lempar exception dengan pesan error.
      (failure) async => throw Exception(failure.message),
      // Jika sukses, perbarui provider yang sesuai berdasarkan peran pengguna.
      (_) async {
        final userRoleAsync = ref.read(userRoleProvider);
        if (userRoleAsync.hasValue) {
          final userRole = userRoleAsync.value;
          if (userRole == 'Worker') {
            // Refresh laundryOrdersProvider untuk pekerja.
            var _ = ref.refresh(laundryOrdersProvider);
          } else {
            // Refresh customerOrdersProvider untuk pelanggan.
            var _ = ref.refresh(customerOrdersProvider);
          }
        }
      },
    );
  }
}