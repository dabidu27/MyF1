import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/DriverWithPoints.dart';
import 'models/Driver.dart';
import 'services/api_service.dart';

void main() {
  runApp(const F1App());
}

class F1App extends StatelessWidget {
  const F1App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F1 Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  //flutter style constructor that calls the constructor of the base class (StatefulWidget)
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Driver>> top3Future;
  late Future<List<DriverWithPoints>> top3ChampionshipFuture;

  @override
  void initState() {
    super.initState();
    top3Future = ApiService.fetchLastRaceTop3();
    top3ChampionshipFuture = ApiService.fetchStandingsTop3();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Scaffold is a widget that provides the basic visual structure of the screen
      //it provides:
      //-appBar = top bar of the app
      appBar: AppBar(
        title: Text("F1 App"),
        centerTitle: true,
      ), //we added a text title in the app bar and we centered it
      //-a body = main content of the app
      body: Padding(
        //every element wrapped in a Padding() will have padding space around it
        padding: const EdgeInsets.all(16.0), //we set the padding space size
        child: ListView(
          //inside the body (child), we add a Column widget, which stacks the widgets inside from top to bottom
          //i replaced it with ListView because ListView is scrollable
          children: [
            //we have children because inside the Column widget we add MULTIPLE WIDGETS
            // NEXT RACE CARD
            Card(
              //we add a card
              shape: RoundedRectangleBorder(
                //we define the shape of the card
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                //Another Padding widget inside the card for the text of the card
                padding: const EdgeInsets.all(16),
                child: Column(
                  //and inside this we add a Column widget, to stack the card text from top to bottom
                  crossAxisAlignment: CrossAxisAlignment.start, //In a Column:
                  // Main axis = vertical (top → bottom)
                  // Cross axis = horizontal (left ↔ right)

                  //crossAxisAlignment.start = allign children to the left
                  children: const [
                    Text(
                      "Next Race",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(
                      height: 8,
                    ), //this defines an empty box, so we basically put an empty space
                    Text(
                      "Bahrain Grand Prix",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text("02 March 2026"),
                    SizedBox(height: 8),
                    Text(
                      "Race starts in 5 days",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Last Race",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Abu Dhabi Grand Prix",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text("07 December 2025"),

                    // // Column(
                    // //   children: [
                    // //     // DriverTile(null, "Max Verstappen", "Red Bull", "1"),
                    // //     // DriverTile(null, "Oscar Piastri", "McLaren", "2"),
                    // //     // DriverTile(null, "Lando Norris", "McLaren", "3"),
                    // //   ],
                    // ),
                    SizedBox(height: 12),
                    FutureBuilder<List<Driver>>(
                      future: top3Future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        }

                        if (!snapshot.hasData) {
                          return Text("No data");
                        }

                        final drivers = snapshot
                            .data!; //! is a null check, so the map method knows we don t parse null data

                        return Column(
                          //drivers is a List<Driver> (it was wrapped in a Future object)
                          //so we need to convert each Driver object into a DriverTile card
                          //and also make it a list at the end because children: needs a list
                          children: drivers
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
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
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

                    // DriverTile(
                    //   null,
                    //   "Max Verstappen",
                    //   "Red Bull",
                    //   "1",
                    // ), //null first because we pass no Key key argument
                    // DriverTile(null, "Lewis Hamilton", "Ferrari", "2"),
                    // DriverTile(null, "Lando Norris", "McLaren", "3"),
                    FutureBuilder<List<DriverWithPoints>>(
                      future: top3ChampionshipFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        }

                        if (!snapshot.hasData) {
                          return Text("No data");
                        }

                        final drivers = snapshot.data!;
                        return Column(
                          children: drivers
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
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // TOP 3 DRIVERS
            // const Align(
            //   //we use an Align widget to Align this text
            //   alignment: Alignment.centerLeft,
            //   child: Text(
            //     "Top 3 Drivers",
            //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //   ),
            // ),

            // const SizedBox(height: 8),

            // Expanded(
            //   //Expanded widget makes it that what we add here takes up all remaining vertical space
            //   child: ListView(
            //     //ListView is like a Column widget (stacks widgets from top to bottom), but it is also scrollable
            //     children: const [
            //       //and inside the ListView we add our DriverTile widgets (classes) we defined bellow
            //       DriverTile(
            //         null,
            //         "Max Verstappen",
            //         "Red Bull",
            //         "1",
            //       ), //null first because we pass no Key key argument
            //       DriverTile(null, "Lewis Hamilton", "Ferrari", "2"),
            //       DriverTile(null, "Lando Norris", "McLaren", "3"),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

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
