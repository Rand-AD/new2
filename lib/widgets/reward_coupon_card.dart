import 'package:flutter/material.dart';

import '../core/coupon_status.dart';

class RewardCouponCard extends StatelessWidget {
  const RewardCouponCard({
    super.key,
    required this.coupon,
    required this.isFaded,
    required this.statusLabel,
    this.onUsePressed,
    this.showStatus = true,
  });

  final Map<String, dynamic> coupon;
  final bool isFaded;
  final String statusLabel;
  final VoidCallback? onUsePressed;
  final bool showStatus;

  String get title => CouponStatus.stringValue(coupon, [
    'couponType',
    'type',
    'title',
  ], 'Coupon');

  String get description => CouponStatus.stringValue(coupon, [
    'couponDescription',
    'description',
    'discription',
  ]);

  String get startDate => CouponStatus.dateValue(coupon, [
    'startDate',
    'startsAt',
    'startAt',
    'validFrom',
    'validFromDate',
    'fromDate',
    'beginDate',
    'beginsAt',
    'availableFrom',
    'couponStartDate',
    'createdAt',
    'createdOn',
    'date',
  ]);

  String get endDate => CouponStatus.dateValue(coupon, [
    'endDate',
    'endsAt',
    'endAt',
    'validTo',
    'validUntil',
    'validThrough',
    'expirationDate',
    'expiresAt',
    'expiredAt',
    'expiredDate',
    'expiryDate',
    'expiryAt',
    'toDate',
    'couponEndDate',
  ]);

  @override
  Widget build(BuildContext context) {
    final displayStart = startDate.isEmpty ? '-' : startDate;
    final displayEnd = endDate.isEmpty ? '-' : endDate;
    final cardColor = isFaded ? Colors.grey.shade200 : Colors.white;
    final topColor = isFaded ? Colors.grey.shade400 : const Color(0xFF2B6E7F);
    final isUsed = statusLabel.toUpperCase() == 'USED';

    return Opacity(
      opacity: isFaded ? 0.55 : 1,
      child: Container(
        height: 210,
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              left: 6,
              top: 6,
              right: 6,
              height: 112,
              child: Container(
                decoration: BoxDecoration(
                  color: topColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 24,
                      right: 110,
                      top: 20,
                      bottom: 18,
                      child: Center(
                        child: Text(
                          description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            height: 1.18,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -10,
                      bottom: -8,
                      child: Image.asset(
                        'assets/images/gift1.png',
                        width: 104,
                        height: 104,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 62,
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo3.png',
                    width: 46,
                    height: 46,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 28,
              right: isUsed ? 28 : 122,
              bottom: 35,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    height: 1,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 28,
              right: 122,
              bottom: 14,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      'Starts: $displayStart',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Ends: $displayEnd',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showStatus)
              Positioned(
                right: 18,
                bottom: isUsed ? 8 : 52,
                child: isUsed
                    ? Container(
                        width: 74,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFE93030),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'USED',
                          style: TextStyle(
                            color: Color(0xFFE93030),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      )
                    : statusLabel == 'Active' && !isFaded
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.green, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isFaded
                              ? Colors.grey.shade300
                              : const Color(0xFFE6F2F5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: isFaded
                                ? Colors.grey.shade700
                                : const Color(0xFF2B6E7F),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
            if (!isFaded && onUsePressed != null)
              Positioned(
                right: 18,
                bottom: 8,
                child: GestureDetector(
                  onTap: onUsePressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B6E7F),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Use It',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
