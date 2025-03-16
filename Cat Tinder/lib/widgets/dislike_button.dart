import 'package:flutter/material.dart';

class DislikeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double scale;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;

  const DislikeButton({
    super.key,
    required this.onPressed,
    required this.scale,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: onTapCancel,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 100),
        child: const CircleAvatar(
          backgroundColor: Colors.redAccent,
          radius: 35,
          child: Icon(Icons.thumb_down, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
