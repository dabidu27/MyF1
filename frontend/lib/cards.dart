import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/Constructor.dart';
import 'package:flutter_application_1/models/Driver.dart';
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

class StandingsCard extends StatelessWidget {
  final List<DriverWithPoints> standings;

  const StandingsCard({super.key, required this.standings});

  @override
  Widget build(BuildContext context) {
    final preview = standings.take(3).toList();
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return FullStandingsScreen(standings: standings);
            },
          ),
        );
      },

      child: Column(
        children: preview
            .map(
              (driver) => Expanded(
                child: DriverTile(
                  null,
                  driver.name,
                  driver.team,
                  driver.pos,
                  driver.points,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class FullStandingsScreen extends StatelessWidget {
  final List<DriverWithPoints> standings;

  const FullStandingsScreen({super.key, required this.standings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Standings",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: ListView(
                    children: standings
                        .map(
                          (driver) => DriverTile(
                            null,
                            driver.name,
                            driver.team,
                            driver.pos,
                            driver.points,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StandingsConstructorsCard extends StatelessWidget {
  final List<Constructor> standings;

  const StandingsConstructorsCard({super.key, required this.standings});

  @override
  Widget build(BuildContext context) {
    final preview = standings.take(3).toList();
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return FullConstuctorsStandingsScreen(standings: standings);
            },
          ),
        );
      },

      child: Column(
        children: preview
            .map(
              (team) => Expanded(
                child: ConstructorTile(
                  teamName: team.name,
                  points: team.points,
                  pos: team.pos,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class FullConstuctorsStandingsScreen extends StatelessWidget {
  final List<Constructor> standings;
  const FullConstuctorsStandingsScreen({super.key, required this.standings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: Padding(
        padding: EdgeInsets.all(16),

        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Standings",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: ListView(
                    children: standings
                        .map(
                          (team) => ConstructorTile(
                            teamName: team.name,
                            points: team.points,
                            pos: team.pos,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LastRaceStandingsCard extends StatelessWidget {
  final List<Driver> standings;

  const LastRaceStandingsCard({super.key, required this.standings});

  @override
  Widget build(BuildContext context) {
    final preview = standings.take(3).toList();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return FullLastRaceStandingsCard(standings: standings);
            },
          ),
        );
      },

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: preview
            .map(
              (driver) =>
                  DriverTile(null, driver.name, driver.team, driver.pos, null),
            )
            .toList(),
      ),
    );
  }
}

class FullLastRaceStandingsCard extends StatelessWidget {
  final List<Driver> standings;

  const FullLastRaceStandingsCard({super.key, required this.standings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Standings",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: ListView(
                    children: standings
                        .map(
                          (driver) => DriverTile(
                            null,
                            driver.name,
                            driver.team,
                            driver.pos,
                            null,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
