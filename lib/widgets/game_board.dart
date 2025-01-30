import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/piece.dart';
import '../utils/constants.dart';

class GameBoard extends StatefulWidget {
  final Function(int) onScoreUpdate;
  final Function(Piece) onNextPieceUpdate;

  const GameBoard({
    super.key,
    required this.onScoreUpdate,
    required this.onNextPieceUpdate,
  });

  @override
  GameBoardState createState() => GameBoardState();
}

class GameBoardState extends State<GameBoard>
    with SingleTickerProviderStateMixin {
  late List<List<int>> board;
  late Piece currentPiece;
  late Piece nextPiece;
  late int score;
  late int currentRow;
  late int currentCol;
  late AnimationController _controller;
  bool isGameOver = false;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(seconds: 1), _startGame);
      }
    });
  }

  void _initializeGame() {
    board = List.generate(boardHeight, (i) => List.filled(boardWidth, 0));
    currentPiece = _getRandomPiece();
    nextPiece = _getRandomPiece();
    score = 0;
    currentRow = 0;
    currentCol = boardWidth ~/ 2 - currentPiece.shape[0].length ~/ 2;
    isGameOver = false;
    isPaused = false;

    // Initial position validation
    if (_checkCollision(currentRow, currentCol, currentPiece.shape)) {
      currentCol = (boardWidth - currentPiece.shape[0].length) ~/ 2;
      if (_checkCollision(currentRow, currentCol, currentPiece.shape)) {
        _handleGameOver();
      }
    }
  }

  void _startGame() {
    if (mounted && !isGameOver) {
      _controller
        ..reset()
        ..addListener(_updateGame)
        ..repeat();
    }
  }

  void _handleGameOver() {
    if (mounted) {
      setState(() {
        isGameOver = true;
        _controller.stop();
      });
    }
  }

  void togglePause(bool pause) {
    if (mounted) {
      setState(() => isPaused = pause);
      if (pause) {
        _controller.stop();
      } else {
        _controller.repeat();
      }
    }
  }

  Piece _getRandomPiece() {
    final random = DateTime.now().millisecond % pieces.length;
    return Piece(pieces[random]);
  }

  void _updateGame() {
    if (isGameOver || isPaused) return;

    if (_checkCollision(currentRow + 1, currentCol, currentPiece.shape)) {
      _placePiece();
      _clearLines();
      widget.onNextPieceUpdate(nextPiece);
      currentPiece = nextPiece;
      nextPiece = _getRandomPiece();
      currentRow = 0;
      currentCol = boardWidth ~/ 2 - currentPiece.shape[0].length ~/ 2;

      if (_checkCollision(currentRow, currentCol, currentPiece.shape)) {
        _handleGameOver();
      }
    } else {
      currentRow++;
    }
    if (mounted) setState(() {});
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
    int linesCleared = 0;
    for (int i = boardHeight - 1; i >= 0; i--) {
      if (board[i].every((cell) => cell == 1)) {
        board.removeAt(i);
        board.insert(0, List.filled(boardWidth, 0));
        linesCleared++;
      }
    }
    if (linesCleared > 0) {
      score += linesCleared * 100;
      widget.onScoreUpdate(score);
      _controller.duration = Duration(milliseconds: 1000 - (score ~/ 100) * 50);
    }
  }

  bool _checkCollision(int row, int col, List<List<int>> shape) {
    for (int i = 0; i < shape.length; i++) {
      for (int j = 0; j < shape[i].length; j++) {
        if (shape[i][j] == 1) {
          if (row + i >= boardHeight ||
              col + j < 0 ||
              col + j >= boardWidth ||
              board[row + i][col + j] == 1) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void movePiece(int direction) {
    if (isGameOver || isPaused) return;
    setState(() {
      if (!_checkCollision(
          currentRow, currentCol + direction, currentPiece.shape)) {
        currentCol += direction;
      }
    });
  }

  void moveDown() {
    if (isGameOver || isPaused) return;
    setState(() {
      if (!_checkCollision(currentRow + 1, currentCol, currentPiece.shape)) {
        currentRow++;
      }
    });
  }

  void rotatePiece() {
    if (isGameOver || isPaused) return;
    setState(() {
      currentPiece.rotate();
      if (_checkCollision(currentRow, currentCol, currentPiece.shape)) {
        // Rotate back if collision
        currentPiece.rotate();
        currentPiece.rotate();
        currentPiece.rotate();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            autofocus: true,
            onKey: (event) {
              if (event is RawKeyDownEvent && !isPaused) {
                if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                  movePiece(-1);
                } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  movePiece(1);
                } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                  moveDown();
                } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  rotatePiece();
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
          ),
        ),
        if (isGameOver)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text(
                  'Game Over!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    _initializeGame();
                    _startGame();
                    setState(() {});
                  },
                  child: const Text('Restart'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
