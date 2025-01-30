import 'package:flutter/material.dart';

import '../models/piece.dart';

class NextPieceDisplay extends StatelessWidget {
  final Piece nextPiece;

  const NextPieceDisplay({super.key, required this.nextPiece});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Text(
            'Next Piece:',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              // final cellSize = constraints.maxWidth / 4;
              return SizedBox(
                width: 100,
                height: 100,
                // width: constraints.maxWidth,
                // height: cellSize * 4,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                  ),
                  itemBuilder: (context, index) {
                    final row = index ~/ 4;
                    final col = index % 4;
                    final pieceRow = row - (4 - nextPiece.shape.length) ~/ 2;
                    final pieceCol = col - (4 - nextPiece.shape[0].length) ~/ 2;
                    final isFilled = pieceRow >= 0 &&
                        pieceRow < nextPiece.shape.length &&
                        pieceCol >= 0 &&
                        pieceCol < nextPiece.shape[0].length &&
                        nextPiece.shape[pieceRow][pieceCol] == 1;
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        color: isFilled ? Colors.black : Colors.white,
                      ),
                    );
                  },
                  itemCount: 16,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
