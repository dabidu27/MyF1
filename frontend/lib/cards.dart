import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/DriverWithPoints.dart';

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

class StandingsCard extends StatefulWidget {
  final List<DriverWithPoints> standings;

  const StandingsCard({super.key, required this.standings});

  @override
  State<StandingsCard> createState() => _StandingsCardState();
}

class _StandingsCardState extends State<StandingsCard> {
  bool isExtended = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExtended = !isExtended;
        });
      },

      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: ListView(children: _buildStandings()),
      ),
    );
  }

  List<Widget> _buildStandings() {
    final standingsToShow = isExtended
        ? widget.standings
        : widget.standings.take(1);

    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Standings",
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          Icon(isExtended ? Icons.expand_less : Icons.expand_more),
        ],
      ),

      const SizedBox(height: 8),

      ...standingsToShow.map(
        (driver) => DriverTile(
          null,
          driver.name,
          driver.team,
          driver.pos,
          driver.points,
        ),
      ),
    ];
  }
}
