import 'package:flutter/material.dart';
import 'home_page.dart';
import 'Myrewards_page.dart';

class GetRewardsPage extends StatelessWidget {
  const GetRewardsPage({super.key});

  // Figma frame (Pixel 5)
  static const double designW = 393;
  static const double designH = 851;

  // Background gradient
  static const Color topColor = Color(0xFFF8F8F8);
  static const Color bottomColor = Color(0xFF1D5D6D);

  // Header positions from Figma
  static const double titleX = 105, titleY = 40;
  static const double subX = 51, subY = 86;

  // Coupon dimensions & spacing from Figma
  static const double couponW = 329, couponH = 129;
  static const double couponX = 32, couponY = 155;
  static const double couponGap = 16;

  // Coupon components (absolute positions from Figma) => relative inside coupon
  static const double cTitleRelX = 66 - couponX; // 34
  static const double cTitleRelY = 169 - couponY - 8;

  static const double cDescRelX = 98 - couponX - 8;
  static const double cDescRelY = 211 - couponY;

  static const double cPointsRelX = 45 - couponX;
  static const double cPointsRelY = 244 - couponY + 8;

  static const double cTimeRelX = 248 - couponX;
  static const double cTimeRelY = 238 - couponY + 8;

  // Popup (Figma)
  static const double popupW = 266;
  static const double popupH = 173;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / designW;

