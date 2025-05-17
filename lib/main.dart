import 'package:flutter/material.dart';
import 'welcome.dart';

void main() {
  runApp(const Anapurna());
}

class Anapurna extends StatelessWidget {
  const Anapurna({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anapurna',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Poppins'),
      home: WelcomePage(),
    );
  }
}
