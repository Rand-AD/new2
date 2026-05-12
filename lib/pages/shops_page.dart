import 'package:flutter/material.dart';

import '../Services/api_service.dart';
import 'shop_details_page.dart';

class ShopsPage extends StatefulWidget {
  const ShopsPage({super.key});

  @override
  State<ShopsPage> createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> {
  static const Color tealMid = Color(0xFF5FA9BB);
  static const Color pageBg = Color(0xFFF6F6F6);

  List stores = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStores();
  }

  Future<void> fetchStores() async {
    try {
      final data = await ApiService.getStores();
      setState(() {
        stores = data
            .where(
              (s) =>
                  s['storeImageUrl'] != null &&
                  s['storeImageUrl'].toString().isNotEmpty,
            )
            .toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => isLoading = false);
    }
  }

  void _openStoreDetails(dynamic store) {
    if (store is! Map) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ShopDetailsPage(store: Map<String, dynamic>.from(store)),
      ),
    );
  }

  String _displayStoreName(dynamic value) {
    final text = value?.toString().trim() ?? '';

    if (text.isEmpty) {
      return '';
    }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: Column(
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: tealMid,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(56),
                bottomRight: Radius.circular(56),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Positioned(
                    left: 18,
                    top: 16,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: Center(
                      child: Text(
                        'Shops',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : stores.isEmpty
                ? const Center(
                    child: Text(
                      'No stores found',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    itemCount: stores.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.95,
                        ),
                    itemBuilder: (_, index) {
                      final store = stores[index];
                      final imageUrl = store['storeImageUrl']?.toString() ?? '';

                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _openStoreDetails(store),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFF5FA9BB),
                              width: 2.2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: Center(
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                          imageUrl,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.store, size: 64),
                                        )
                                      : const Icon(Icons.store, size: 64),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 44,
                                child: Center(
                                  child: Text(
                                    _displayStoreName(store['name']),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF2B6E7F),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
