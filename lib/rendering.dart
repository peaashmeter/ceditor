import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:ceditor/model.dart';
import 'package:flutter/rendering.dart';

import 'cell.dart';
import 'main.dart';

const cellWidth = 4;

class CustomGrid extends CustomPainter {
  final Image image;

  CustomGrid(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    canvas.scale(4);
    canvas.drawImage(image, Offset.zero, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

Uint8List generatePixels(List<Cell> cells, CellTypeModel model) {
  final list = Uint8List(fieldWidth * fieldWidth * cellWidth * cellWidth * 4);

  //построчное рисование сетки сверху вниз, слева направо
  for (var y = 0; y < fieldWidth; y++) {
    for (var x = 0; x < fieldWidth; x++) {
      //номер клетки, которая рисуется в данный момент
      final index = y * fieldWidth + x;

      final color = model.getColor(cells[index].type);

      //номер набора из четырех байтов в списке
      final pIndex = y * fieldWidth + x;

      list[pIndex * 4 + 0] = color.red;
      list[pIndex * 4 + 1] = color.green;
      list[pIndex * 4 + 2] = color.blue;
      list[pIndex * 4 + 3] = color.alpha;
    }
  }
  return list;
}

Future<Image>? makeGridImage(Uint8List pixels) {
  final Completer<Image> c = Completer();

  decodeImageFromPixels(pixels, fieldWidth, fieldWidth, PixelFormat.rgba8888,
      (img) {
    c.complete(img);
  });

  return c.future;
}
