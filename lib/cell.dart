import 'package:flutter/material.dart';
import 'package:worldgen/main.dart';

enum CellType { water, grass, sand }

class Cell {
  late CellType type;

  Cell(this.type);
  Cell.init() {
    type = rand.nextBool() ? CellType.grass : CellType.water;
  }

  static const colorMap = {
    CellType.grass: Colors.lightGreen,
    CellType.water: Colors.teal,
    CellType.sand: Colors.yellow,
  };
}
