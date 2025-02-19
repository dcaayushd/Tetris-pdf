import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris_pdf/widgets/high_score_manager.dart';
import '../models/piece.dart';
import '../utils/constants.dart';

class GameBoard extends StatefulWidget {
  final Function(int) onScoreUpdate;
  final Function(Piece) onNextPieceUpdate;
  final Function(int) onLevelUpdate;

  const GameBoard({
    super.key,
    required this.onScoreUpdate,
    required this.onNextPieceUpdate,
    required this.onLevelUpdate,
  });

  @override
  GameBoardState createState() => GameBoardState();
}

class GameBoardState extends State<GameBoard>
    with SingleTickerProviderStateMixin {
  late List<List<int>> board;
  late Piece currentPiece;
  late Piece nextPiece;
  late AnimationController _controller;
  bool isGameOver = false;
  bool isPaused = false;
  int score = 0;
  int level = 1;
  int linesCleared = 0;
  int combo = 0;
  int currentRow = -1;
  int currentCol = 0;

  // Much slower base speed (1.5 seconds)
  final baseSpeed = 1500;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: baseSpeed),
    );
    _initializeGame();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 3000), _startGame);
      }
    });
  }

  void _initializeGame() {
    board = List.generate(boardHeight, (i) => List.filled(boardWidth, 0));
    currentPiece = _getRandomPiece();
    nextPiece = _getRandomPiece();
    score = 0;
    level = 1;
    linesCleared = 0;
    combo = 0;
    currentRow = -1;
    currentCol = (boardWidth - currentPiece.shape[0].length) ~/ 2;
    isGameOver = false;
    isPaused = false;

    if (_controller.isAnimating) {
      _controller.stop();
    }

    _controller.duration = Duration(milliseconds: baseSpeed);

    Future.microtask(() {
      if (mounted) {
        widget.onScoreUpdate(score);
        widget.onNextPieceUpdate(nextPiece);
        widget.onLevelUpdate(level);
      }
    });
  }

  void _startGame() {
    if (mounted && !isGameOver) {
      _controller
        ..reset()
        ..duration = Duration(milliseconds: baseSpeed)
        ..addListener(_updateGame)
        ..repeat();
    }
  }

  void _updateGameSpeed() {
    // Much slower speed progression
    int newSpeed =
        baseSpeed - (level - 1) * 25; // Only reduce by 25ms per level
    newSpeed = newSpeed.clamp(500, baseSpeed); // Don't go faster than 500ms

    if (_controller.duration?.inMilliseconds != newSpeed) {
      _controller.duration = Duration(milliseconds: newSpeed);
      if (_controller.isAnimating) {
        _controller
          ..stop()
          ..reset()
          ..repeat();
      }
    }
  }

  Piece _getRandomPiece() {
    final random = DateTime.now().millisecond % pieces.length;
    return Piece(pieces[random]);
  }

  void _updateGame() {
    if (isGameOver || isPaused) return;

    setState(() {
      if (_checkCollision(currentRow + 1, currentCol, currentPiece.shape)) {
        _placePiece();
        _clearLines();
        _spawnNewPiece();
      } else {
        currentRow++;
      }
    });
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

    if (piecePlaced) {
      score += 10;
      widget.onScoreUpdate(score);
    }
  }

  void _clearLines() {
    int clearedInMove = 0;
    for (int i = boardHeight - 1; i >= 0; i--) {
      if (board[i].every((cell) => cell == 1)) {
        board.removeAt(i);
        board.insert(0, List.filled(boardWidth, 0));
        clearedInMove++;
        linesCleared++;
      }
    }

    if (clearedInMove > 0) {
      combo++;
      final basePoints = [0, 100, 300, 500, 800][clearedInMove];
      score += (basePoints * level) + (combo * 50);

      // Slower level progression
      level = (score ~/ 7000) +
          1; // Changed from 5000 to 7000 for even slower progression

      widget.onScoreUpdate(score);
      widget.onLevelUpdate(level);
      _updateGameSpeed();
    } else {
      combo = 0;
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

  void _spawnNewPiece() {
    widget.onNextPieceUpdate(nextPiece);
    currentPiece = nextPiece;
    nextPiece = _getRandomPiece();
    currentRow = -1;
    currentCol = (boardWidth - currentPiece.shape[0].length) ~/ 2;

    if (_checkCollision(currentRow, currentCol, currentPiece.shape)) {
      _handleGameOver();
    }
  }

  void movePiece(int direction) {
    if (isGameOver || isPaused) return;
    final newCol = currentCol + direction;
    if (!_checkCollision(currentRow, newCol, currentPiece.shape)) {
      setState(() {
        currentCol = newCol;
      });
    }
  }

  void moveDown() {
    if (isGameOver || isPaused) return;
    if (!_checkCollision(currentRow + 1, currentCol, currentPiece.shape)) {
      setState(() {
        currentRow++;
      });
    }
  }

  void rotatePiece() {
    if (isGameOver || isPaused) return;

    final rotated = Piece(currentPiece.shape);
    rotated.rotate();

    // Try normal rotation
    if (!_checkCollision(currentRow, currentCol, rotated.shape)) {
      setState(() {
        currentPiece = rotated;
      });
      return;
    }

    // Try wall kicks
    for (final offset in [-1, 1, -2, 2]) {
      if (!_checkCollision(currentRow, currentCol + offset, rotated.shape)) {
        setState(() {
          currentPiece = rotated;
          currentCol += offset;
        });
        return;
      }
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

  void _handleGameOver() async {
    if (mounted) {
      setState(() {
        isGameOver = true;
        _controller.stop();
      });
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() async {
      final highScores = await HighScoreManager.getHighScores();
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              'GAME OVER',
              style: TextStyle(
                color: Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Score: $score'),
              const SizedBox(height: 16),
              const Text('Top 5 High Scores:'),
            for (var i = 0; i < highScores.length; i++)
              Text('${i + 1}. ${highScores[i]}'),

            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _initializeGame();
                _startGame();
              },
              child: const Text('Restart'),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Close App'),
            ),
          ],
        );
      },
    );
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
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: boardWidth,
                ),
                itemCount: boardWidth * boardHeight,
                itemBuilder: (context, index) {
                  final row = index ~/ boardWidth;
                  final col = index % boardWidth;
                  final isCurrentPiece = _isCurrentPieceCell(row, col);

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
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isCurrentPieceCell(int row, int col) {
    if (currentRow < 0) return false;
    return row >= currentRow &&
        row < currentRow + currentPiece.shape.length &&
        col >= currentCol &&
        col < currentCol + currentPiece.shape[0].length &&
        currentPiece.shape[row - currentRow][col - currentCol] == 1;
  }
}
