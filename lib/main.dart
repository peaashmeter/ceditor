import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' hide File;
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'cell.dart';
import 'gui.dart';
import 'model.dart';
import 'template.dart';
import 'utils.dart';

const fieldWidth = 100;

void main() {
  if (kDebugMode) {
    print(":(");
  }

  random = SeededRandom();
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

  int? seed;

  late List<RuleTile> tiles;
  late CellularAutomataModel automata;
  late Stream<List<Cell>> stream;
  StreamSubscription? streamSubscription;
  late ScrollController rulesListController;

  @override
  void initState() {
    automata = CellularAutomataModel()
      ..rules = [
        RuleModel(
          1,
          [
            Condition.always(0.5, 0, 1),
          ],
        ),
      ];
    tiles = generateTiles(automata);
    rulesListController = ScrollController();

    super.initState();
  }

  List<RuleTile> generateTiles(CellularAutomataModel model) {
    tiles = [];
    for (var i = 0; i < model.rules.length; i++) {
      var m = model.rules[i];
      tiles.add(RuleTile(
        index: i + 1,
        model: m,
        deleteFunction: deleteRule,
        key: ValueKey(automata.rules[i]),
      ));
    }
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Редактор клеточных автоматов',
      theme: ThemeData(
          colorScheme: const ColorScheme.dark(),
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.purpleAccent),
                borderRadius: BorderRadius.circular(8.0)),
            labelStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          )),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      home: Scaffold(
          body: Container(
        color: Colors.grey[900],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              final json = jsonEncode(automata.toJson());
                              final bytes = utf8.encode(json);
                              final blob = Blob([bytes]);
                              final url = Url.createObjectUrlFromBlob(blob);
                              final anchor =
                                  document.createElement('a') as AnchorElement
                                    ..href = url
                                    ..style.display = 'none'
                                    ..download = 'automaton.json';
                              document.body?.children.add(anchor);

                              anchor.click();

                              document.body?.children.remove(anchor);
                              Url.revokeObjectUrl(url);
                            },
                            child: const Text('Сохранить')),
                        ElevatedButton(
                            onPressed: () async {
                              var result = await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['json']);

                              if (result != null) {
                                final bytes = result.files.first.bytes;
                                final json = utf8.decode(bytes!);
                                final asMap = jsonDecode(json);
                                final automaton_ =
                                    CellularAutomataModel.fromJson(asMap);
                                loadAutomaton(automaton_);
                              }
                            },
                            child: const Text('Загрузить')),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.teal),
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                                onPressed: () => loadTemplate(0),
                                child: const Text('Жизнь')),
                            TextButton(
                                onPressed: () => loadTemplate(1),
                                child: const Text('День и ночь')),
                            TextButton(
                                onPressed: () => loadTemplate(2),
                                child: const Text('Континент')),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 400,
                    height: 400,
                    child: CustomPaint(
                      painter: CustomGrid(cells, automata.cellTypeModel),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SelectableText(
                        '${seed ?? ''}',
                        style: const TextStyle(
                            color: Colors.teal, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CellPanel(
                      model: automata.cellTypeModel,
                      key: ValueKey(automata.cellTypeModel),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 600,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: const InputDecoration(
                            labelText: 'Сид (оставить пустым для случайного)'),
                        onChanged: (s) {
                          if (s != '') {
                            final sInt = int.tryParse(s);
                            if (sInt != null) {
                              seed = sInt;
                            } else {
                              seed = s.hashCode;
                            }
                          } else {
                            seed = null;
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.teal),
                              borderRadius: BorderRadius.circular(8.0)),
                          child: ListView(
                            controller: rulesListController,
                            children: tiles,
                          ),
                        ),
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
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.teal)),
                          onPressed: () {
                            final seed_ =
                                seed ?? Random().nextInt(pow(2, 32).toInt());
                            random.setSeed(seed_);

                            if (automata.collectData()) {
                              setState(() {
                                cells = List.generate(
                                    fieldWidth * fieldWidth, (_) => Cell(0));
                              });
                              stream = automata.makeStream(cells);
                              streamSubscription?.cancel();
                              streamSubscription = stream.listen((event) {
                                setState(() {
                                  cells = List.from(event);
                                  seed = seed_;
                                });
                              });
                            }
                          },
                          child: const Text('Запустить')),
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

  void loadTemplate(int i) {
    streamSubscription?.cancel();
    cells = List.generate(fieldWidth * fieldWidth, (_) => Cell(0));

    setState(() {
      automata = CellularAutomataModel.copy(templates[i]);
      tiles = generateTiles(automata);
    });
    rulesListController.jumpTo(rulesListController.position.minScrollExtent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      rulesListController.animateTo(
          rulesListController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn);
    });
  }

  void loadAutomaton(CellularAutomataModel automataModel) {
    streamSubscription?.cancel();
    cells = List.generate(fieldWidth * fieldWidth, (_) => Cell(0));

    setState(() {
      automata = CellularAutomataModel.copy(automataModel);
      tiles = generateTiles(automata);
    });
    rulesListController.jumpTo(rulesListController.position.minScrollExtent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      rulesListController.animateTo(
          rulesListController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn);
    });
  }

  void deleteRule(RuleTile ruleTile) {
    automata.deleteRule(ruleTile.model);
    setState(() {
      List<RuleTile> newTiles = [];
      for (var i = 0; i < tiles.length; i++) {
        if (tiles[i] != ruleTile) {
          newTiles.add(RuleTile(
              model: tiles[i].model,
              deleteFunction: deleteRule,
              index: newTiles.length + 1));
        }
      }
      tiles = List.from(newTiles);
      //List.from(tiles..remove(ruleTile));
    });
  }

  void addRule() {
    final r = RuleModel(1, [Condition.always(0.5, 0, 1)]);
    automata.addRule(r);
    setState(() {
      tiles = List.from(tiles
        ..add(RuleTile(
          index: tiles.length + 1,
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
