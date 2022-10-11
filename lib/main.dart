import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

const fieldWidth = 100;
const maxGenerations = 300;

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
  List<bool> states =
      List.generate(fieldWidth * fieldWidth, (index) => Random().nextBool());

  late Stream stream;
  late StreamSubscription sub;
  @override
  void initState() {
    stream = Stream.periodic(const Duration(milliseconds: 17));
    sub = stream.listen((event) {
      setState(() {
        states = nextState(states, gen);
        gen++;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (gen == maxGenerations) sub.pause();
    return MaterialApp(
      home: Scaffold(
        body: CustomPaint(
          painter: CustomGrid(states),
        ),
      ),
    );
  }
}

List<bool> nextState(List<bool> states, int generation) {
  List<bool> newStates = [];

  for (var i = 0; i < states.length; i++) {
    if (states[i]) {
      //жива
      const l = [3, 4, 6, 7, 8];
      final n = findLivingNeighbors(i, states);
      if (l.contains(n)) {
        newStates.add(true);
      } else {
        newStates.add(false);
      }
    } else {
      //мертва
      const l = [3, 6, 7, 8];
      final n = findLivingNeighbors(i, states);
      if (l.contains(n)) {
        newStates.add(true);
      } else {
        newStates.add(false);
      }
    }
  }
  return newStates;
}

int findLivingNeighbors(int index, List<bool> states) {
  List<int> indices = [];
  //верх
  indices.add(index - fieldWidth - 1);
  indices.add(index - fieldWidth);
  indices.add(index - fieldWidth + 1);
  //стороны
  indices.add(index - 1);
  indices.add(index + 1);
  //низ
  indices.add(index + fieldWidth - 1);
  indices.add(index + fieldWidth);
  indices.add(index + fieldWidth + 1);

  //удаление несуществующих
  indices.removeWhere((i) => i < 0 || i >= fieldWidth * fieldWidth);

  //Тороидальная форма
  // for (var i = 0; i < indices.length; i++) {
  //   if (indices[i] < 0) {
  //     indices[i] = fieldWidth * fieldWidth - indices[i];
  //   }
  //   if (indices[i] >= fieldWidth * fieldWidth) {
  //     indices[i] -= fieldWidth * fieldWidth;
  //   }
  // }

  int living = 0;
  for (var i in indices) {
    if (states[i]) living++;
  }
  return living;
}

class CustomGrid extends CustomPainter {
  static const cellWidth = 16.0;
  static const gap = 2;

  final List<bool> states;

  CustomGrid(this.states);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint deadPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.teal;
    final Paint alivePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.lightGreen;
    for (int i = 0; i < fieldWidth * fieldWidth; i++) {
      canvas.drawRect(
          Rect.fromLTWH((i % fieldWidth) * cellWidth / 2,
              (i ~/ fieldWidth) * cellWidth / 2, cellWidth, cellWidth),
          states[i] ? alivePaint : deadPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
