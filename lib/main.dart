import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:worldgen/cell.dart';
import 'package:worldgen/gui.dart';
import 'package:worldgen/model.dart';
import 'package:worldgen/utils.dart';

const fieldWidth = 100;

void main() {
  runApp(const Editor());
}

class Editor extends StatefulWidget {
  const Editor({super.key});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  int gen = 0;
  List<Cell> cells = List.generate(fieldWidth * fieldWidth, (_) => Cell(0));

  late List<RuleTile> tiles;

  late List<RuleModel> ruleModel;
  late CellularAutomataModel automata;

  late CellTypeModel cellTypeModel;

  late Stream<List<Cell>> stream;
  @override
  void initState() {
    ruleModel = [
      RuleModel(1, [Condition.always(0.5, 0, 1)]),
    ];

    automata = CellularAutomataModel()..rules = ruleModel;

    tiles = automata.rules
        .map((m) => RuleTile(
              model: m,
              deleteFunction: deleteRule,
            ))
        .toList();

    cellTypeModel = CellTypeModel();

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 400,
                    height: 400,
                    child: CustomPaint(
                      painter: CustomGrid(cells, cellTypeModel),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CellPanel(model: cellTypeModel),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 500,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: tiles,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            addRule();
                          },
                          child: const Text('Добавить правило')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            if (automata.collectData()) {
                              setState(() {
                                cells = List.generate(
                                    fieldWidth * fieldWidth, (_) => Cell(0));
                              });
                              stream = automata.makeStream(cells);
                              stream.listen((event) {
                                setState(() {
                                  cells = List.from(event);
                                });
                              });
                            }
                          },
                          child: Text('Запустить')),
                    )
                  ],
                ),
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

class CustomGrid extends CustomPainter {
  static const cellWidth = 4.0;

  final List<Cell> cells;
  final CellTypeModel model;

  CustomGrid(this.cells, this.model);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    for (int i = 0; i < fieldWidth * fieldWidth; i++) {
      canvas.drawRect(
          Rect.fromLTWH((i % fieldWidth) * cellWidth,
              (i ~/ fieldWidth) * cellWidth, cellWidth, cellWidth),
          paint..color = model.getColor(cells[i].type));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
