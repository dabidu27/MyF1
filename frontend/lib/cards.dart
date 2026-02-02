import 'package:flutter/material.dart';

class DriverTile extends StatelessWidget {
  //class DriverTile inherits from StatelessWidget, this class becomes a reusable Widget
  //class attributes
  final String driverName; //final is like a const in c++
  final String team;
  final String pos;
  final String? points; //? means that this value may be null

  //constructor
  const DriverTile(
    Key? key,
    String driverName,
    String team,
    String pos,
    String? points,
  ) //Key? key means that a key attribute is OPTIONAL (because of ?) to pass
  : //because we have final attributes, we have to use the initializer list for initialization
      driverName = driverName,
      team = team,
      pos = pos,
      points = points,
      super(key: key); //this is a call to the base class constructor

  @override
  Widget build(BuildContext context) {
    //BuildContext context is pass to Widget methods for FLutter to know the hierarchy of widgets

    return Card(
      //Card is a predefined visual container with rounded corners
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        //child means this is inside the Card
        //ListTile is a prebuild row layout format with: leading text - the circle in our case, title, subtitle, trailing text and onTap which is a click handler
        leading: CircleAvatar(
          backgroundColor: Colors.redAccent,
          child: Text(this.pos), //the text is inside the circle
        ),
        title: Text(this.driverName),
        subtitle: Text(this.team),
        trailing: points != null
            ? Text(this.points!, style: TextStyle(fontSize: 16))
            : null, //this is a conditional statement
        //if points != null render Text(this.points!) and we use the ! to say "hey this is surely not null"
        //if points == null render nothing
      ),
    );
  }
}

class ConstructorTile extends StatelessWidget {
  final String teamName;
  final String points;
  final String pos;

  const ConstructorTile({
    required this.teamName,
    required this.points,
    required this.pos,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.redAccent,
          child: Text(this.pos), //the text is inside the circle
        ),
        title: Text(this.teamName),
        trailing: Text(this.points, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
