import 'package:flutter/material.dart';
import 'package:worldgen/main.dart';

enum CellType { water, deepWater, grass, sand }

class Cell {
  late CellType type;

  Cell(this.type);
  Cell.init() {
    type = rand.nextBool() ? CellType.deepWater : CellType.grass;
  }

  static final colorMap = {
    CellType.grass: Colors.lightGreen,
    CellType.water: Colors.cyan,
    CellType.deepWater: Colors.blue,
    CellType.sand: Colors.yellow,
  };
}
