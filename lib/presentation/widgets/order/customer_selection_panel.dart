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

class CustomerSelectionPanel extends ConsumerStatefulWidget {
  final Function(String uniqueName, String userId) onCustomerSelected;

  const CustomerSelectionPanel({
    super.key,
    required this.onCustomerSelected,
  });

  @override
  CustomerSelectionPanelState createState() => CustomerSelectionPanelState();
}

class CustomerSelectionPanelState
    extends ConsumerState<CustomerSelectionPanel> {
  @override
  Widget build(BuildContext context) {
    final customersAsync =
        ref.watch(user_provider.customersProvider); // Changed to ref.watch

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(PaddingSizes.cardPadding),
        child: customersAsync.when(
          data: (customers) {
            TextEditingController searchController = TextEditingController();
            List<User> filteredCustomers = List.from(customers);

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter modalSetState) {
                return Column(
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
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        Text(
                          'Select Unique Name',
                          style: AppTypography.modalTitle,
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: MarginSizes.modalTop),
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
                              Navigator.pop(context);
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
                        user_provider.customersProvider); // Trigger re-fetch
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
