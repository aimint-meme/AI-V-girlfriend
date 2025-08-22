import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/girlfriend_provider.dart';

class SimpleChatScreen extends StatelessWidget {
  const SimpleChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final girlfriendProvider = Provider.of<GirlfriendProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          girlfriendProvider.currentGirlfriend?.name ?? '聊天',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pink.shade400,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink.shade50,
              Colors.white,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: Colors.pink,
              ),
              SizedBox(height: 20),
              Text(
                '聊天功能',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '与你的AI女友开始对话',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}