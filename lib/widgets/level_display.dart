import 'package:flutter/material.dart';

class LevelDisplay extends StatelessWidget {
  final int level;
  
  const LevelDisplay({super.key, required this.level});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Level:',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          Text(
            '$level',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }
}