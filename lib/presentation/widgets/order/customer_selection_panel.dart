// File: lib/presentation/widgets/panel/customer_selection_panel.dart
// Berisi panel untuk memilih pelanggan berdasarkan nama unik.
// Digunakan pada proses pembuatan pesanan oleh admin.

// Mengimpor package dan file yang diperlukan.
import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/domain/entities/user.dart';
import 'package:flutter_laundry_app/presentation/providers/user_provider.dart'
    as user_provider;
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/icon_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/margin_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/padding_sizes.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/custom_text_form_field.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/loading_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Widget panel untuk memilih pelanggan
class CustomerSelectionPanel extends ConsumerStatefulWidget {
  // Fungsi saat pelanggan dipilih
  final Function(String uniqueName, String userId) onCustomerSelected;

  // Konstruktor dengan parameter wajib
  const CustomerSelectionPanel({
    super.key,
    required this.onCustomerSelected,
  });

  @override
  CustomerSelectionPanelState createState() => CustomerSelectionPanelState();
}

// State untuk mengelola logika panel
class CustomerSelectionPanelState
    extends ConsumerState<CustomerSelectionPanel> {
  @override
  Widget build(BuildContext context) {
    // Ambil data pelanggan dari provider
    final customersAsync =
        ref.watch(user_provider.customersProvider);

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7, // Tinggi panel
        padding: const EdgeInsets.all(PaddingSizes.cardPadding),
        child: customersAsync.when(
          data: (customers) {
            // Kontroler untuk pencarian
            TextEditingController searchController = TextEditingController();
            // Daftar pelanggan yang difilter
            List<User> filteredCustomers = List.from(customers);

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter modalSetState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tombol kembali
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            size: IconSizes.navigationIcon,
                          ),
                          onPressed: () {
                            Navigator.pop(context); // Tutup panel
                          },
                        ),
                        Text(
                          'Select Unique Name',
                          style: AppTypography.modalTitle,
                        ),
                        const SizedBox(width: 48), // Spacer
                      ],
                    ),
                    const SizedBox(height: MarginSizes.modalTop),
                    // Kolom pencarian
                    CustomTextFormField(
                      controller: searchController,
                      hintText: "Search Unique Name...",
                      prefixIcon: Icons.search,
                      onChanged: (value) {
                        modalSetState(() {
                          filteredCustomers = customers
                              .where((customer) => customer.uniqueName
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: MarginSizes.moderate),
                    // Daftar pelanggan
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(filteredCustomers[index].uniqueName),
                            onTap: () {
                              widget.onCustomerSelected(
                                filteredCustomers[index].uniqueName,
                                filteredCustomers[index].id,
                              );
                              Navigator.pop(context); // Tutup panel
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Error: $error'),
                const SizedBox(height: MarginSizes.moderate),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(
                        user_provider.customersProvider); // Muat ulang data
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          loading: () => const Center(child: LoadingIndicator()),
        ),
      ),
    );
  }
}