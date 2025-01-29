import 'package:flutter/material.dart';
import '../models/piece.dart';

class NextPieceDisplay extends StatelessWidget {
  final Piece nextPiece;

  const NextPieceDisplay({super.key, required this.nextPiece});

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
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: nextPiece.shape[0].length,
            ),
            itemBuilder: (context, index) {
              final row = index ~/ nextPiece.shape[0].length;
              final col = index % nextPiece.shape[0].length;
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  color: nextPiece.shape[row][col] == 1 ? Colors.black : Colors.white,
                ),
              );
            },
            itemCount: nextPiece.shape.length * nextPiece.shape[0].length,
          ),
        ],
      ),
    );
  }
}