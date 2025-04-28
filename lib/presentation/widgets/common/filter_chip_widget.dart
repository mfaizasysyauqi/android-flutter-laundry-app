import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/style/colors/button_colors.dart';
import 'package:flutter_laundry_app/presentation/style/colors/text_colors.dart';

class FilterChipWidget<T> extends StatelessWidget {
  final T filter;
  final T selectedFilter;
  final String label;
  final ValueChanged<T> onSelected;
  final bool showCheckmark;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? checkmarkColor;

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
    final isSelected = filter == selectedFilter;

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
      onSelected: (selected) => onSelected(filter),
      checkmarkColor: checkmarkColor ?? TextColors.lightText,
      backgroundColor: unselectedColor ?? ButtonColors.filterChipUnselected,
      selectedColor: selectedColor ?? ButtonColors.filterChipSelected,
      side: BorderSide.none,
      showCheckmark: showCheckmark, // Explicitly set showCheckmark
    );
  }
}
