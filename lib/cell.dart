import 'package:flutter/material.dart';
import 'package:worldgen/main.dart';
import 'package:worldgen/utils.dart';

class Cell {
  late int type;

  Cell(this.type);
}

class CellTypeModel extends ChangeNotifier {
  final List<Color> _colors;
  CellTypeModel() : _colors = [Colors.black, Colors.white];
  CellTypeModel.colors(List<Color> colors) : _colors = colors;

  Color getColor(int i) => _colors[i];

  List<Color> get colors => List.from(_colors);

  ///Добавляет новый тип клетки с черным цветом
  void addColor() {
    _colors.add(Colors.black);
    notifyListeners();
  }

  void setColor(int i, Color color) {
    _colors[i] = color;
    notifyListeners();
  }

  void removeColor(int i) {
    _colors.removeAt(i);
    notifyListeners();
  }
}
