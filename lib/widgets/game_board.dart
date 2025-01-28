import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/piece.dart';
import '../utils/constants.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with SingleTickerProviderStateMixin {
  late List<List<int>> board;
  late Piece currentPiece;
  late Piece nextPiece;
  late int score;
  late int currentRow;
  late int currentCol;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(_updateGame);
    _controller.repeat();
  }

  void _initializeGame() {
    board = List.generate(boardHeight, (i) => List.filled(boardWidth, 0));
    currentPiece = _getRandomPiece();
    nextPiece = _getRandomPiece();
    score = 0;
    currentRow = 0;
    currentCol = boardWidth ~/ 2 - currentPiece.shape[0].length ~/ 2;
  }

  Piece _getRandomPiece() {
    final random = DateTime.now().millisecond % pieces.length;
    return Piece(pieces[random]);
  }

  void _updateGame() {
    if (_checkCollision(currentRow + 1, currentCol, currentPiece.shape)) {
      _placePiece();
      _clearLines();
      currentPiece = nextPiece;
      nextPiece = _getRandomPiece();
      currentRow = 0;
      currentCol = boardWidth ~/ 2 - currentPiece.shape[0].length ~/ 2;
      if (_checkCollision(currentRow, currentCol, currentPiece.shape)) {
        _initializeGame(); // Game over
      }
    } else {
      currentRow++;
    }
    setState(() {});
  }

  void _placePiece() {
    for (int i = 0; i < currentPiece.shape.length; i++) {
      for (int j = 0; j < currentPiece.shape[i].length; j++) {
        if (currentPiece.shape[i][j] == 1) {
          board[currentRow + i][currentCol + j] = 1;
        }
      }
    }
  }

  void _clearLines() {
    for (int i = boardHeight - 1; i >= 0; i--) {
      if (board[i].every((cell) => cell == 1)) {
        board.removeAt(i);
        board.insert(0, List.filled(boardWidth, 0));
        score += 100;
      }
    }
  }

  bool _checkCollision(int row, int col, List<List<int>> shape) {
    for (int i = 0; i < shape.length; i++) {
      for (int j = 0; j < shape[i].length; j++) {
        if (shape[i][j] == 1) {
          if (row + i >= boardHeight || col + j < 0 || col + j >= boardWidth || board[row + i][col + j] == 1) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void _movePiece(int direction) {
    setState(() {
      if (!_checkCollision(currentRow, currentCol + direction, currentPiece.shape)) {
        currentCol += direction;
      }
    });
  }

  void _rotatePiece() {
    setState(() {
      currentPiece.rotate();
      if (_checkCollision(currentRow, currentCol, currentPiece.shape)) {
        currentPiece.rotate();
        currentPiece.rotate();
        currentPiece.rotate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _movePiece(-1);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _movePiece(1);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _updateGame();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _rotatePiece();
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 2),
        ),
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