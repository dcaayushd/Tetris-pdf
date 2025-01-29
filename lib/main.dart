import 'package:flutter/material.dart';
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
          background: Colors.white,
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

class TetrisGame extends StatelessWidget {
  const TetrisGame({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
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
                child: NextPieceDisplay(),
              ),
              Expanded(
                flex: 1,
                child: ScoreDisplay(),
              ),
            ],
          ),
        ),
        ControlButtons(),
      ],
    );
  }
}
