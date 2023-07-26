import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChateScreen extends StatefulWidget {
  const ChateScreen({super.key});

  @override
  State<ChateScreen> createState() => _ChateScreenState();
}

class _ChateScreenState extends State<ChateScreen> {
  void setupPushNotifications() async {
    // final fcm = FirebaseMessaging.instance;

    // await fcm.requestPermission();

    // fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();

    setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Chat'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            }, 
            icon: const Icon(Icons.exit_to_app)
          )
        ],
      ),
      body: Center(
        child: Column(
          children: const [
            Expanded(child: ChatMessages()),
            NewMessage()
          ],
        ),
      ),
    );
  }
}