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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16),
            ),
            onPressed: onLeft,
            child: const Icon(Icons.arrow_back, size: 40),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16),
            ),
            onPressed: onRight,
            child: const Icon(Icons.arrow_forward, size: 40),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16),
            ),
            onPressed: onDown,
            child: const Icon(Icons.arrow_downward, size: 40),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16),
            ),
            onPressed: onRotate,
            child: const Icon(Icons.rotate_right, size: 40),
          ),
        ],
      ),
    );
  }
}