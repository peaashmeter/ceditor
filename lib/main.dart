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
import 'rendering.dart';
import 'template.dart';
import 'utils.dart';
import 'dart:ui' as ui;

const fieldWidth = 100;

void main() {
  if (kDebugMode) {
    print(":(");
  }

  random = SeededRandom();
  runApp(MaterialApp(
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
      home: const Editor()));
}

class Editor extends StatefulWidget {
  const Editor({super.key});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  int gen = 0;
  ValueNotifier<List<Cell>> cells =
      ValueNotifier(List.generate(fieldWidth * fieldWidth, (_) => Cell(0)));

  int? seed;
  int? displaySeed;

  late List<RuleTile> tiles;
  late Stream<List<Cell>> stream;
  StreamSubscription? streamSubscription;
  late ScrollController rulesListController;

  @override
  void initState() {
    automataModel = CellularAutomataModel()
      ..rules = [
        RuleModel(
          1,
          [
            Condition.always(0.5, 0, 1),
          ],
        ),
      ];
    tiles = generateTiles(automataModel);
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
        key: ValueKey(model.rules[i]),
      ));
    }
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
        body: Container(
            color: Colors.grey[900],
            child: horizontal ? horizontalView() : verticalView()));
  }

  Row horizontalView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        drawPanel(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 600,
            child: rulePanel(),
          ),
        ),
      ],
    );
  }

  Widget verticalView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        shrinkWrap: true,
        children: [
          drawPanel(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(width: 600, height: 600, child: rulePanel()),
          ),
        ],
      ),
    );
  }

  Column rulePanel() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                    onPressed: () {
                      showSettingsDialog();
                    },
                    icon: const Icon(Icons.settings_rounded)),
              )
            ],
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
                  backgroundColor: MaterialStatePropertyAll(Colors.teal)),
              onPressed: () {
                final seed_ = seed ?? Random().nextInt(pow(2, 32).toInt());
                random.setSeed(seed_);

                if (automataModel.collectData()) {
                  setState(() {
                    displaySeed = seed_;
                  });

                  cells.value =
                      List.generate(fieldWidth * fieldWidth, (_) => Cell(0));

                  stream = automataModel.makeStream(cells.value);
                  streamSubscription?.cancel();
                  streamSubscription = stream.listen((event) {
                    cells.value = List.from(event);
                  });
                }
              },
              child: const Text('Запустить')),
        )
      ],
    );
  }

  SizedBox drawPanel() {
    return SizedBox(
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
                      final json = jsonEncode(automataModel.toJson());
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
                          type: FileType.custom, allowedExtensions: ['json']);

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
              child: ValueListenableBuilder(
                valueListenable: cells,
                builder: (context, value, child) => FutureBuilder<ui.Image>(
                  future: makeGridImage(
                      generatePixels(cells.value, automataModel.cellTypeModel)),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return CustomPaint(painter: CustomGrid(snapshot.data!));
                    } else {
                      return const Placeholder();
                    }
                  },
                ),
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SelectableText(
                '${displaySeed ?? ''}',
                style: const TextStyle(
                    color: Colors.teal, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CellPanel(
              model: automataModel.cellTypeModel,
              key: ValueKey(automataModel.cellTypeModel),
            ),
          )
        ],
      ),
    );
  }

  Future showSettingsDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return SettingsDialog(
          automata: automataModel,
        );
      },
    );
  }

  void loadTemplate(int i) {
    streamSubscription?.cancel();
    cells.value = List.generate(fieldWidth * fieldWidth, (_) => Cell(0));

    automataModel = CellularAutomataModel.copy(templates[i]);
    setState(() {
      tiles = generateTiles(automataModel);
    });
    rulesListController.jumpTo(rulesListController.position.minScrollExtent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      rulesListController.animateTo(
          rulesListController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn);
    });
  }

  void loadAutomaton(CellularAutomataModel model) {
    streamSubscription?.cancel();
    cells.value = List.generate(fieldWidth * fieldWidth, (_) => Cell(0));

    automataModel = CellularAutomataModel.copy(model);
    setState(() {
      tiles = generateTiles(automataModel);
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
    automataModel.deleteRule(ruleTile.model);
    List<RuleTile> newTiles = [];

    for (int i = 0; i < automataModel.rules.length; i++) {
      newTiles.add(RuleTile(
          model: automataModel.rules[i],
          deleteFunction: deleteRule,
          index: newTiles.length + 1,
          key: ValueKey(automataModel.rules[i])));
      setState(() {
        tiles = List.from(newTiles);
      });
    }
  }

  void addRule() {
    final r = RuleModel(1, [Condition.always(0.5, 0, 1)]);
    automataModel.addRule(r);
    setState(() {
      tiles = List.from(tiles
        ..add(RuleTile(
          index: tiles.length + 1,
          model: r,
          deleteFunction: deleteRule,
          key: ValueKey(automataModel.rules[tiles.length]),
        )));
    });
  }
}

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key, required this.automata});

  final CellularAutomataModel automata;
  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool connectTopDown;
  late bool connectSides;

  @override
  void initState() {
    connectTopDown = automataModel.connectTopDown;
    connectSides = automataModel.connectSides;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Параметры'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
              title: const Text('Соединить по вертикали'),
              value: connectTopDown,
              onChanged: (value) {
                setState(() {
                  connectTopDown = value!;
                });
                automataModel.connectTopDown = value!;
              }),
          CheckboxListTile(
              title: const Text('Соединить по горизонтали'),
              value: connectSides,
              onChanged: (value) {
                setState(() {
                  connectSides = value!;
                });
                automataModel.connectSides = value!;
              }),
        ],
      ),
    );
  }
}
