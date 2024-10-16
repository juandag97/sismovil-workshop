import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

void main() async {
  // Load the .env file
  // await dotenv.load(fileName: "../.env");
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Sismovil Chat',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.themeMode, // Aplica el tema dinámicamente
          home: ChatPage(),
        );
      },
    );
  }
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  // Reemplaza con tu API key de OpenAI
  final String apiKey = 'YOUR-API-KEY';
  // final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.add({'sender': 'user', 'text': message});
      _isLoading = true;
    });

    final response = await _sendToOpenAI(message);

    setState(() {
      _messages.add({'sender': 'bot', 'text': response});
      _isLoading = false;
    });
  }

  Future<String> _sendToOpenAI(String message) async {
    const apiUrl = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are a helpful assistant.'},
          {'role': 'user', 'content': message},
        ],
        'max_tokens': 100,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final reply = data['choices'][0]['message']['content'];
      return reply.trim();
    } else {
      return 'Error: ${response.statusCode}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sismovil Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () {
              // Alternar entre light y dark mode
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(
                    message['text']!,
                    textAlign: message['sender'] == 'user'
                        ? TextAlign.end
                        : TextAlign.start,
                  ),
                  subtitle: Text(message['sender']!),
                );
              },
            ),
          ),
          if (_isLoading) CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final message = _controller.text;
                    if (message.isNotEmpty) {
                      _controller.clear();
                      _sendMessage(message);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
