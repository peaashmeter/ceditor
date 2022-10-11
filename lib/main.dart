import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:worldgen/cell.dart';
import 'package:worldgen/generator.dart';

const fieldWidth = 100;
const seed = 123456;
final rand = Random(seed);

void main() {
  runApp(const WorldGen());
}

class WorldGen extends StatefulWidget {
  const WorldGen({super.key});

  @override
  State<WorldGen> createState() => _WorldGenState();
}

class _WorldGenState extends State<WorldGen> {
  int gen = 0;
  List<Cell> cells = List.generate(fieldWidth * fieldWidth, (_) => Cell.init());

  late Stream stream;
  late StreamSubscription sub;
  @override
  void initState() {
    stream = Stream.periodic(const Duration(milliseconds: 20));
    sub = stream.listen((event) {
      setState(() {
        if (gen > 9999) {
          sub.pause();
          return;
        }
        cells = nextState(cells, gen++);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CustomPaint(
          painter: CustomGrid(cells),
        ),
      ),
    );
  }
}

List<Cell> nextState(List<Cell> cells, int generation) {
  const oceanGen = 200;
  List<Cell> newCells = [];
  if (generation < oceanGen) {
    newCells = deepOcean(cells);
  } else if (generation < 400) {
    newCells = coastlineComplex(cells);
  } else if (generation < 500) {
    newCells = ocean(cells);
  } else {
    return cells;
  }
  return newCells;
}

class CustomGrid extends CustomPainter {
  static const cellWidth = 16.0;
  static const gap = 2;

  final List<Cell> cells;

  CustomGrid(this.cells);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < fieldWidth * fieldWidth; i++) {
      canvas.drawRect(
          Rect.fromLTWH((i % fieldWidth) * cellWidth / 2,
              (i ~/ fieldWidth) * cellWidth / 2, cellWidth, cellWidth),
          paint..color = Cell.colorMap[cells[i].type]!);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
