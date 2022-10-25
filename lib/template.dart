import 'package:flutter/material.dart';
import 'cell.dart';
import 'model.dart';

final List<CellularAutomataModel> templates = [
  CellularAutomataModel()
    ..rules = [
      RuleModel(1, [Condition.always(0.5, 0, 1)]),
      RuleModel(200, [
        Condition.near([3], 1, 0, 1, 1),
        Condition.near([0, 1, 2, 3, 4, 7, 8], 0, 1, 0, 1)
      ])
    ],
  CellularAutomataModel()
    ..rules = [
      RuleModel(1, [Condition.always(0.5, 0, 1)]),
      RuleModel(200, [
        Condition.near([3, 6, 7, 8], 1, 0, 1, 1),
        Condition.near([3, 6, 7, 8], 0, 1, 0, 1)
      ])
    ]
    ..cellTypeModel = CellTypeModel.colors([Colors.black, Colors.amber]),
  CellularAutomataModel()
    ..rules = [
      RuleModel(1, [Condition.always(0.5, 0, 1)]),
      RuleModel(200, [
        Condition.near([3, 6, 7, 8], 1, 0, 1, 1),
        Condition.near([3, 6, 7, 8], 0, 1, 0, 1),
      ]),
      RuleModel(100, [
        Condition.near([1, 2, 3, 4, 5, 6, 7, 8], 0, 1, 2, 1),
        Condition.near([5, 6, 7, 8], 2, 0, 2, 0.02)
      ]),
      RuleModel(1, [
        Condition.near([1, 2, 3, 4, 5, 6, 7, 8], 2, 0, 3, 1)
      ]),
      RuleModel(100, [
        Condition.near([4, 5, 6, 7, 8], 3, 0, 3, 0.04)
      ]),
      RuleModel(1, [Condition.always(0.5, 1, 4)]),
      RuleModel(200, [
        Condition.near([3, 6, 7, 8], 4, 1, 4, 1),
        Condition.near([3, 6, 7, 8], 1, 4, 1, 1),
      ])
    ]
    ..cellTypeModel = CellTypeModel.colors([
      Colors.blue,
      Colors.lightGreen,
      Colors.yellow,
      Colors.cyan,
      Colors.lightGreen[800]!
    ])
];
