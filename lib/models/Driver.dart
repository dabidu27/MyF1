//create a model class that matches the API response

class Driver {
  //make sure the name of the fields match the keys in the json response
  final String name;
  final String team;
  final String pos;

  const Driver({
    required this.name,
    required this.team,
    required this.pos,
  }); //flutter style constructor

  //mapping method: maps Json to our class
  factory Driver.fromJson(Map<String, dynamic> json) {
    //Map <String, dynamic> can hold our json data

    return Driver(name: json['name'], team: json['team'], pos: json['pos']);
  }
}
