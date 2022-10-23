import 'package:worldgen/cell.dart';
import 'package:worldgen/utils.dart';

enum ConditionType { always, near }

class Condition {
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
}

class RuleModel {
  bool Function()? collectData;
  int times;
  List<Condition> conditions;
  RuleModel(this.times, this.conditions);

  List<Cell> Function(List<Cell>) makeFunction(List<Cell> cells) {
    Map<int, Function> cfs = {};
    for (var c in conditions) {
      cfs[c.checkType] = (int i, List<Cell> cells) {
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
      };
    }

    List<Cell> f(List<Cell> cells) {
      List<Cell> newCells_ = [];
      for (var i = 0; i < cells.length; i++) {
        var type = cells[i].type;
        if (cfs[type] == null) {
          newCells_.add(Cell(type));
        } else {
          newCells_.add(cfs[type]!(i, cells));
        }
      }
      return newCells_;
    }

    return f;
  }
}

///Определяем клеточный автомат как набор последовательных правил, применямых к
///клеткам указанных типов
class CellularAutomataModel {
  List<RuleModel> rules = [];
  CellTypeModel cellTypeModel = CellTypeModel();

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
}
