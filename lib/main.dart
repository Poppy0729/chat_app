import 'package:chat_app/screens/auth.dart';
import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            return const ChateScreen();
          }
          return const AuthScreen();
        }),
      ),
    );
  }
}