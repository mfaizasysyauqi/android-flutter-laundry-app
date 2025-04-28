import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/providers/voucher_provider.dart';
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/colors/button_colors.dart';

import 'package:flutter_laundry_app/presentation/style/sizes/icon_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/margin_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/padding_sizes.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/custom_text_form_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/voucher.dart';

class EditVoucherScreen extends ConsumerStatefulWidget {
  final Voucher voucher;

  const EditVoucherScreen({super.key, required this.voucher});

  @override
  ConsumerState<EditVoucherScreen> createState() => _EditVoucherScreenState();
}

class _EditVoucherScreenState extends ConsumerState<EditVoucherScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _typeController;
  late TextEditingController _obtainMethodController;
  late TextEditingController _validityPeriodController;
  DateTime? _validityPeriod;
  bool _isUpdating = false;
  bool _isDeleting = false;

  final List<String> _voucherTypes = [
    'Free Laundry',
    'Discount',
  ];
  final List<String> _obtainMethods = [
    'Laundry 5 Kg',
    'Laundry 10 Kg',
    'First Laundry',
    'Laundry on Birthdate',
    'Weekday Laundry',
    'New Service',
    'Twin Date',
    'Special Date',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.voucher.name);
    _amountController =
        TextEditingController(text: widget.voucher.amount.toString());
    _typeController = TextEditingController(text: widget.voucher.type);
    _obtainMethodController =
        TextEditingController(text: widget.voucher.obtainMethod);
    _validityPeriod = widget.voucher.validityPeriod;
    _validityPeriodController = TextEditingController(
      text: _validityPeriod != null
          ? DateFormat('dd/MM/yyyy').format(_validityPeriod!)
          : 'No Expiry',
    );
    _isUpdating = false;
    _isDeleting = false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _typeController.dispose();
    _obtainMethodController.dispose();
    _validityPeriodController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _validityPeriod ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B7280),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: const DialogTheme(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _validityPeriod) {
      setState(() {
        _validityPeriod = picked;
        _validityPeriodController.text =
            DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _clearValidityPeriod() {
    setState(() {
      _validityPeriod = null;
      _validityPeriodController.text = 'No Expiry';
    });
  }

  void _updateVoucher() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUpdating = true;
      });

      final amount = double.tryParse(_amountController.text);

      if (amount == null) {
        setState(() {
          _isUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid voucher amount')),
        );
        return;
      }

      final updatedVoucher = Voucher(
        id: widget.voucher.id,
        name: _nameController.text,
        amount: amount,
        type: _typeController.text,
        obtainMethod: _obtainMethodController.text,
        validityPeriod: _validityPeriod,
        laundryId: widget.voucher.laundryId,
        ownerVoucherIds: widget.voucher.ownerVoucherIds,
      );

      ref.read(editVoucherProvider.notifier).updateVoucher(updatedVoucher);
    }
  }

  void _deleteVoucher() {
    setState(() {
      _isDeleting = true;
    });
    ref.read(editVoucherProvider.notifier).deleteVoucher(widget.voucher.id);
  }

  void _showOptionsModal({
    required BuildContext context,
    required List<String> options,
    required TextEditingController controller,
    required String title,
  }) {
    TextEditingController searchController = TextEditingController();
    List<String> filteredOptions = List.from(options);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(PaddingSizes.cardPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            size: IconSizes.navigationIcon,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Select $title',
                              style: AppTypography.modalTitle,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: IconSizes.navigationIcon),
                      ],
                    ),
                    const SizedBox(height: MarginSizes.modalTop),
                    CustomTextFormField(
                      controller: searchController,
                      hintText: "Search $title...",
                      prefixIcon: Icons.search,
                      onChanged: (value) {
                        modalSetState(() {
                          filteredOptions = options
                              .where((option) => option
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: MarginSizes.moderate),
                    Flexible(
                      child: filteredOptions.isEmpty
                          ? const Center(child: Text('No options found'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredOptions.length,
                              itemBuilder: (context, index) {
                                final option = filteredOptions[index];
                                return ListTile(
                                  title: Text(
                                    option,
                                    style: AppTypography.formInstruction
                                        .copyWith(color: Colors.black),
                                  ),
                                  onTap: () {
                                    if (mounted) {
                                      setState(() {
                                        controller.text = option;
                                      });
                                    }
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      searchController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<Voucher?>>(editVoucherProvider, (previous, next) {
      ScaffoldMessenger.of(context).clearSnackBars();
      next.when(
        data: (voucher) {
          if (voucher != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Voucher updated successfully!')),
            );
            ref
                .read(
                    adminVoucherListProvider(widget.voucher.laundryId).notifier)
                .refresh();
            context.go('/admin-voucher-list-screen');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Voucher deleted successfully!')),
            );
            ref
                .read(
                    adminVoucherListProvider(widget.voucher.laundryId).notifier)
                .refresh();
            context.go('/admin-voucher-list-screen');
          }
        },
        loading: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(_isDeleting
                    ? 'Deleting voucher...'
                    : 'Updating voucher...')),
          );
        },
        error: (error, stack) {
          setState(() {
            _isUpdating = false;
            _isDeleting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $error')),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: IconSizes.navigationIcon,
          ),
          onPressed: () {
            context.go('/admin-voucher-list-screen');
          },
        ),
        title: Text(
          'Edit Voucher',
          style: AppTypography.appBarTitle.copyWith(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PaddingSizes.sectionTitlePadding,
          vertical: PaddingSizes.contentContainerPadding,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Edit Voucher',
                style: AppTypography.sectionTitle.copyWith(color: Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                'Modify existing vouchers to update discounts, validity, or terms as needed.',
                style: AppTypography.formInstruction,
              ),
              const SizedBox(height: PaddingSizes.screenEdgePadding),
              CustomTextFormField(
                hintText: 'Voucher Name',
                labelText: 'Voucher Name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter voucher name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: PaddingSizes.sectionTitlePadding),
              CustomTextFormField(
                hintText: 'Voucher Amount',
                labelText: 'Voucher Amount',
                controller: _amountController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter voucher amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: PaddingSizes.sectionTitlePadding),
              CustomTextFormField(
                hintText: 'Voucher Type',
                labelText: 'Voucher Type',
                controller: _typeController,
                readOnly: true,
                onTap: () => _showOptionsModal(
                  context: context,
                  options: _voucherTypes,
                  controller: _typeController,
                  title: 'Voucher Type',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select voucher type';
                  }
                  return null;
                },
                suffixIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(height: PaddingSizes.sectionTitlePadding),
              CustomTextFormField(
                hintText: 'How to get a voucher',
                labelText: 'How to get a voucher',
                controller: _obtainMethodController,
                readOnly: true,
                onTap: () => _showOptionsModal(
                  context: context,
                  options: _obtainMethods,
                  controller: _obtainMethodController,
                  title: 'How to get a voucher',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select how to obtain the voucher';
                  }
                  return null;
                },
                suffixIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(height: PaddingSizes.sectionTitlePadding),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      hintText: 'Voucher Validity Period',
                      labelText: 'Voucher Validity Period dd/mm/yyy...',
                      controller: _validityPeriodController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      suffixIcon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                  if (_validityPeriod != null) ...[
                    const SizedBox(width: PaddingSizes.sectionTitlePadding),
                    IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: _clearValidityPeriod,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: PaddingSizes.screenEdgePadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed:
                        _isUpdating || _isDeleting ? null : _deleteVoucher,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isUpdating || _isDeleting
                          ? Colors.grey
                          : ButtonColors.delete,
                      foregroundColor: ButtonColors.buttonTextColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('Delete'),
                  ),
                  const SizedBox(width: PaddingSizes.sectionTitlePadding),
                  ElevatedButton(
                    onPressed:
                        _isUpdating || _isDeleting ? null : _updateVoucher,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isUpdating || _isDeleting
                          ? Colors.grey
                          : ButtonColors.sendToHistory,
                      foregroundColor: ButtonColors.buttonTextColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('Update'),
                  ),
                ],
              ),
              const SizedBox(height: PaddingSizes.sectionTitlePadding),
            ],
          ),
        ),
      ),
    );
  }
}
