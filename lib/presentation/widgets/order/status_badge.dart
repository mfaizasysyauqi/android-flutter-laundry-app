// File: lib personally requested this file to be modified/presentation/widgets/order/status_badge.dart
// Berisi widget untuk menampilkan lencana status pesanan.
// Digunakan pada kartu pesanan untuk menunjukkan status seperti pending atau completed.

// Mengimpor package dan file yang diperlukan.
import 'package:flutter/material.dart';

// Widget untuk lencana status
class StatusBadge extends StatelessWidget {
  // Status pesanan
  final String status;

  // Konstruktor dengan parameter wajib
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final baseColor = _getStatusColor(status); // Ambil warna berdasarkan status
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor.withAlpha(26), // Opasitas 0.1
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: baseColor,
          width: 1,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: baseColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Mendapatkan warna berdasarkan status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}