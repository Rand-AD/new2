import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  static const Color tealDark = Color(0xFF2B6E7F);
  static const Color tealMid = Color(0xFF5FA9BB);
  static const Color pageBg = Color(0xFFF6F6F6);

  @override
  Widget build(BuildContext context) {
    final shops = [
      {'name': 'ZARA', 'floor': 'First Floor', 'icon': Icons.checkroom},
      {'name': 'SUBWAY', 'floor': 'Ground Floor', 'icon': Icons.fastfood},
      {'name': 'MAX', 'floor': 'Second Floor', 'icon': Icons.shopping_bag},
      {'name': 'Cinema', 'floor': 'Third Floor', 'icon': Icons.movie},
    ];

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: tealMid,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mall Map',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.map_outlined,
                      size: 120,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 50,
                    child: _marker('ZARA'),
                  ),
                  Positioned(
                    top: 120,
                    right: 40,
                    child: _marker('MAX'),
                  ),
                  Positioned(
                    bottom: 35,
                    left: 80,
                    child: _marker('SUBWAY'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for a store...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            ListView.separated(
              itemCount: shops.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final shop = shops[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: tealMid.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          shop['icon'] as IconData,
                          color: tealDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shop['name'] as String,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              shop['floor'] as String,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _marker(String label) {
    return Column(
      children: [
        const Icon(Icons.location_on, color: Colors.redAccent, size: 28),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: tealDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}