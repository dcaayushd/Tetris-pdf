import 'package:flutter/material.dart';
import 'package:tetris_pdf/models/piece.dart';
import 'package:tetris_pdf/utils/constants.dart';
import 'widgets/control_buttons.dart';
import 'widgets/game_board.dart';
import 'widgets/next_piece.dart';
import 'widgets/score_display.dart';

void main() {
  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDF-Style Tetris',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          surface: Colors.white,
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Courier', color: Colors.black),
          bodyMedium: TextStyle(fontFamily: 'Courier', color: Colors.black),
        ),
      ),
      home: const Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: TetrisGame(),
        ),
      ),
    );
  }
}

class TetrisGame extends StatefulWidget {
  const TetrisGame({super.key});

  @override
  State<TetrisGame> createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame> {
  late Piece nextPiece;
  int score = 0;
  late GlobalKey<GameBoardState> gameBoardKey;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    gameBoardKey = GlobalKey<GameBoardState>();
    nextPiece = _getRandomPiece();

    // Delay initialization until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    });
  }

  Piece _getRandomPiece() {
    final random = DateTime.now().millisecond % pieces.length;
    return Piece(pieces[random]);
  }

  void _handleScoreUpdate(int newScore) {
    if (mounted) {
      setState(() => score = newScore);
    }
  }

  void _handleNextPieceUpdate(Piece newNextPiece) {
    if (mounted) {
      setState(() => nextPiece = newNextPiece);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: ScoreDisplay(score: score),
              ),
              if (_isInitialized)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: IconButton(
                    icon: Icon(
                      gameBoardKey.currentState?.isPaused == true
                          ? Icons.play_arrow
                          : Icons.pause,
                      size: 24,
                    ),
                    onPressed: () {
                      final currentState = gameBoardKey.currentState;
                      if (currentState != null) {
                        final newPauseState = !currentState.isPaused;
                        currentState.togglePause(newPauseState);
                        setState(() {});
                      }
                    },
                  ),
                ),
              Expanded(
                flex: 1,
                child: NextPieceDisplay(nextPiece: nextPiece),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: _isInitialized
              ? GameBoard(
                  key: gameBoardKey,
                  onScoreUpdate: _handleScoreUpdate,
                  onNextPieceUpdate: _handleNextPieceUpdate,
                )
              : const Center(child: CircularProgressIndicator()),
        ),
        if (_isInitialized)
          ControlButtons(
            onLeft: () => gameBoardKey.currentState?.movePiece(-1),
            onRight: () => gameBoardKey.currentState?.movePiece(1),
            onDown: () => gameBoardKey.currentState?.moveDown(),
            onRotate: () => gameBoardKey.currentState?.rotatePiece(),
          ),
      ],
    );
  }
}