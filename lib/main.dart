import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:teste/pages/home.dart';
import 'package:teste/pages/loginscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    );
  }
}
