import 'package:flutter/material.dart';
import 'home_page.dart';
import '../models/my_reward_model.dart';
import '../Services/my_rewards_service.dart';

class MyRewardsPage extends StatefulWidget {
  const MyRewardsPage({super.key, required this.userId});

  final String userId;

  static const double designW = 393;
  static const double designH = 851;

  static const Color topColor = Color(0xFFF8F8F8);
  static const Color bottomColor = Color(0xFF1D5D6D);

  static const double titleX = 105, titleY = 40;
  static const double subX = 70, subY = 86;

  static const double couponW = 329, couponH = 129;
  static const double couponX = 32, couponY = 155;
  static const double couponGap = 16;

  static const double cTitleRelX = 66 - couponX;
  static const double cTitleRelY = 169 - couponY - 8;

  static const double cDescRelX = 98 - couponX - 8;
  static const double cDescRelY = 211 - couponY;

  static const double cIdRelX = 45 - couponX;
  static const double cIdRelY = 244 - couponY + 8;

  static const double cTimeRelX = 248 - couponX;
  static const double cTimeRelY = 238 - couponY + 8;

  @override
  State<MyRewardsPage> createState() => _MyRewardsPageState();
}

class _MyRewardsPageState extends State<MyRewardsPage> {
  late Future<List<MyRewardModel>> _futureRewards;

  @override
  void initState() {
    super.initState();

    /// 👈 نستخدم userId اللي جاي من الصفحة
    _futureRewards = MyRewardsService.fetchMyRewards(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / MyRewardsPage.designW;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.12, 0.83],
            colors: [MyRewardsPage.topColor, MyRewardsPage.bottomColor],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Back
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
                left: MyRewardsPage.titleX * s,
                top: MyRewardsPage.titleY * s,
                child: Text(
                  'My Rewards',
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
                left: MyRewardsPage.subX * s,
                top: MyRewardsPage.subY * s,
                child: Text(
                  'Use your reward at checkout\nShow it to the cashier to apply the discount',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Judson',
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4A9EB2),
                    height: 1.15,
                  ),
                ),
              ),

              /// ⭐️ CONTENT
              FutureBuilder<List<MyRewardModel>>(
                future: _futureRewards,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load rewards'));
                  }

                  final rewards = snapshot.data!;
                  if (rewards.isEmpty) {
                    return const Center(child: Text('No rewards found'));
                  }

                  return Stack(
                    children: [
                      for (int i = 0; i < rewards.length; i++)
                        Positioned(
                          left: MyRewardsPage.couponX * s,
                          top:
                              (MyRewardsPage.couponY +
                                  i *
                                      (MyRewardsPage.couponH +
                                          MyRewardsPage.couponGap)) *
                              s,
                          width: MyRewardsPage.couponW * s,
                          height: MyRewardsPage.couponH * s,
                          child: MyRewardCouponWidget(
                            scale: s,
                            reward: rewards[i],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyRewardCouponWidget extends StatelessWidget {
  const MyRewardCouponWidget({
    super.key,
    required this.reward,
    required this.scale,
  });

  final MyRewardModel reward;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
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
                left: MyRewardsPage.cTitleRelX * scale,
                top: MyRewardsPage.cTitleRelY * scale,
                width: 210 * scale,
                child: Text(
                  reward.couponType,
                  style: TextStyle(
                    fontFamily: 'Judson',
                    fontSize: 26 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D5D6D),
                  ),
                ),
              ),
              Positioned(
                left: MyRewardsPage.cDescRelX * scale,
                top: MyRewardsPage.cDescRelY * scale,
                width: 230 * scale,
                child: Text(
                  reward.couponDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Judson',
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                left: MyRewardsPage.cIdRelX * scale,
                top: MyRewardsPage.cIdRelY * scale,
                child: Text(
                  'ID: ${reward.serialNumber}',
                  style: TextStyle(
                    fontFamily: 'Judson',
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5CA8B9),
                  ),
                ),
              ),
              Positioned(
                left: MyRewardsPage.cTimeRelX * scale,
                top: MyRewardsPage.cTimeRelY * scale,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Starts: ${reward.validFrom.substring(0, 10)}'),
                    Text('Ends: ${reward.validUntil.substring(0, 10)}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
