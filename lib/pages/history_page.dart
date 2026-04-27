import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const Color tealDark = Color(0xFF2B6E7F);
  static const Color tealMid = Color(0xFF5FA9BB);
  static const Color pageBg = Color(0xFFF6F6F6);

  String selectedFilter = 'All';

  final List<Map<String, dynamic>> transactions = [
    {
      'store': 'ZARA',
      'action': 'Redeemed',
      'points': -200,
      'date': '12 Feb 2026',
      'status': 'Completed',
      'icon': Icons.local_offer_outlined,
    },
    {
      'store': 'SUBWAY',
      'action': 'Earned',
      'points': 50,
      'date': '10 Feb 2026',
      'status': 'Completed',
      'icon': Icons.fastfood_outlined,
    },
    {
      'store': 'MAX',
      'action': 'Earned',
      'points': 120,
      'date': '08 Feb 2026',
      'status': 'Completed',
      'icon': Icons.shopping_bag_outlined,
    },
    {
      'store': 'H&M',
      'action': 'Redeemed',
      'points': -150,
      'date': '05 Feb 2026',
      'status': 'Pending',
      'icon': Icons.card_giftcard_outlined,
    },
  ];

  List<Map<String, dynamic>> get filteredTransactions {
    if (selectedFilter == 'All') return transactions;
    return transactions
        .where((item) => item['action'] == selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: tealMid,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Transaction History',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            color: tealMid,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Earned'),
                const SizedBox(width: 8),
                _buildFilterChip('Redeemed'),
              ],
            ),
          ),
          Expanded(
            child: filteredTransactions.isEmpty
                ? const Center(
                    child: Text(
                      'No transactions found',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTransactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filteredTransactions[index];
                      final int points = item['points'];
                      final bool isPositive = points > 0;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: tealMid.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item['icon'],
                                color: tealDark,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['store'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['action'],
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['date'],
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isPositive ? '+' : ''}$points pts',
                                  style: TextStyle(
                                    color: isPositive
                                        ? Colors.green
                                        : Colors.redAccent,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item['status'] == 'Completed'
                                        ? Colors.green.withOpacity(0.12)
                                        : Colors.orange.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    item['status'],
                                    style: TextStyle(
                                      color: item['status'] == 'Completed'
                                          ? Colors.green
                                          : Colors.orange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = selectedFilter == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? tealDark : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}