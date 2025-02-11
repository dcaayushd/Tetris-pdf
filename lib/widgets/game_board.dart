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

    // Delay game start to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Future.delayed(const Duration(seconds: 1), _startGame);
        Future.delayed(const Duration(seconds: 2), _startGame);
      }
    });
  }

  void _initializeGame() {
    board = List.generate(boardHeight, (i) => List.filled(boardWidth, 0));
    currentPiece = _getRandomPiece();
    nextPiece = _getRandomPiece();
    score = 0;
    currentRow = -1; // Start above the board
    currentCol = (boardWidth - currentPiece.shape[0].length) ~/ 2;
    isGameOver = false;
    isPaused = false;

    // // Delay callbacks to avoid setState during build
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     widget.onScoreUpdate(score);
    //     widget.onNextPieceUpdate(nextPiece);
    //   }
    // });
   // Instead, schedule them for the next frame
  Future.microtask(() {
    if (mounted) {
      widget.onScoreUpdate(score);
      widget.onNextPieceUpdate(nextPiece);
    }
  });
  }

  void _startGame() {
    if (mounted && !isGameOver) {
      _controller
        ..reset()
        ..addListener(_updateGame)
        ..repeat();
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
      // currentRow = 0;
      currentRow = -1;
      currentCol = (boardWidth - currentPiece.shape[0].length) ~/ 2;

      if (_checkCollision(currentRow, currentCol, currentPiece.shape)) {
        _handleGameOver();
      }
    } else {
      currentRow++;
    }
    if (mounted) setState(() {});
  }


void _placePiece() {
  bool piecePlaced = false;
  for (int i = 0; i < currentPiece.shape.length; i++) {
    for (int j = 0; j < currentPiece.shape[i].length; j++) {
      if (currentPiece.shape[i][j] == 1) {
        final row = currentRow + i;
        if (row >= 0) {
          board[row][currentCol + j] = 1;
          piecePlaced = true;
        }
      }
    }
  }
  
  // Add points for placing a piece
  if (piecePlaced) {
    score += 10;  // Base points for placing a piece
    widget.onScoreUpdate(score);
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
    // Update score based on lines cleared using multiplier for more lines
    final multiplier = [0, 100, 300, 500, 800]; // Bonus for multiple lines
    score += multiplier[linesCleared];
    widget.onScoreUpdate(score);

    // Make speed increase much more gradual
    int baseSpeed = 1000;
    int levelSpeed = (score ~/ 1000) * 50; // Decrease 50ms every 1000 points
    int newSpeed = baseSpeed - levelSpeed;
    
    // Keep speed between 300ms and 1000ms
    newSpeed = newSpeed.clamp(300, 1000);
    
    Duration newDuration = Duration(milliseconds: newSpeed);
    
    // Only update speed if it's different
    if (_controller.duration != newDuration) {
      _controller.duration = newDuration;
      // Important: Reset the animation with new duration
      _controller
        ..stop()
        ..reset()
        ..repeat();
    }
  }
}

  bool _checkCollision(int row, int col, List<List<int>> shape) {
    for (int i = 0; i < shape.length; i++) {
      for (int j = 0; j < shape[i].length; j++) {
        if (shape[i][j] == 1) {
          final boardRow = row + i;
          final boardCol = col + j;
          if (boardRow >= boardHeight ||
              boardCol < 0 ||
              boardCol >= boardWidth) {
            return true;
          }
          if (boardRow >= 0 && board[boardRow][boardCol] == 1) {
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
      final newCol = currentCol + direction;
      if (!_checkCollision(currentRow, newCol, currentPiece.shape)) {
        currentCol = newCol;
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
      final rotated = Piece(currentPiece.shape);
      rotated.rotate();
      if (!_checkCollision(currentRow, currentCol, rotated.shape)) {
        currentPiece = rotated;
      }
    });
  }

  void _handleGameOver() {
    if (mounted) {
      setState(() {
        isGameOver = true;
        _controller.stop();
      });
    }
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
                switch (event.logicalKey) {
                  case LogicalKeyboardKey.arrowLeft:
                    movePiece(-1);
                    break;
                  case LogicalKeyboardKey.arrowRight:
                    movePiece(1);
                    break;
                  case LogicalKeyboardKey.arrowDown:
                    moveDown();
                    break;
                  case LogicalKeyboardKey.arrowUp:
                    rotatePiece();
                    break;
                  default:
                    break;
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
                  final isCurrentPiece = row >= currentRow &&
                      row < currentRow + currentPiece.shape.length &&
                      col >= currentCol &&
                      col < currentCol + currentPiece.shape[0].length &&
                      currentPiece.shape[row - currentRow][col - currentCol] ==
                          1;

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      color: isCurrentPiece
                          ? Colors.black
                          : board[row][col] == 1
                              ? Colors.black
                              : Colors.white,
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
                    _controller.stop();
                    _initializeGame();
                    _startGame();
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
