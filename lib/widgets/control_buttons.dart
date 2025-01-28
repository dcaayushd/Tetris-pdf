import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_left),
            onPressed: () {
              // Move left
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_right),
            onPressed: () {
              // Move right
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_downward),
            onPressed: () {
              // Move down
            },
          ),
          IconButton(
            icon: const Icon(Icons.rotate_right),
            onPressed: () {
              // Rotate
            },
          ),
        ],
      ),
    );
  }
}