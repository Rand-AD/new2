import 'package:flutter/material.dart';

import '../Services/api_service.dart';
import '../core/coupon_status.dart';
import '../widgets/reward_coupon_card.dart';
import '../widgets/rewards_header.dart';
import 'coupon_page.dart';
import 'home_page.dart';
import 'my_coupons_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const Color pageBg = Color(0xFFF7F7F7);

  List<Map<String, dynamic>> historyCoupons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getHistoryCoupons();
  }

  Future<void> getHistoryCoupons() async {
    try {
      final data = await ApiService.getUserCoupons();
      final coupons = CouponStatus.uniqueInstances(
        data,
      ).where(CouponStatus.belongsInHistory).toList();

      if (!mounted) {
        return;
      }

      setState(() {
        historyCoupons = coupons;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('COUPON HISTORY ERROR = $e');
      if (!mounted) {
        return;
      }

      setState(() => isLoading = false);
    }
  }

  void _openTab(int index) {
    if (index == 2) {
      return;
    }

    final Widget page = index == 0 ? const CouponPage() : const MyCouponsPage();

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  void _openBottomTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomePage(initialIndex: index)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      bottomNavigationBar: _HistoryBottomNavBar(onTap: _openBottomTab),
      body: Column(
        children: [
          const RewardsHeader(),
          _RewardTabs(selectedIndex: 2, onTap: _openTab),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : historyCoupons.isEmpty
                ? const Center(child: Text('No history yet'))
                : RefreshIndicator(
                    onRefresh: getHistoryCoupons,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                      itemCount: historyCoupons.length,
                      itemBuilder: (context, index) {
                        final item = historyCoupons[index];
                        final status = CouponStatus.statusLabel(
                          item,
                        ).toUpperCase();

                        return RewardCouponCard(
                          coupon: item,
                          isFaded: status == 'EXPIRED',
                          statusLabel: status,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RewardTabs extends StatelessWidget {
  const _RewardTabs({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const tabs = ['All rewards', 'My rewards', 'History'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(tabs.length, (index) {
          final selected = selectedIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFE2E2E2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _HistoryBottomNavBar extends StatelessWidget {
  const _HistoryBottomNavBar({required this.onTap});

  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.grey,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map_outlined),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble_outline),
          label: 'Chatbot',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          activeIcon: Icon(Icons.notifications_none),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
