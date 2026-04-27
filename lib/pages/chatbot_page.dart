import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  static const Color tealDark = Color(0xFF2B6E7F);
  static const Color tealMid = Color(0xFF5FA9BB);
  static const Color pageBg = Color(0xFFF6F6F6);

  final TextEditingController _controller = TextEditingController();

  final String baseUrl =
      "https://yallarewards-hfhxdxerb8caa8g9.switzerlandnorth-01.azurewebsites.net";

  String conversationId = "";

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  // ================= GET HISTORY =================
  Future<void> loadHistory() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/Chatbot/history"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          messages.clear();

          for (var item in data) {
            messages.add({'text': item['message'], 'isUser': true});

            messages.add({
              'text':
                  item['response'] ??
                  item['answer'] ??
                  item['message'] ??
                  item.toString(),
              'isUser': false,
            });
          }
        });
      }
    } catch (e) {
      print("Error loading history: $e");
    }
  }

  // ================= SEND MESSAGE =================
  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({'text': text, 'isUser': true});
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/Chatbot/ask"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "message": text,
          "conversationSessionId": conversationId.isEmpty
              ? "00000000-0000-0000-0000-000000000000"
              : conversationId,
        }),
      );
      print(response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          messages.add({
            'text': data['botResponse'] ?? "No response",
            'isUser': false,
          });

          conversationId = data['conversationId'] ?? conversationId;
        });
      } else {
        setState(() {
          messages.add({'text': "Server error", 'isUser': false});
        });
      }
    } catch (e) {
      setState(() {
        messages.add({'text': "Connection error", 'isUser': false});
      });
    }
  }

  void sendQuickMessage(String text) {
    _controller.text = text;
    sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: tealMid,
        centerTitle: true,
        title: const Text(
          'ChatBot',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // QUICK BUTTONS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _quickButton('My Points'),
                _quickButton('Offers'),
                _quickButton('Where is Zara?'),
              ],
            ),
          ),

          // CHAT LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final item = messages[index];
                final bool isUser = item['isUser'];

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? tealMid : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      item['text'],
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // INPUT
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        filled: true,
                        fillColor: pageBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: tealDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickButton(String text) {
    return GestureDetector(
      onTap: () => sendQuickMessage(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: tealMid.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(color: tealDark, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
