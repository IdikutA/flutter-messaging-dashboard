// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messaging + Dashboard Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ChatScreen(),        // Messaging UI
    const DashboardWebView(),  // Angular dashboard
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messaging',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool waitingForClarification = false;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        setState(() {
          _unreadCount = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _messages.add({
          'sender': 'You',
          'text': '[image]',
          'time': _formatTime(DateTime.now()),
          'imagePath': picked.path,
        });
      });
      _saveMessages();
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_messages);
    prefs.setString('messages', json);
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('messages');
    if (data != null) {
      setState(() {
        _messages.clear();
        final List<dynamic> decoded = jsonDecode(data);
        _messages.addAll(decoded.map((e) => Map<String, String>.from(e)).toList());
      });
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'sender': 'You',
        'text': text,
        'time': _formatTime(DateTime.now())
      });

      _messages.add({
        'sender': 'Agent',
        'text': '...typing',
        'time': _formatTime(DateTime.now())
      });
    });

    _controller.clear();
    _saveMessages();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.removeLast();
        _messages.add({
          'sender': 'Agent',
          'text': _autoReply(text),
          'time': _formatTime(DateTime.now())
        });
        _unreadCount++;
        _saveMessages();
      });
    });
  }

  String _autoReply(String userInput) {
    final input = userInput.toLowerCase().trim();

    if (waitingForClarification) {
      waitingForClarification = false;
      return "Leave your contact info and an agent will get back to you soon. Thank you!";
    }

    if (input.startsWith("hello") || input.startsWith("hi") || input.startsWith("hey")) {
      return "Hi, I am a chatbot for help! 😄";
    }

    if (input.endsWith("?")) {
      waitingForClarification = true;
      return "Could you please clarify?";
    }

    if (input.contains("thank")) {
      return "You're welcome ❤️";
    }

    if (input.contains("bye")) {
      return "Goodbye! Have a great day!";
    }

    return "Hi, I am a chatbot. How can I help?";
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Messages"),
            if (_unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'You';
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!isUser)
                      CircleAvatar(child: Text(msg['sender']![0])),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            msg.containsKey('imagePath')
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${msg['sender']}:"),
                                      const SizedBox(height: 4),
                                      Image.file(File(msg['imagePath']!), width: 150),
                                    ],
                                  )
                                : Text("${msg['sender']}: ${msg['text']}"),
                            const SizedBox(height: 4),
                            Text(
                              msg['time'] ?? "",
                              style: const TextStyle(fontSize: 10, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isUser) CircleAvatar(child: Text(msg['sender']![0])),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.green),
                    onPressed: _pickImage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: () {
                      _sendMessage();
                      setState(() {
                        _unreadCount = 0;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardWebView extends StatelessWidget {
  const DashboardWebView({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // On Chrome/Web, just open the Angular dashboard in a new tab
      _launchDashboard();
      return const Scaffold(
        body: Center(
          child: Text(
            'Dashboard opened in a new browser tab.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    } else {
      // On Android/iOS/macOS, use WebView
      return const DashboardWebViewNative();
    }
  }

  Future<void> _launchDashboard() async {
    final url = Uri.parse('http://localhost:4200');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

class DashboardWebViewNative extends StatefulWidget {
  const DashboardWebViewNative({super.key});

  @override
  State<DashboardWebViewNative> createState() => _DashboardWebViewNativeState();
}

class _DashboardWebViewNativeState extends State<DashboardWebViewNative> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('http://localhost:4200'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Angular Dashboard')),
      body: WebViewWidget(controller: controller),
    );
  }
}
