import 'package:flutter/material.dart';
import '../Services/offers_service.dart';
import '../core/session_store.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  late Future<List<dynamic>> offers;

  @override
  void initState() {
    super.initState();

    final sessionId = SessionStore.current?.sessionId ?? "";

    offers = OffersService.getOffers(sessionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Offers")),
      body: FutureBuilder<List<dynamic>>(
        future: offers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final offer = data[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(offer['title'] ?? "No Title"),
                  subtitle: Text(offer['description'] ?? ""),
                ),
              );
            },
          );
        },
      ),
    );
  }
}