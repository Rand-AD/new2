import 'package:flutter/material.dart';
import '../Services/api_service.dart';

class ShopsPage extends StatefulWidget {
  const ShopsPage({super.key});

  @override
  State<ShopsPage> createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> {
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
        stores = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Shops")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: stores.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (_, index) {
                final store = stores[index];

                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF6DAAB4)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text(store['name'] ?? '')),
                );
              },
            ),
    );
  }
}