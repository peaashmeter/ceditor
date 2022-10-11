import 'package:worldgen/cell.dart';
import 'package:worldgen/main.dart';
import 'package:worldgen/utils.dart';

List<Cell> ocean(List<Cell> cells) {
  List<Cell> newCells = [];
  for (var i = 0; i < cells.length; i++) {
    if (cells[i].type == CellType.water) {
      const l = [3, 4, 6, 7, 8];
      final n = findNearby(i, cells, CellType.water);
      if (l.contains(n)) {
        newCells.add(Cell(CellType.water));
      } else {
        newCells.add(Cell(CellType.grass));
      }
    } else {
      const l = [3, 6, 7, 8];
      final n = findNearby(i, cells, CellType.water);
      if (l.contains(n)) {
        newCells.add(Cell(CellType.water));
      } else {
        newCells.add(Cell(CellType.grass));
      }
    }
  }
  return newCells;
}

List<Cell> coastlineComplex(List<Cell> cells) {
  List<Cell> newCells = [];
  for (var i = 0; i < cells.length; i++) {
    if (cells[i].type == CellType.grass) {
      final n = findNearby(i, cells, CellType.water);
      if (n > 0) {
        newCells.add(Cell(CellType.sand));
      } else {
        newCells.add(Cell(CellType.grass));
      }
    } else if (cells[i].type == CellType.sand) {
      final w = findNearby(i, cells, CellType.water);
      final r = rand.nextDouble();
      if (w > 4 && r > 0.998) {
        newCells.add(Cell(CellType.water));
      } else {
        newCells.add(Cell(CellType.sand));
      }
    } else if (cells[i].type == CellType.water) {
      final s = findNearby(i, cells, CellType.sand);
      if (s > 6) {
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
