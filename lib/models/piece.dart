class Piece {
  late List<List<int>> shape;
  late int rotationState;

  Piece(this.shape) {
    rotationState = 0;
  }

  void rotate() {
    rotationState = (rotationState + 1) % 4;
    shape = _rotateShape(shape);
  }

  List<List<int>> _rotateShape(List<List<int>> shape) {
    final int rows = shape.length;
    final int cols = shape[0].length;
    final List<List<int>> newShape = List.generate(cols, (i) => List.filled(rows, 0));

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        newShape[j][rows - 1 - i] = shape[i][j];
      }
    }
    return newShape;
  }
}