// File: voucher_obtain_method_checker.dart
// Berisi kelas VoucherObtainMethodChecker untuk memeriksa kelayakan pesanan terhadap voucher.

// Mengimpor model dan package yang diperlukan.
import 'package:flutter_laundry_app/data/models/order_model.dart';
import 'package:flutter_laundry_app/data/models/voucher_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Kelas VoucherObtainMethodChecker untuk memeriksa kelayakan voucher.
class VoucherObtainMethodChecker {
  // Method statis untuk memeriksa apakah pesanan memenuhi syarat untuk voucher.
  static Future<bool> isOrderEligibleForVoucher({
    required OrderModel order,
    required VoucherModel voucher,
    required String userId,
  }) async {
    // Inisialisasi instance Firestore untuk mengakses database.
    final firestore = FirebaseFirestore.instance;

    // Periksa metode perolehan voucher dan tentukan kelayakan.
    switch (voucher.obtainMethod) {
      case 'Laundry 5 Kg':
        // Voucher berlaku jika berat pesanan >= 5 kg.
        return order.weight >= 5.0;

      case 'Laundry 10 Kg':
        // Voucher berlaku jika berat pesanan >= 10 kg.
        return order.weight >= 10.0;

      case 'First Laundry':
        // Voucher berlaku jika pengguna belum pernah membuat pesanan sebelumnya.
        final ordersSnapshot = await firestore
            .collection('orders')
            .where('customerUniqueName', isEqualTo: order.customerUniqueName)
            .get();
        return ordersSnapshot.docs.isEmpty;

      case 'Laundry on Birthdate':
        // Voucher berlaku jika pesanan dibuat pada hari ulang tahun pengguna.
        final userDoc = await firestore.collection('users').doc(userId).get();
        if (!userDoc.exists) return false;
        final userData = userDoc.data()!;
        final birthdate = (userData['birthdate'] as Timestamp?)?.toDate();
        if (birthdate == null) return false;
        final now = DateTime.now();
        return birthdate.month == now.month && birthdate.day == now.day;

      case 'Weekday Laundry':
        // Voucher berlaku untuk pesanan pada hari kerja (Senin-Jumat).
        final now = DateTime.now();
        return now.weekday >= DateTime.monday && now.weekday <= DateTime.friday;

      case 'New Service':
        // Voucher berlaku untuk pesanan dengan layanan Express.
        return order.laundrySpeed == 'Express';

      case 'Twin Date':
        // Voucher berlaku pada tanggal kembar, misalnya 11/11.
        final now = DateTime.now();
        final dayStr = now.day.toString().padLeft(2, '0');
        final monthStr = now.month.toString().padLeft(2, '0');
        return dayStr == monthStr;

      case 'Special Date':
        // Voucher berlaku pada tanggal khusus, misalnya Tahun Baru (1 Januari).
        final now = DateTime.now();
        return now.month == 1 && now.day == 1;

      default:
        // Kembalikan false jika metode perolehan tidak dikenali.
        return false;
    }
  }
}