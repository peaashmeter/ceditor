import 'cell.dart';
import 'utils.dart';

import 'serialize.dart';

enum ConditionType { always, near }

class Condition implements ISerializable {
  ConditionType conditionType;
  List<int> count;
  int nearType;
  int checkType;
  int newType;
  double chance;

  Condition(this.conditionType, this.count, this.checkType, this.nearType,
      this.newType, this.chance);
  Condition.always(this.chance, this.checkType, this.newType)
      : conditionType = ConditionType.always,
        count = [1, 2, 3],
        nearType = 0;
  Condition.near(
      this.count, this.nearType, this.checkType, this.newType, this.chance)
      : conditionType = ConditionType.near;

  Condition.fromJson(Map<String, dynamic> json)
      : conditionType = ConditionType.values[json['conditionType']],
        count = json['count'].cast<int>(),
        nearType = json['nearType'],
        checkType = json['checkType'],
        newType = json['newType'],
        chance = json['chance'];

  @override
  Map<String, dynamic> toJson() => {
        'conditionType': conditionType.index,
        'count': count,
        'nearType': nearType,
        'checkType': checkType,
        'newType': newType,
        'chance': chance,
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
        final r = random.rand.nextDouble();
        if ((c.conditionType == ConditionType.always ||
                cells[i].type == c.checkType) &&
            r < c.chance) {
          final l = c.count;
          final n = findNearby(i, cells, c.nearType);
          if (c.conditionType == ConditionType.always || l.contains(n)) {
            return Cell(c.newType);
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

  CellularAutomataModel()
      : rules = [],
        cellTypeModel = CellTypeModel();
  CellularAutomataModel.copy(CellularAutomataModel from)
      : rules = List.from(from.rules),
        cellTypeModel =
            CellTypeModel.colors(List.from(from.cellTypeModel.colors));

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
        await Future.delayed(const Duration(milliseconds: 50));
        yield newCells;
      }
    }
  }

  CellularAutomataModel.fromJson(Map<String, dynamic> json)
      : rules = List.generate(json['rules'].length,
            (index) => RuleModel.fromJson(json['rules'][index])),
        cellTypeModel = CellTypeModel.fromJson(json['cellTypeModel']);

  @override
  Map<String, dynamic> toJson() => {
        'rules': rules.map((e) => e.toJson()).toList(),
        'cellTypeModel': cellTypeModel.toJson(),
      };
}

class ConditionFunc {
  int checkType;
  Cell Function(int i, List<Cell> cells) function;

  ConditionFunc(this.checkType, this.function);
  Cell call(int i, List<Cell> cells) => function(i, cells);
}
