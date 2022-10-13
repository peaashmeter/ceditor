import 'package:worldgen/cell.dart';
import 'package:worldgen/main.dart';

int findNearby(int index, List<Cell> cells, CellType type) {
  final x = index % fieldWidth;
  final y = index ~/ fieldWidth;

  List<int> indices = [];
  //верх
  indices.add(ctl(x - 1, y - 1));
  indices.add(ctl(x, y - 1));
  indices.add(ctl(x + 1, y - 1));
  //стороны
  indices.add(ctl(x - 1, y));
  indices.add(ctl(x + 1, y));
  //низ
  indices.add(ctl(x - 1, y + 1));
  indices.add(ctl(x, y + 1));
  indices.add(ctl(x + 1, y + 1));

  //удаление несуществующих
  //indices.removeWhere((i) => i < 0 || i >= fieldWidth * fieldWidth);

  //Тороидальная форма
  // for (var i = 0; i < indices.length; i++) {
  //   if (indices[i] < 0) {
  //     indices[i] = fieldWidth * fieldWidth - indices[i];
  //   }
  //   if (indices[i] >= fieldWidth * fieldWidth) {
  //     indices[i] -= fieldWidth * fieldWidth;
  //   }
  // }

  int c = 0;
  for (var i in indices) {
    if (cells[i].type == type) c++;
  }
  return c;
}

///Cartesian To Linear
int ctl(int x, int y) {
  x %= fieldWidth;
  y %= fieldWidth;
  return fieldWidth * y + x;
}
