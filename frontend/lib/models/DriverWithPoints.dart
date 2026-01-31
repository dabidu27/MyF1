class DriverWithPoints {
  final String name;
  final String team;
  final String pos;
  final String points;

  const DriverWithPoints({
    required this.name,
    required this.team,
    required this.pos,
    required this.points,
  });

  factory DriverWithPoints.fromJson(Map<String, dynamic> json) {
    return DriverWithPoints(
      name: json['name'],
      team: json['team'],
      pos: json['pos'],
      points: json['points'],
    );
  }
}
