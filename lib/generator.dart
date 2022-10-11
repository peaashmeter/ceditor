import 'package:worldgen/cell.dart';
import 'package:worldgen/main.dart';
import 'package:worldgen/utils.dart';

List<Cell> ocean(List<Cell> cells) {
  List<Cell> newCells = [];
  for (var i = 0; i < cells.length; i++) {
    if (cells[i].type == CellType.deepWater) {
      final n = findNearby(i, cells, CellType.sand);
      final w = findNearby(i, cells, CellType.water);
      final r = rand.nextDouble();
      if (n > 0 || w > 2 && r > 0.98) {
        newCells.add(Cell(CellType.water));
      } else {
        newCells.add(Cell(CellType.deepWater));
      }
    } else {
      newCells.add(Cell(cells[i].type));
    }
  }
  return newCells;
}

List<Cell> deepOcean(List<Cell> cells) {
  List<Cell> newCells = [];
  for (var i = 0; i < cells.length; i++) {
    if (cells[i].type == CellType.deepWater) {
      const l = [3, 4, 6, 7, 8];
      final n = findNearby(i, cells, CellType.deepWater);
      if (l.contains(n)) {
        newCells.add(Cell(CellType.deepWater));
      } else {
        newCells.add(Cell(CellType.grass));
      }
    } else if (cells[i].type == CellType.grass) {
      const l = [3, 6, 7, 8];
      final n = findNearby(i, cells, CellType.deepWater);
      if (l.contains(n)) {
        newCells.add(Cell(CellType.deepWater));
      } else {
        newCells.add(Cell(CellType.grass));
      }
    } else {
      newCells.add(Cell(cells[i].type));
    }
  }
  return newCells;
}

List<Cell> coastlineComplex(List<Cell> cells) {
  List<Cell> newCells = [];
  for (var i = 0; i < cells.length; i++) {
    if (cells[i].type == CellType.grass) {
      final n = findNearby(i, cells, CellType.deepWater);
      if (n > 0) {
        newCells.add(Cell(CellType.sand));
      } else {
        newCells.add(Cell(CellType.grass));
      }
    } else if (cells[i].type == CellType.sand) {
      final w = findNearby(i, cells, CellType.deepWater);
      final r = rand.nextDouble();
      if (w > 4 && r > 0.998) {
        newCells.add(Cell(CellType.water));
      } else {
        newCells.add(Cell(CellType.sand));
      }
    } else if (cells[i].type == CellType.deepWater) {
      final s = findNearby(i, cells, CellType.sand);
      if (s > 6) {
        newCells.add(Cell(CellType.sand));
      } else {
        newCells.add(Cell(CellType.deepWater));
      }
    } else {
      newCells.add(Cell(cells[i].type));
    }
  }
  return newCells;
}

List<Cell> coastlineSimple(List<Cell> cells) {
  List<Cell> newCells = [];
  for (var i = 0; i < cells.length; i++) {
    if (cells[i].type == CellType.water) {
      final n = findNearby(i, cells, CellType.grass);
      if (n > 0) {
        newCells.add(Cell(CellType.sand));
      } else {
        newCells.add(Cell(CellType.water));
      }
    } else {
      newCells.add(Cell(cells[i].type));
    }
  }
  return newCells;
}
