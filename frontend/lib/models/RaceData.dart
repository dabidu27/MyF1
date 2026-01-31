class RaceData {
  final String name;
  final String date;

  const RaceData({required this.name, required this.date});

  factory RaceData.fromJson(Map<String, dynamic> json) {
    return RaceData(name: json['name'], date: json['date']);
  }
}
