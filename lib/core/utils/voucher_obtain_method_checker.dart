import 'package:flutter_laundry_app/data/models/order_model.dart';
import 'package:flutter_laundry_app/data/models/voucher_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherObtainMethodChecker {
  static Future<bool> isOrderEligibleForVoucher({
    required OrderModel order,
    required VoucherModel voucher,
    required String userId,
  }) async {
    final firestore = FirebaseFirestore.instance;

    switch (voucher.obtainMethod) {
      case 'Laundry 5 Kg':
        return order.weight >= 5.0;

      case 'Laundry 10 Kg':
        return order.weight >= 10.0;

      case 'First Laundry':
        // Check if user has no previous orders
        final ordersSnapshot = await firestore
            .collection('orders')
            .where('customerUniqueName', isEqualTo: order.customerUniqueName)
            .get();
        return ordersSnapshot.docs.isEmpty;

      case 'Laundry on Birthdate':
        // Assume user document has a 'birthdate' field
        final userDoc = await firestore.collection('users').doc(userId).get();
        if (!userDoc.exists) return false;
        final userData = userDoc.data()!;
        final birthdate = (userData['birthdate'] as Timestamp?)?.toDate();
        if (birthdate == null) return false;
        final now = DateTime.now();
        return birthdate.month == now.month && birthdate.day == now.day;

      case 'Weekday Laundry':
        final now = DateTime.now();
        return now.weekday >= DateTime.monday && now.weekday <= DateTime.friday;

      case 'New Service':
        // Example: Check if order uses a new service (e.g., Express)
        return order.laundrySpeed == 'Express';

      case 'Twin Date':
        final now = DateTime.now();
        final dayStr = now.day.toString().padLeft(2, '0');
        final monthStr = now.month.toString().padLeft(2, '0');
        return dayStr == monthStr; // e.g., 11/11, 22/22

      case 'Special Date':
        // Example: Check for a specific date, e.g., New Year
        final now = DateTime.now();
        return now.month == 1 && now.day == 1;

      default:
        return false;
    }
  }
}