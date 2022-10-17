import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:worldgen/cell.dart';
import 'package:worldgen/generator.dart';
import 'package:worldgen/gui.dart';
import 'package:worldgen/model.dart';
import 'package:worldgen/utils.dart';

const fieldWidth = 100;

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
  List<Cell> cells =
      List.generate(fieldWidth * fieldWidth, (_) => Cell(CellType.water));

  late List<RuleTile> tiles;

  late List<RuleModel> model;
  late CellularAutomataModel automata;

  late Stream<List<Cell>> stream;
  @override
  void initState() {
    model = [
      RuleModel(1, [Condition.always(0.5, 0, 1)]),
    ];

    automata = CellularAutomataModel()..rules = model;

    tiles = automata.rules
        .map((m) => RuleTile(
              model: m,
              deleteFunction: deleteRule,
            ))
        .toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      home: Scaffold(
          body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 400,
              height: 400,
              child: CustomPaint(
                painter: CustomGrid(cells),
              ),
            ),
            SizedBox(
              width: 500,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: tiles,
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        addRule();
                      },
                      child: Text('Добавить правило')),
                  ElevatedButton(
                      onPressed: () {
                        if (automata.collectData()) {
                          setState(() {
                            cells = List.generate(fieldWidth * fieldWidth,
                                (_) => Cell(CellType.values.first));
                          });
                          stream = automata.makeStream(cells);
                          stream.listen((event) {
                            setState(() {
                              cells = List.from(event);
                            });
                          });
                        }
                      },
                      child: Text('Запустить'))
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  void deleteRule(RuleTile ruleTile) {
    automata.deleteRule(ruleTile.model);
    setState(() {
      tiles = List.from(tiles..remove(ruleTile));
    });
  }

  void addRule() {
    final r = RuleModel(1, [Condition.always(0.5, 0, 1)]);
    automata.addRule(r);
    setState(() {
      tiles = List.from(tiles
        ..add(RuleTile(
          model: r,
          deleteFunction: deleteRule,
        )));
    });
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
