import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final Function() onLeft;
  final Function() onRight;
  final Function() onDown;
  final Function() onRotate;

  const ControlButtons({
    super.key,
    required this.onLeft,
    required this.onRight,
    required this.onDown,
    required this.onRotate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 40),
            onPressed: onLeft,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, size: 40),
            onPressed: onRight,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_downward, size: 40),
            onPressed: onDown,
          ),
          IconButton(
            icon: const Icon(Icons.rotate_right, size: 40),
            onPressed: onRotate,
          ),
        ],
      ),
    );
  }
}
