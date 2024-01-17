//jcep - JSON CEditor Parser.
import 'package:flutter/material.dart';
import 'dart:convert';
import 'serialize.dart';

//Парсит в Json
String list2Json(List<ISerializable> objects) {
  final objMap = objects.map((e) => e.toJson()).toList();
  return jsonEncode(objMap);
}

List<int> colors2Int(List<Color> colors) {
  return colors.map((c) => c.value).toList();
}

List<Color> int2Colors(List<int> listInt) {
  return listInt.map((i) => Color(i)).toList();
}
