import 'package:flutter/material.dart';
import '../Services/get_rewards_services.dart';
import '../models/coupon_data.dart';
import 'home_page.dart';
import 'Myrewards_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/session_store.dart';

class GetRewardsPage extends StatefulWidget {
  const GetRewardsPage({super.key});
  @override
  State<GetRewardsPage> createState() => _GetRewardsPageState();
}

class _GetRewardsPageState extends State<GetRewardsPage> {
  // Figma frame (Pixel 5)
  static const double designW = 393;
  // Background gradient
  static const Color topColor = Color(0xFFF8F8F8);
  static const Color bottomColor = Color(0xFF1D5D6D);
  // Title & subtitle positions
  static const double titleX = 105, titleY = 40;
  static const double subX = 51, subY = 86;
  // Coupon positions & dimensions
  static const double couponW = 329, couponH = 129;
  static const double couponX = 32, couponY = 155;
  static const double couponGap = 16;
  // Coupon inner positions
  static const double cTitleRelX = 66 - couponX;
  static const double cTitleRelY = 169 - couponY - 8;
  static const double cDescRelX = 98 - couponX - 8;
  static const double cDescRelY = 211 - couponY;
  static const double cPointsRelX = 45 - couponX;
  static const double cPointsRelY = 244 - couponY + 8;
  static const double cTimeRelX = 248 - couponX;
  static const double cTimeRelY = 238 - couponY + 8;

  // State
  bool loading = true;
  bool error = false;
  List<CouponData> coupons = [];

  final String _baseUrl =
      'https://yallarewards-hfhxdxerb8caa8g9.switzerlandnorth-01.azurewebsites.net/api';

  @override
  void initState() {
    super.initState();
    fetchCoupons();
  }

  Future<void> fetchCoupons() async {
    setState(() {
      loading = true;
      error = false;
    });

    try {
      coupons = await GetRewardsServices.fetchActiveCoupons();
    } catch (e) {
      error = true;
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / designW;
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
              // Back button
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
              // Title
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
              // Subtitle
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
              // Main content
              if (loading)
                const Center(child: CircularProgressIndicator())
              else if (error)
                Center(
                  child: Text(
                    'Failed to load rewards.\nCheck your internet connection.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16 * s,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (coupons.isEmpty)
                Center(
                  child: Text(
                    'No active rewards available',
                    style: TextStyle(
                      fontSize: 16 * s,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                for (int i = 0; i < coupons.length; i++)
                  Positioned(
                    left: couponX * s,
                    top: (couponY + i * (couponH + couponGap)) * s,
                    width: couponW * s,
                    height: couponH * s,
                    child: CouponWidget(
                      data: coupons[i],
                      scale: s,
                      onTap: () => _claimFlow(context, coupons[i]),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _claimFlow(BuildContext context, CouponData coupon) async {
    final s = MediaQuery.of(context).size.width / designW;
    final userId = SessionStore.current!.userId;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (ctx) => _ConfirmClaimDialog(scale: s),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    final int userPoints = SessionStore.current!.totalPoints;
    final int couponPoints = int.parse(coupon.points);

    if (userPoints < couponPoints) {
      await showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black26,
        builder: (_) => _ErrorDialog(
          scale: s,
          message: 'You don’t have enough points to claim this reward',
        ),
      );

      return;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/Coupons/redeem'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'couponId': coupon.id, // تأكدي أن CouponData فيه id
      }),
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to redeem coupon')));
      return;
    }
    setState(() {
      coupons.removeWhere((c) => c.id == coupon.id);
    });

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,

      builder: (ctx) => _SuccessDialog(
        scale: s,
        onGo: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MyRewardsPage(userId: userId)),
          );
        },
      ),
    );
  }
}

// -------------------- Coupon Widget --------------------
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
                  left: _GetRewardsPageState.cTitleRelX * scale,
                  top: _GetRewardsPageState.cTitleRelY * scale,
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
                  left: _GetRewardsPageState.cDescRelX * scale,
                  top: _GetRewardsPageState.cDescRelY * scale,
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
                  left: _GetRewardsPageState.cPointsRelX * scale,
                  top: _GetRewardsPageState.cPointsRelY * scale,
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
                  left: _GetRewardsPageState.cTimeRelX * scale,
                  top: _GetRewardsPageState.cTimeRelY * scale,
                  width: 105 * scale,
                  height: 42 * scale,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Starts: ${data.start}',
                        style: TextStyle(
                          fontFamily: 'Judson',
                          fontSize: 12 * scale,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        'Ends: ${data.end}',
                        style: TextStyle(
                          fontFamily: 'Judson',
                          fontSize: 12 * scale,
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
    );
  }
}

// -------------------- Popups --------------------
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
  //static const Color teal = Color(0xFF1D5D6D);
  static const Color textGrey = Color(0xFF8E8E8E);
  @override
  Widget build(BuildContext context) {
    final w = 266 * scale;
    final h = 173 * scale;
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Are you sure you want\nto claim this reward?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20 * scale,
              fontWeight: FontWeight.w800,
              color: _PopupShell.textGrey,
            ),
          ),
          SizedBox(height: 20 * scale),

          // YES / NO buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // NO
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20 * scale,
                    vertical: 8 * scale,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No', style: TextStyle(fontSize: 14 * scale)),
              ),

              SizedBox(width: 16 * scale),

              // YES
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D5D6D),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20 * scale,
                    vertical: 8 * scale,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes', style: TextStyle(fontSize: 14 * scale)),
              ),
            ],
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Reward Claimed Successfully!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1D5D6D),
            ),
          ),
          SizedBox(height: 20 * scale),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D5D6D),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 24 * scale,
                vertical: 10 * scale,
              ),
            ),
            onPressed: onGo,
            child: Text(
              'Go to My Rewards',
              style: TextStyle(fontSize: 16 * scale, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorDialog extends StatelessWidget {
  const _ErrorDialog({required this.scale, required this.message});

  final double scale;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _PopupShell(
      scale: scale,
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Not enough points',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1D5D6D),
            ),
          ),
          SizedBox(height: 12 * scale),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: _PopupShell.textGrey,
            ),
          ),
          SizedBox(height: 20 * scale),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D5D6D),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 28 * scale,
                vertical: 10 * scale,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(fontSize: 14 * scale)),
          ),
        ],
      ),
    );
  }
}
