import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'dart:convert';
// import 'dart:io';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'package:chat_app/login_page.dart';
// ChatPage is defined in this file, no separate chat_page.dart is needed
// Login functionality is handled through the _logout method in ChatPage

void main() async {
  // Load the .env file
  await dotenv.load(fileName: "assets/.env");
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
          home: LoginPage(),
        );
      },
    );
  }
}
