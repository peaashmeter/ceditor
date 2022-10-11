import 'package:worldgen/cell.dart';
import 'package:worldgen/main.dart';

int findNearby(int index, List<Cell> cells, CellType type) {
  List<int> indices = [];
  //верх
  indices.add(index - fieldWidth - 1);
  indices.add(index - fieldWidth);
  indices.add(index - fieldWidth + 1);
  //стороны
  indices.add(index - 1);
  indices.add(index + 1);
  //низ
  indices.add(index + fieldWidth - 1);
  indices.add(index + fieldWidth);
  indices.add(index + fieldWidth + 1);

  //удаление несуществующих
  //indices.removeWhere((i) => i < 0 || i >= fieldWidth * fieldWidth);

  //Тороидальная форма
  for (var i = 0; i < indices.length; i++) {
    if (indices[i] < 0) {
      indices[i] = fieldWidth * fieldWidth - indices[i];
    }
    if (indices[i] >= fieldWidth * fieldWidth) {
      indices[i] -= fieldWidth * fieldWidth;
    }
  }

  int water = 0;
  for (var i in indices) {
    if (cells[i].type == type) water++;
  }
  return water;
}
