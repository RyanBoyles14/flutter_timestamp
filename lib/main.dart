import 'package:flutter/material.dart';
import 'TimeManager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Time Stamp App',
      theme: new ThemeData(
        accentColor: Colors.blue
      ),
      home: TimeStamp(),
    );
  }
}