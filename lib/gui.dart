import 'package:flutter/material.dart';
import 'package:worldgen/model.dart';

class RuleTile extends StatefulWidget {
  final RuleModel model;
  final void Function(RuleTile) deleteFunction;
  const RuleTile(
      {super.key, required this.model, required this.deleteFunction});

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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 500),
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Выполнить ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                        width: 40,
                        child: TextField(
                          controller: timesController,
                        )),
                    const Text(' раз:'),
                    IconButton(
                        onPressed: () {
                          widget.deleteFunction(widget);
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ))
                  ],
                ),
                ...generateConditions(),
                IconButton(
                    onPressed: () {
                      setState(() {
                        data.addAll({
                          Condition.always(0.5, 0, 1): List.generate(
                              5, (index) => TextEditingController())
                        });
                      });
                    },
                    icon: const Icon(Icons.add_rounded))
              ],
            )),
          ),
        ),
      ),
    );
  }

  List<Widget> generateConditions() {
    List<Widget> c = [];
    for (var i = 0; i < data.keys.length; i++) {
      c.add(Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Column(
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
                IntrinsicWidth(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 20),
                      child: TextField(
                        controller: data.values.elementAt(i)[0],
                      )),
                ),
                ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 80),
                    child: DropdownButton<ConditionType>(
                        value: data.keys.elementAt(i).conditionType,
                        items: const <DropdownMenuItem<ConditionType>>[
                          DropdownMenuItem(
                            value: ConditionType.always,
                            child: Text('всегда'),
                          ),
                          DropdownMenuItem(
                              value: ConditionType.near, child: Text('рядом'))
                        ],
                        onChanged: (value) {
                          setState(() {
                            data.keys.elementAt(i).conditionType = value!;
                          });
                        })),
                if (data.keys.elementAt(i).conditionType == ConditionType.near)
                  Row(
                    children: [
                      IntrinsicWidth(
                        child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 20),
                            child: TextField(
                              controller: data.values.elementAt(i)[1],
                            )),
                      ),
                      const Text(' клеток типа '),
                      IntrinsicWidth(
                        child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 20),
                            child: TextField(
                                controller: data.values.elementAt(i)[2])),
                      ),
                    ],
                  ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        data = Map.from(data..remove(data.keys.elementAt(i)));
                      });
                    },
                    icon: const Icon(Icons.remove_rounded))
              ],
            ),
            Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    const Text(
                      'Изменить ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('состояние клетки на '),
                    IntrinsicWidth(
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 20),
                          child: TextField(
                              controller: data.values.elementAt(i)[3])),
                    ),
                    const Text('с вероятностью '),
                    IntrinsicWidth(
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 20),
                          child: TextField(
                              controller: data.values.elementAt(i)[4])),
                    ),
                  ],
                )),
          ],
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
