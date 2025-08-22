import 'package:flutter/material.dart';

class VoiceInputButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isListening;

  const VoiceInputButton({
    Key? key,
    this.onPressed,
    this.isListening = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isListening ? Colors.red : Colors.pink.shade400,
      ),
      child: IconButton(
        icon: Icon(
          isListening ? Icons.mic : Icons.mic_none,
          color: Colors.white,
        ),
        onPressed: onPressed,
      ),
    );
  }
}