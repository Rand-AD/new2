import 'package:flutter/material.dart';
import '../Services/api_service.dart';

class ReceiptPage extends StatefulWidget {
  final int transactionId;

  const ReceiptPage({super.key, required this.transactionId});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  static const Color tealDark = Color(0xFF2B6E7F);
  static const Color tealMid = Color(0xFF5FA9BB);
  //static const Color tealLight = Color(0xFFDFF4F8);

  Map<String, dynamic>? receipt;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReceipt();
  }

  Future<void> fetchReceipt() async {
    try {
      final res = await ApiService.getTransaction(widget.transactionId);
      setState(() {
        receipt = res;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("RECEIPT ERROR = $e");
      setState(() => isLoading = false);
    }
  }

  num _numberValue(dynamic value) {
    if (value is num) {
      return value;
    }

    return num.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _stringValue(dynamic value, String fallback) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _capitalizeWords(dynamic value) {
    final text = _stringValue(value, 'Store').toLowerCase();

    return text
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) {
            return word;
          }

          return '${word[0].toUpperCase()}${word.substring(1)}';
        })
        .join(' ');
  }

  String _formatNumber(dynamic value, {int decimals = 0}) {
    final number = _numberValue(value);
    final fixed = number.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final whole = parts.first;
    final sign = whole.startsWith('-') ? '-' : '';
    final digits = sign.isEmpty ? whole : whole.substring(1);
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }

    final formattedWhole = '$sign$buffer';
    if (decimals == 0) {
      return formattedWhole;
    }

    return '$formattedWhole.${parts[1]}';
  }

  String _formatDate(dynamic value) {
    final raw = value?.toString() ?? '';
    if (raw.length >= 10) {
      return raw.substring(0, 10);
    }

    return raw;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final store = _capitalizeWords(receipt?['storeName']);
    final price = receipt?['price'] ?? 0;
    final points = receipt?['pointsEarned'] ?? 0;
    final date = receipt?['createdAt'] ?? '';
    final status = _stringValue(receipt?['status'], 'completed');
    final priceText = '${_formatNumber(price, decimals: 2)} JOD';
    final pointsText = '${_formatNumber(points)} pts';
    final dateText = _formatDate(date);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [tealMid, Color(0xFF88C7D5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🔙 Back + Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    const Text(
                      "Receipt",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🧾 Receipt Card
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🏬 Store Name
                      Center(
                        child: Text(
                          store,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: tealDark,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Divider(),

                      const SizedBox(height: 10),

                      _row("Price", priceText),
                      _row("Points", pointsText),
                      _row("Date", dateText),

                      const SizedBox(height: 20),

                      // ✅ Status Badge
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: status == 'completed'
                                ? Colors.green.withOpacity(0.15)
                                : Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: status == 'completed'
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // ⭐ Bottom message
                      Center(
                        child: Text(
                          "Thank you for your purchase 💙",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 reusable row
  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
