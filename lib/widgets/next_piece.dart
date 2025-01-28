import 'package:flutter/material.dart';
import '../models/piece.dart';
import '../utils/constants.dart';

class NextPieceDisplay extends StatelessWidget {
  const NextPieceDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Next Piece:',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}