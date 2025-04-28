import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/domain/entities/user.dart';
import 'package:flutter_laundry_app/domain/entities/voucher.dart';
import 'package:flutter_laundry_app/presentation/providers/user_provider.dart';
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/icon_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/padding_sizes.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/loading_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AdminVoucherDetailsScreen extends ConsumerWidget {
  static const routeName = '/admin-voucher-details-screen';
  final Voucher voucher;

  const AdminVoucherDetailsScreen({super.key, required this.voucher});

  String _getDisplayObtainMethod(String obtainMethod) {
    const methodDescriptions = {
      'Laundry 5 Kg': 'Available for 5 Kg laundry',
      'Laundry 10 Kg': 'Available for 10 Kg laundry',
      'First Laundry': 'Available for first time users',
      'Laundry on Birthdate': 'Available on your birthday',
      'Weekday Laundry': 'Available for weekday laundry',
      'New Service': 'Available for new services',
      'Twin Date': 'Available on twin dates',
      'Special Date': 'Available on special dates',
    };
    return methodDescriptions[obtainMethod] ?? obtainMethod;
  }

  String _getDescription(Voucher voucher) {
    if (voucher.type == 'Discount') {
      return 'Enjoy ${voucher.amount}% discount for new customer';
    } else if (voucher.type == 'Free Laundry') {
      return 'Enjoy ${voucher.amount} Kg free laundry';
    }
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getUserByIdUseCase = ref.watch(getUserByIdUseCaseProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: BackgroundColors.transparent,
        shadowColor: BackgroundColors.transparent,
        surfaceTintColor: BackgroundColors.transparent,
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
          'Voucher Details',
          style: AppTypography.darkAppBarTitle,
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<dartz.Either<Failure, User>>(
        future: getUserByIdUseCase(voucher.laundryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Error fetching laundry name'));
          }

          return snapshot.data!.fold(
            (failure) => const Center(
                child: Text('Error fetching laundry name: Server Failure')),
            (user) {
              final laundryName = user.uniqueName;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: PaddingSizes.sectionTitlePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              right: PaddingSizes.sectionTitlePadding,
                              left: PaddingSizes.sectionTitlePadding,
                              top: PaddingSizes.topOnly,
                            ),
                            child: Text(
                              'Voucher Details',
                              style: AppTypography.sectionTitle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                          height: PaddingSizes.contentContainerPadding),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipPath(
                            clipper: NotchedRectangleClipper(
                                notchRadius: 16.0, cornerRadius: 12.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0x0ff5f5f5),
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withAlpha(25),
                                    blurRadius: 8.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0, horizontal: 20.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              voucher.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0,
                                                color: Color(0xFF95BBE3),
                                              ),
                                            ),
                                            Text(
                                              laundryName,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 12.0),
                                            Text(
                                              _getDisplayObtainMethod(
                                                  voucher.obtainMethod),
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12.0,
                                              ),
                                            ),
                                            const SizedBox(height: 4.0),
                                            Text(
                                              _getDescription(voucher),
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12.0,
                                              ),
                                            ),
                                            const SizedBox(height: 4.0),
                                            Text(
                                              'Valid until ${voucher.validityPeriod != null ? DateFormat('dd/MM/yyyy').format(voucher.validityPeriod!) : 'N/A'}',
                                              style: const TextStyle(
                                                color: Color(0xFF95BBE3),
                                                fontSize: 12.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    CustomPaint(
                                      size: const Size(1, double.infinity),
                                      painter: DashedLinePainter(),
                                    ),
                                    Container(
                                      width: 100.0,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0, horizontal: 16.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            voucher.type,
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF95BBE3),
                                            ),
                                          ),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            voucher.type == 'Discount'
                                                ? '${voucher.amount}% Off'
                                                : '${voucher.amount} Kg',
                                            style: const TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF95BBE3),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 500.0,
                            left: 0,
                            right: 0,
                            child: ClipPath(
                              clipper: NotchedRectangleClipper(
                                  notchRadius: 16.0, cornerRadius: 12.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0x0ff5f5f5),
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withAlpha(25),
                                      blurRadius: 8.0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0, horizontal: 20.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                laundryName,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 12.0),
                                              Text(
                                                _getDisplayObtainMethod(
                                                    voucher.obtainMethod),
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                _getDescription(voucher),
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                'Valid until ${voucher.validityPeriod != null ? DateFormat('dd/MM/yyyy').format(voucher.validityPeriod!) : 'N/A'}',
                                                style: const TextStyle(
                                                  color: Color(0xFF95BBE3),
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      CustomPaint(
                                        size: const Size(1, double.infinity),
                                        painter: DashedLinePainter(),
                                      ),
                                      Container(
                                        width: 100.0,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0, horizontal: 16.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              voucher.type,
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF95BBE3),
                                              ),
                                            ),
                                            const SizedBox(height: 4.0),
                                            Text(
                                              voucher.type == 'Discount'
                                                  ? '${voucher.amount}% Off'
                                                  : '${voucher.amount} Kg',
                                              style: const TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF95BBE3),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 100.0,
                            left: 0,
                            right: 0,
                            child: SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withAlpha(50),
                                      blurRadius: 12.0,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'ID: ${voucher.id}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            voucher.validityPeriod != null
                                                ? DateFormat('dd/MM/yyyy')
                                                    .format(
                                                        voucher.validityPeriod!)
                                                : 'N/A',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Colors.grey),
                                      Text(
                                        laundryName,
                                        style: AppTypography.sectionTitle
                                            .copyWith(fontSize: 24),
                                      ),
                                      const SizedBox(height: 16.0),
                                      _buildDetailRow(
                                          'VOUCHER NAME', voucher.name),
                                      const SizedBox(height: 8.0),
                                      _buildDetailRow('VOUCHER AMOUNT',
                                          '${voucher.amount}% discount'),
                                      const SizedBox(height: 8.0),
                                      _buildDetailRow(
                                          'VOUCHER TYPE', voucher.type),
                                      const SizedBox(height: 8.0),
                                      _buildDetailRow(
                                          'HOW TO GET A VOUCHER',
                                          _getDisplayObtainMethod(
                                              voucher.obtainMethod)),
                                      const SizedBox(height: 8.0),
                                      _buildDetailRow('VOUCHER BENEFITS',
                                          _getDescription(voucher)),
                                      const SizedBox(height: 8.0),
                                      _buildDetailRow(
                                        'VOUCHER VALIDITY PERIOD',
                                        voucher.validityPeriod != null
                                            ? DateFormat('dd/MM/yyyy')
                                                .format(voucher.validityPeriod!)
                                            : 'N/A',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class NotchedRectangleClipper extends CustomClipper<Path> {
  final double notchRadius;
  final double cornerRadius;

  NotchedRectangleClipper(
      {required this.notchRadius, required this.cornerRadius});

  @override
  Path getClip(Size size) {
    final path = Path();
    final double height = size.height;
    final double width = size.width;
    final double nRadius = notchRadius;
    final double cRadius = cornerRadius;

    path.moveTo(cRadius, 0);
    path.lineTo(width - cRadius, 0);
    path.arcToPoint(
      Offset(width, cRadius),
      radius: Radius.circular(cRadius),
      clockwise: true,
    );
    path.lineTo(width, height * 0.5 - nRadius);
    path.arcToPoint(
      Offset(width - nRadius, height * 0.5),
      radius: Radius.circular(nRadius),
      clockwise: false,
    );
    path.arcToPoint(
      Offset(width, height * 0.5 + nRadius),
      radius: Radius.circular(nRadius),
      clockwise: false,
    );
    path.lineTo(width, height - cRadius);
    path.arcToPoint(
      Offset(width - cRadius, height),
      radius: Radius.circular(cRadius),
      clockwise: true,
    );
    path.lineTo(cRadius, height);
    path.arcToPoint(
      Offset(0, height - cRadius),
      radius: Radius.circular(cRadius),
      clockwise: true,
    );
    path.lineTo(0, height * 0.5 + nRadius);
    path.arcToPoint(
      Offset(nRadius, height * 0.5),
      radius: Radius.circular(nRadius),
      clockwise: false,
    );
    path.arcToPoint(
      Offset(0, height * 0.5 - nRadius),
      radius: Radius.circular(nRadius),
      clockwise: false,
    );
    path.lineTo(0, cRadius);
    path.arcToPoint(
      Offset(cRadius, 0),
      radius: Radius.circular(cRadius),
      clockwise: true,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;

    const dashHeight = 4.0;
    const dashSpace = 2.0;
    double startY = 0.0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
