import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '古诗拼图',
      home: Column(children: <Widget>[
        Text("section1"),
        Text("section2"),
      ]),
    );
  }
}
