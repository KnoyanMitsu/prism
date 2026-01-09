import 'package:flutter/material.dart';
import 'package:prism/pages/root_pages.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prism App',
      theme: ThemeData(
        useMaterial3: true,
        // Masukkan font atau tema di sini
      ),
      home: const RootPages(),
    );
  }
}