    final coupons = <CouponData>[
      const CouponData(
        title: '15% discount',
        subtitle: '15% discount on one purchase',
        points: '500 point',
        start: '21 Mar 2026',
        end: '10 Apr 2026',
      ),
      const CouponData(
        title: '10 JDs off',
        subtitle: '10 JDs off on one purchase',
        points: '1000 point',
        start: '21 Mar 2026',
        end: '10 Apr 2026',
      ),
      const CouponData(
        title: '20% discount',
        subtitle: '20% discount on one purchase',
        points: '700 point',
        start: '21 Mar 2026',
        end: '10 Apr 2026',
      ),
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.12, 0.83],
            colors: [topColor, bottomColor],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: 8,
                top: 4,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    );
                  },
                ),
              ),
              Positioned(
                left: titleX * s,
                top: titleY * s,
                child: Text(
                  'Get rewards',
                  style: TextStyle(
                    fontFamily: 'Judson',
                    fontSize: 32 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Positioned(
                left: subX * s,
                top: subY * s,
                child: Text(
                  'Enjoy amazing rewards using your points',
                  style: TextStyle(
                    fontFamily: 'Judson',
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4A9EB2),
                  ),
                ),
              ),
              for (int i = 0; i < coupons.length; i++)
                Positioned(
                  left: couponX * s,
                  top: (couponY + i * (couponH + couponGap)) * s,
                  width: couponW * s,
                  height: couponH * s,
                  child: CouponWidget(
                    data: coupons[i],
                    scale: s,
                    onTap: () => _claimFlow(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _claimFlow(BuildContext context) async {
    final s = MediaQuery.of(context).size.width / designW;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (ctx) => _ConfirmClaimDialog(scale: s),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (ctx) => _SuccessDialog(
        scale: s,
        onGo: () {
          Navigator.of(ctx).pop();
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const MyRewardsPage()));
        },
      ),
    );
  }
}

class CouponData {
  final String title;
  final String subtitle;
  final String points;
  final String start;
  final String end;

  const CouponData({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.start,
    required this.end,
  });
}

class CouponWidget extends StatelessWidget {
  const CouponWidget({
    super.key,
    required this.data,
    required this.scale,
    required this.onTap,
  });

  final CouponData data;
  final double scale;
  final VoidCallback onTap;

  static const double titleRelX = GetRewardsPage.cTitleRelX;
  static const double titleRelY = GetRewardsPage.cTitleRelY;

  static const double descRelX = GetRewardsPage.cDescRelX;
  static const double descRelY = GetRewardsPage.cDescRelY;

  static const double pointsRelX = GetRewardsPage.cPointsRelX;
  static const double pointsRelY = GetRewardsPage.cPointsRelY;

  static const double timeRelX = GetRewardsPage.cTimeRelX;
  static const double timeRelY = GetRewardsPage.cTimeRelY;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/coupon.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: titleRelX * scale,
                  top: titleRelY * scale,
                  width: 210 * scale,
                  child: Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Judson',
                      fontSize: 26 * scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1D5D6D),
                      height: 1,
                    ),
                  ),
                ),
                Positioned(
                  left: descRelX * scale,
                  top: descRelY * scale,
                  width: 230 * scale,
                  child: Text(
                    data.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Judson',
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 1.05,
                    ),
                  ),
                ),
                Positioned(
                  left: pointsRelX * scale,
                  top: pointsRelY * scale,
                  width: 170 * scale,
                  child: Text(
                    data.points,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontFamily: 'Judson',
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5CA8B9),
                      height: 1,
                    ),
                  ),
                ),
                Positioned(
                  left: timeRelX * scale,
                  top: timeRelY * scale,
                  width: 105 * scale,
                  height: 42 * scale,
                  child: _TimeBlock(
                    start: data.start,
                    end: data.end,
                    scale: scale,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({
    required this.start,
    required this.end,
    required this.scale,
  });

  final String start;
  final String end;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          textAlign: TextAlign.right,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Starts: ',
                style: TextStyle(
                  fontFamily: 'Judson',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: start,
                style: TextStyle(
                  fontFamily: 'Judson',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4 * scale),
        RichText(
          textAlign: TextAlign.right,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Ends: ',
                style: TextStyle(
                  fontFamily: 'Judson',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: end,
                style: TextStyle(
                  fontFamily: 'Judson',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ---------------- POPUPS (MATCH IMAGE) ----------------

class _PopupShell extends StatelessWidget {
  const _PopupShell({
    required this.scale,
    required this.child,
    required this.onClose,
  });

  final double scale;
  final Widget child;
  final VoidCallback onClose;

  static const Color bg = Colors.white;
  static const Color stroke = Color(0xFF1D5D6D);
  static const Color teal = Color(0xFF1D5D6D);
  static const Color textGrey = Color(0xFF8E8E8E);

  @override
  Widget build(BuildContext context) {
    final w = GetRewardsPage.popupW * scale;
    final h = GetRewardsPage.popupH * scale;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Center(
        child: SizedBox(
          width: w,
          height: h,
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18 * scale),
              border: Border.all(color: stroke, width: 2 * scale),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 10 * scale,
                  top: 8 * scale,
                  child: InkWell(
                    onTap: onClose,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: EdgeInsets.all(4 * scale),
                      child: Icon(
                        Icons.close,
                        size: 24 * scale,
                        color: textGrey,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmClaimDialog extends StatelessWidget {
  const _ConfirmClaimDialog({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    return _PopupShell(
      scale: scale,
      onClose: () => Navigator.of(context).pop(false),
      child: Stack(
        children: [
          Positioned(
            left: 18 * scale,
            right: 18 * scale,
            top: 52 * scale,
            child: Text(
              'Are you sure you want\nto claim this reward?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontFamilyFallback: const ['Roboto'],
                fontSize: 20 * scale,
                fontWeight: FontWeight.w800,
                color: _PopupShell.textGrey,
                height: 1.15,
              ),
            ),
          ),

          Positioned(
            right: 18 * scale,
            bottom: 16 * scale,
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: _PopupShell.teal,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 * scale,
                      vertical: 8 * scale,
                    ),
                  ),
                  child: Text(
                    'NO',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontFamilyFallback: const ['Roboto'],
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                SizedBox(width: 10 * scale),
                SizedBox(
                  height: 34 * scale,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _PopupShell.teal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22 * scale),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 18 * scale,
                        vertical: 6 * scale,
                      ),
                    ),
                    child: Text(
                      'YES',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontFamilyFallback: const ['Roboto'],
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog({required this.scale, required this.onGo});

  final double scale;
  final VoidCallback onGo;

  @override
  Widget build(BuildContext context) {
    return _PopupShell(
      scale: scale,
      onClose: () => Navigator.of(context).pop(),
      child: Stack(
        children: [
          Positioned(
            left: 18 * scale,
            right: 18 * scale,
            top: 50 * scale,
            child: Text(
              'Reward claimed successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontFamilyFallback: const ['Roboto'],
                fontSize: 18 * scale,
                fontWeight: FontWeight.w900,
                color: _PopupShell.textGrey,
                height: 1.1,
              ),
            ),
          ),

          Positioned(
            left: 26 * scale,
            right: 26 * scale,
            bottom: 18 * scale,
            child: SizedBox(
              height: 40 * scale,
              child: ElevatedButton(
                onPressed: onGo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _PopupShell.teal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24 * scale),
                  ),
                ),
                child: Text(
                  'Go to My Rewards',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontFamilyFallback: const ['Roboto'],
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
