import 'package:flutter/foundation.dart';

class Constructor {
  final String name;
  final String points;
  final String pos;

  const Constructor({
    required this.name,
    required this.points,
    required this.pos,
  });

  factory Constructor.fromJson(Map<String, dynamic> json) {
    return Constructor(
      name: json['name'],
      points: json['points'],
      pos: json['pos'],
    );
  }
}
