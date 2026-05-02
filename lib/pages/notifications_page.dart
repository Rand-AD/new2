import 'package:flutter/material.dart';


class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const Color headerColor = Color(0xFF5CA7BC);
  static const Color cardColor = Color(0xFF7EC0CF);

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title':
            'You have some offers from Subway\nthat might have you’re intrest',
        'date': '22/3/2026',
        'asset': 'assets/images/subway_logo.png',
        'icon': Icons.fastfood,
      },
      {
        'title': 'Congrats, You have got 100 pts\nfrom Max.',
        'date': '18/3/2026',
        'asset': 'assets/images/max_logo.jpeg',
        'icon': Icons.shopping_bag,
      },
      {
        'title': 'Welcome to Yalla Rewards',
        'date': '15/3/2026',
        'asset': 'assets/images/logo3.png',
        'icon': Icons.shopping_bag_outlined,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 78,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: headerColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(34),
                  bottomRight: Radius.circular(34),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: ClipOval(
                            child: (item['asset'] as String).isNotEmpty
                                ? Image.asset(
                                    item['asset'] as String,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      item['icon'] as IconData,
                                      color: const Color(0xFF6AAFC1),
                                      size: 24,
                                    ),
                                  )
                                : Icon(
                                    item['icon'] as IconData,
                                    color: const Color(0xFF6AAFC1),
                                    size: 24,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  right: 0,
                                  child: Text(
                                    item['title'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      height: 1.15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 2,
                                  bottom: 0,
                                  child: Text(
                                    item['date'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
    );
  }
}
