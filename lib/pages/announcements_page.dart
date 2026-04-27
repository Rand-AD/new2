import 'package:flutter/material.dart';
import '../Services/api_service.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  late Future<List<dynamic>> announcements;

  @override
  void initState() {
    super.initState();
    announcements = ApiService.getAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Announcements")),
      body: FutureBuilder<List<dynamic>>(
        future: announcements,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;

          if (data.isEmpty) {
            return const Center(child: Text("No announcements"));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(item['title'] ?? ''),
                  subtitle: Text(item['content'] ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
