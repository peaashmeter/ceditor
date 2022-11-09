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

bool checkIfAtPos(int index, List<int> positions, List<Cell> cells, int type,
    bool connectSides, bool connectTopDown) {
  ///Cartesian To Linear
  int ctl(int x, int y) {
    x = connectSides ? x % fieldWidth : x;
    y = connectTopDown ? y % fieldWidth : y;
    return fieldWidth * y + x;
  }

  final x = index % fieldWidth;
  final y = index ~/ fieldWidth;

  Map<int, int> indices = {};
  //верх
  indices[0] = (ctl(x - 1, y - 1));
  indices[1] = (ctl(x, y - 1));
  indices[2] = (ctl(x + 1, y - 1));
  //стороны
  indices[3] = (ctl(x - 1, y));
  indices[4] = (ctl(x, y));
  indices[5] = (ctl(x + 1, y));
  //низ
  indices[6] = (ctl(x - 1, y + 1));
  indices[7] = (ctl(x, y + 1));
  indices[8] = (ctl(x + 1, y + 1));

  //удаление несуществующих
  indices.removeWhere(
      (_, i) => i < 0 || i >= fieldWidth * fieldWidth || i == index);

  for (var p in positions) {
    final i = indices[p];
    if (i == null) continue;
    if (cells[i].type == type) return true;
  }
  return false;
}
