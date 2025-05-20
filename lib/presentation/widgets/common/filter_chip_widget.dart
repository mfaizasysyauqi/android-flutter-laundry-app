// File: lib/presentation/widgets/common/filter_chip_widget.dart
// Berisi widget untuk chip filter yang dapat dipilih.
// Digunakan untuk memfilter data seperti voucher atau pesanan.

// Mengimpor package dan file yang diperlukan.
import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/style/colors/button_colors.dart';
import 'package:flutter_laundry_app/presentation/style/colors/text_colors.dart';

// Widget untuk chip filter
class FilterChipWidget<T> extends StatelessWidget {
  // Nilai filter
  final T filter;
  // Filter yang sedang dipilih
  final T selectedFilter;
  // Label chip
  final String label;
  // Fungsi saat chip dipilih
  final ValueChanged<T> onSelected;
  // Menampilkan tanda centang
  final bool showCheckmark;
  // Warna saat dipilih
  final Color? selectedColor;
  // Warna saat tidak dipilih
  final Color? unselectedColor;
  // Warna tanda centang
  final Color? checkmarkColor;

  // Konstruktor dengan parameter wajib dan opsional
  const FilterChipWidget({
    super.key,
    required this.filter,
    required this.selectedFilter,
    required this.label,
    required this.onSelected,
    this.showCheckmark = true,
    this.selectedColor,
    this.unselectedColor,
    this.checkmarkColor,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = filter == selectedFilter; // Status chip dipilih

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) => onSelected(filter), // Panggil fungsi saat dipilih
      checkmarkColor: checkmarkColor ?? TextColors.lightText,
      backgroundColor: unselectedColor ?? ButtonColors.filterChipUnselected,
      selectedColor: selectedColor ?? ButtonColors.filterChipSelected,
      side: BorderSide.none, // Tanpa garis tepi
      showCheckmark: showCheckmark,
    );
  }
}