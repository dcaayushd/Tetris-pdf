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
  late int score;

  @override
  void initState() {
    super.initState();
    nextPiece = _getRandomPiece();
    score = 0;
  }

  Piece _getRandomPiece() {
    final random = DateTime.now().millisecond % pieces.length;
    return Piece(pieces[random]);
  }

  void _moveLeft() {
    // Implement left movement logic
  }

  void _moveRight() {
    // Implement right movement logic
  }

  void _moveDown() {
    // Implement down movement logic
  }

  void _rotatePiece() {
    // Implement rotation logic
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: GameBoard(),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: NextPieceDisplay(nextPiece: nextPiece),
              ),
              Expanded(
                flex: 1,
                child: ScoreDisplay(
                    // score: score,
                    ), // Pass score
              ),
            ],
          ),
        ),
        ControlButtons(
          onLeft: _moveLeft, // Pass control callbacks
          onRight: _moveRight,
          onDown: _moveDown,
          onRotate: _rotatePiece,
        ),
      ],
    );
  }
}
