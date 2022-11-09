import 'dart:math';

import 'package:ceditor/model.dart';

import 'cell.dart';
import 'main.dart';

late final SeededRandom random;
late CellularAutomataModel automataModel;

class SeededRandom {
  Random rand;

  SeededRandom() : rand = Random();

  void setSeed(int seed) {
    rand = Random(seed);
  }
}

int findNearby(int index, List<Cell> cells, int type, bool connectSides,
    bool connectTopDown) {
  ///Cartesian To Linear
  int ctl(int x, int y) {
    x = connectSides ? x % fieldWidth : x;
    y = connectTopDown ? y % fieldWidth : y;
    return fieldWidth * y + x;
  }

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
  indices
      .removeWhere((i) => i < 0 || i >= fieldWidth * fieldWidth || i == index);

  int c = 0;
  for (var i in indices) {
    if (cells[i].type == type) c++;
  }
  return c;
}
