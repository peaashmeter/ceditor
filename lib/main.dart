import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:worldgen/cell.dart';
import 'package:worldgen/generator.dart';

const fieldWidth = 100;
const seed = 123456;
final rand = Random();

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
        body: Stack(children: [
          Container(
            color: Colors.blueGrey[900],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                width: 400,
                height: 400,
                child: CustomPaint(
                  painter: CustomGrid(cells),
                ),
              ),
            ]),
            Column(
              children: [
                Card(
                  child: Column(
                    children: [Text('Функция 1')],
                  ),
                )
              ],
            )
          ]),
        ]),
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
  } else if (generation < 501) {
    for (var i = 0; i < cells.length; i++) {
      if (cells[i].type == CellType.grass) {
        if (rand.nextBool()) {
          newCells.add(Cell(CellType.forest));
        } else {
          newCells.add(Cell(CellType.grass));
        }
      } else {
        newCells.add(Cell(cells[i].type));
      }
    }
  } else if (generation < 550) {
    newCells = forest(cells);
  } else {
    return cells;
  }
  return newCells;
}

class CustomGrid extends CustomPainter {
  static const cellWidth = 4.0;

  final List<Cell> cells;

  CustomGrid(this.cells);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    for (int i = 0; i < fieldWidth * fieldWidth; i++) {
      canvas.drawRect(
          Rect.fromLTWH((i % fieldWidth) * cellWidth,
              (i ~/ fieldWidth) * cellWidth, cellWidth, cellWidth),
          paint..color = Cell.colorMap[cells[i].type]!);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
