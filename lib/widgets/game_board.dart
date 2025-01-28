import 'package:flutter/material.dart';
import '../models/piece.dart';
import '../utils/constants.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late List<List<int>> board;
  late Piece currentPiece;
  late int score;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    board = List.generate(boardHeight, (i) => List.filled(boardWidth, 0));
    currentPiece = _getRandomPiece();
    score = 0;
  }

  Piece _getRandomPiece() {
    final random = DateTime.now().millisecond % pieces.length;
    return Piece(pieces[random]);
  }

  void _movePiece(int direction) {
    setState(() {
      // Implement movement logic here
    });
  }

  void _rotatePiece() {
    setState(() {
      currentPiece.rotate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _rotatePiece,
      child: Container(
        color: Colors.white,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: boardWidth,
          ),
          itemBuilder: (context, index) {
            final row = index ~/ boardWidth;
            final col = index % boardWidth;
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                color: board[row][col] == 1 ? Colors.black : Colors.white,
              ),
            );
          },
          itemCount: boardWidth * boardHeight,
        ),
      ),
    );
  }
}