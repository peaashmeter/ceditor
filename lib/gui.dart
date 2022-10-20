import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:worldgen/cell.dart';
import 'package:worldgen/model.dart';

class RuleTile extends StatefulWidget {
  final int index;
  final RuleModel model;
  final void Function(RuleTile) deleteFunction;
  const RuleTile(
      {super.key,
      required this.model,
      required this.deleteFunction,
      required this.index});

  @override
  State<RuleTile> createState() => _RuleTileState();
}

class _RuleTileState extends State<RuleTile> {
  late Map<Condition, List<TextEditingController>> data;
  late TextEditingController timesController;

  @override
  void initState() {
    data = Map.fromIterables(
        List.from(widget.model.conditions), initTextControllers());
    timesController =
        TextEditingController(text: widget.model.times.toString());

    widget.model.collectData = collectData;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(8.0),
        elevation: 2,
        color: Colors.grey[800],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '${widget.index}. Выполнить ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            width: 60,
                            child: TextField(
                              controller: timesController,
                            )),
                      ),
                      const Text(' раз:'),
                    ],
                  ),
                  IconButton(
                      onPressed: () {
                        widget.deleteFunction(widget);
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.purpleAccent,
                      ))
                ],
              ),
              ...generateConditions(),
              IconButton(
                onPressed: () {
                  setState(() {
                    data.addAll({
                      Condition.always(0.5, 0, 1):
                          List.generate(5, (index) => TextEditingController())
                    });
                  });
                },
                icon: const Icon(Icons.add_rounded),
                color: Colors.teal,
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> generateConditions() {
    List<Widget> c = [];
    for (var i = 0; i < data.keys.length; i++) {
      c.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          color: Colors.grey[700],
          elevation: 2,
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Условие: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'для клетки типа ',
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IntrinsicWidth(
                              child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                      minWidth: 60, maxWidth: 120),
                                  child: TextField(
                                    controller: data.values.elementAt(i)[0],
                                  )),
                            ),
                          ),
                          ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 80),
                              child: DropdownButton<ConditionType>(
                                  value: data.keys.elementAt(i).conditionType,
                                  items: const <
                                      DropdownMenuItem<ConditionType>>[
                                    DropdownMenuItem(
                                      value: ConditionType.always,
                                      child: Text('всегда'),
                                    ),
                                    DropdownMenuItem(
                                        value: ConditionType.near,
                                        child: Text('рядом'))
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      data.keys.elementAt(i).conditionType =
                                          value!;
                                    });
                                  })),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            data =
                                Map.from(data..remove(data.keys.elementAt(i)));
                          });
                        },
                        icon: const Icon(Icons.remove_rounded),
                        color: Colors.purpleAccent,
                      )
                    ],
                  ),
                ),
                if (data.keys.elementAt(i).conditionType == ConditionType.near)
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IntrinsicWidth(
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  minWidth: 60, maxWidth: 120),
                              child: TextField(
                                controller: data.values.elementAt(i)[1],
                              )),
                        ),
                      ),
                      const Text(' клеток типа '),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IntrinsicWidth(
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  minWidth: 60, maxWidth: 120),
                              child: TextField(
                                  controller: data.values.elementAt(i)[2])),
                        ),
                      ),
                    ],
                  ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Text(
                          'Изменить ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text('состояние клетки на '),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IntrinsicWidth(
                            child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                    minWidth: 60, maxWidth: 60),
                                child: TextField(
                                    controller: data.values.elementAt(i)[3])),
                          ),
                        ),
                        const Text('с вероятностью '),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IntrinsicWidth(
                            child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                    minWidth: 60, maxWidth: 60),
                                child: TextField(
                                    controller: data.values.elementAt(i)[4])),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ));
    }
    return c;
  }

  List<List<TextEditingController>> initTextControllers() {
    List<List<TextEditingController>> controllers = [];
    for (int i = 0; i < widget.model.conditions.length; i++) {
      controllers.add([]);
      controllers[i].add(TextEditingController(
          text: widget.model.conditions[i].checkType.toString()));
      controllers[i].add(TextEditingController(
          text: widget.model.conditions[i].count
              .toString()
              .replaceAll(RegExp(r'\[|\]'), '')));
      controllers[i].add(TextEditingController(
          text: widget.model.conditions[i].nearType.toString()));
      controllers[i].add(TextEditingController(
          text: widget.model.conditions[i].newType.toString()));
      controllers[i].add(TextEditingController(
          text: widget.model.conditions[i].chance.toString()));
    }
    return controllers;
  }

  bool collectData() {
    try {
      widget.model.times = int.parse(timesController.text);
      widget.model.conditions = [];
      for (var e in data.entries) {
        var conditionType = e.key.conditionType;
        var count = <int>[];
        var checkType = int.parse(e.value[0].text);
        int? nearType;
        if (conditionType == ConditionType.near) {
          for (var i in e.value[1].text.split(',')) {
            count.add(int.parse(i));
          }
          nearType = int.parse(e.value[2].text);
        }

        var newType = int.parse(e.value[3].text);
        var chance = double.parse(e.value[4].text);
        widget.model.conditions.add(Condition(
            conditionType, count, checkType, nearType ?? 0, newType, chance));
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}

class CellPanel extends StatefulWidget {
  final CellTypeModel model;
  const CellPanel({super.key, required this.model});

  @override
  State<CellPanel> createState() => _CellPanelState();
}

class _CellPanelState extends State<CellPanel> {
  late List<Color> colors;
  @override
  void initState() {
    colors = widget.model.colors;
    widget.model.addListener(() {
      setState(() {
        colors = widget.model.colors;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(children: [
      ...List.generate(
          colors.length,
          (index) => CellChip(
                index: index,
                color: colors[index],
                model: widget.model,
              )),
      IconButton(
          onPressed: () {
            widget.model.addColor();
          },
          icon: const Icon(Icons.add_rounded))
    ]);
  }
}

class CellChip extends StatefulWidget {
  final int index;
  final Color color;
  final CellTypeModel model;
  const CellChip(
      {super.key,
      required this.index,
      required this.color,
      required this.model});

  @override
  State<CellChip> createState() => _CellChipState();
}

class _CellChipState extends State<CellChip> {
  late TextEditingController hexController;
  Color? newColor;

  @override
  void initState() {
    hexController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InputChip(
        label: Text('${widget.index}'),
        avatar: CircleAvatar(
          backgroundColor: widget.color,
          radius: 8,
        ),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            scrollable: true,
            title: Text('Цвет для клетки ${widget.index}'),
            actions: [
              TextButton.icon(
                  onPressed: () {
                    if (newColor != null) {
                      widget.model.setColor(widget.index, newColor!);
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.done_rounded),
                  label: const Text('Применить'))
            ],
            content: Column(
              children: [
                ColorPicker(
                    hexInputController: hexController,
                    pickerColor: widget.color,
                    onColorChanged: (c) => newColor = c),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text('Hex: #'),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: hexController,
                            inputFormatters: [
                              UpperCaseTextFormatter(),
                              FilteringTextInputFormatter.allow(
                                  RegExp(kValidHexPattern)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        onDeleted: widget.model.colors.length > 2 ? delete : null,
      ),
    );
  }

  void delete() {
    widget.model.removeColor(widget.index);
  }
}
