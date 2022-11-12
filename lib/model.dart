import 'cell.dart';
import 'utils.dart' as utils;

import 'serialize.dart';

enum ConditionType { always, near, at }

class Condition implements ISerializable {
  ConditionType conditionType;
  List<int>? count;
  List<int>? positions;
  int? nearType;
  int checkType;
  int newType;
  double chance;

  Condition(this.conditionType, this.count, this.checkType, this.nearType,
      this.newType, this.chance, this.positions);
  Condition.always(this.chance, this.checkType, this.newType)
      : conditionType = ConditionType.always;

  Condition.near(
      this.count, this.nearType, this.checkType, this.newType, this.chance)
      : conditionType = ConditionType.near;
  Condition.at(
      this.positions, this.nearType, this.checkType, this.newType, this.chance)
      : conditionType = ConditionType.at;
  Condition.fromJson(Map<String, dynamic> json)
      : conditionType = ConditionType.values[json['conditionType']],
        count = (json['count'] ?? []).cast<int>(),
        nearType = json['nearType'],
        checkType = json['checkType'],
        newType = json['newType'],
        chance = json['chance'],
        positions = (json['positions'] ?? []).cast<int>();

  @override
  Map<String, dynamic> toJson() => {
        'conditionType': conditionType.index,
        'count': count,
        'nearType': nearType,
        'checkType': checkType,
        'newType': newType,
        'chance': chance,
        'positions': positions
      };
}

class RuleModel implements ISerializable {
  bool Function()? collectData;
  int times;

  List<Condition> conditions;
  RuleModel(this.times, this.conditions);

  List<Cell> Function(List<Cell>) makeFunction(List<Cell> cells) {
    List<ConditionFunc> cfs = [];
    for (var c in conditions) {
      cfs.add(ConditionFunc(c.checkType, (int i, List<Cell> cells) {
        final r = utils.random.rand.nextDouble();

        if (r < c.chance) {
          switch (c.conditionType) {
            case ConditionType.always:
              return Cell(c.newType);
            case ConditionType.near:
              final n = utils.findNearby(
                  i,
                  cells,
                  c.nearType ?? 0,
                  utils.automataModel.connectSides,
                  utils.automataModel.connectTopDown);
              if (c.count?.contains(n) ?? false) {
                return Cell(c.newType);
              }
              return Cell(cells[i].type);
            case ConditionType.at:
              final atPos = utils.checkIfAtPos(
                  i,
                  c.positions ?? [],
                  cells,
                  c.nearType ?? 0,
                  utils.automataModel.connectSides,
                  utils.automataModel.connectTopDown);
              if (atPos) {
                return Cell(c.newType);
              }
              return Cell(cells[i].type);
            default:
          }
        }

        return Cell(cells[i].type);
      }));
    }

    List<Cell> f(List<Cell> cells) {
      List<Cell> newCells_ = [];
      for (var i = 0; i < cells.length; i++) {
        var type = cells[i].type;
        var newCell = Cell(type);
        for (var func in cfs.where((f) => f.checkType == type)) {
          newCell = func(i, cells);
          if (newCell.type != type) break;
        }
        newCells_.add(newCell);
      }
      return newCells_;
    }

    return f;
  }

  RuleModel.fromJson(Map<String, dynamic> json)
      : times = json['times'],
        conditions = List.generate(json['conditions'].length,
            (index) => Condition.fromJson(json['conditions'][index]));

  @override
  Map<String, dynamic> toJson() => {
        'times': times,
        'conditions': conditions.map((e) => e.toJson()).toList(),
      };
}

///Определяем клеточный автомат как набор последовательных правил, применямых к
///клеткам указанных типов
class CellularAutomataModel implements ISerializable {
  late List<RuleModel> rules;
  late CellTypeModel cellTypeModel;
  bool connectSides = true;
  bool connectTopDown = true;

  CellularAutomataModel()
      : rules = [],
        cellTypeModel = CellTypeModel();
  CellularAutomataModel.copy(CellularAutomataModel from)
      : rules = List.from(from.rules),
        cellTypeModel =
            CellTypeModel.colors(List.from(from.cellTypeModel.colors)),
        connectSides = from.connectSides,
        connectTopDown = from.connectTopDown;

  void addRule(RuleModel r) {
    rules.add(r);
  }

  void deleteRule(RuleModel r) {
    rules.remove(r);
  }

  bool collectData() {
    for (var rule in rules) {
      if (!(rule.collectData?.call() ?? false)) {
        return false;
      }
    }
    return true;
  }

  Stream<List<Cell>> makeStream(List<Cell> cells) async* {
    List<Cell> newCells = List.from(cells);
    for (var rule in rules) {
      for (int t = 0; t < rule.times; t++) {
        final f = rule.makeFunction(newCells);
        newCells = f(newCells);
        await Future.delayed(const Duration(milliseconds: 30));
        yield newCells;
      }
    }
  }

  CellularAutomataModel.fromJson(Map<String, dynamic> json)
      : rules = List.generate(json['rules'].length,
            (index) => RuleModel.fromJson(json['rules'][index])),
        cellTypeModel = CellTypeModel.fromJson(json['cellTypeModel']),
        connectSides = json['connectSides'] ?? true,
        connectTopDown = json['connectTopDown'] ?? true;

  @override
  Map<String, dynamic> toJson() => {
        'rules': rules.map((e) => e.toJson()).toList(),
        'cellTypeModel': cellTypeModel.toJson(),
        'connectSides': connectSides,
        'connectTopDown': connectTopDown
      };
}

class ConditionFunc {
  int checkType;
  Cell Function(int i, List<Cell> cells) function;

  ConditionFunc(this.checkType, this.function);
  Cell call(int i, List<Cell> cells) => function(i, cells);
}
