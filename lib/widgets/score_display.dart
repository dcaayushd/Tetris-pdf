// import 'package:flutter/material.dart';

// class ScoreDisplay extends StatelessWidget {
//   final int score;

//   const ScoreDisplay({super.key, required this.score});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           const Text(
//             'Score:',
//             style: TextStyle(fontSize: 16, color: Colors.black),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '$score'.padLeft(6, '0'), 
//             style: const TextStyle(
//               fontSize: 24,
//               color: Colors.black,
//               fontFamily: 'Courier',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class ScoreDisplay extends StatelessWidget {
  final int score;

  const ScoreDisplay({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Score:',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            '$score'.padLeft(6, '0'),
            style: const TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }
}