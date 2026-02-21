import 'package:flutter/material.dart';
import 'models/DriverWithPoints.dart';
import 'models/Driver.dart';
import 'models/RaceData.dart';
import 'models/Constructor.dart';
import 'services/api_service.dart';
import 'services/url_launcher.dart';
import 'cards.dart';

void main() {
  runApp(const F1App());
}

class F1App extends StatelessWidget {
  const F1App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyF1',
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
  late Future<List<Constructor>> top3ConstructorsChampionshipFuture;
  late Future<RaceData> lastRaceData;
  late Future<RaceData> nextRaceData;
  late Future<RaceData> nextQualiData;

  @override
  void initState() {
    super.initState();
    top3Future = ApiService.fetchLastRaceTop3();
    top3ChampionshipFuture = ApiService.fetchStandingsTop3();
    lastRaceData = ApiService.fetchLastRaceData();
    nextRaceData = ApiService.fetchNextRaceData();
    nextQualiData = ApiService.fetchNextQualiData();
    top3ConstructorsChampionshipFuture =
        ApiService.fetchConstructorsStandings();
  }

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final PageController _pageController2 = PageController();
  int _currentPage2 = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Scaffold is a widget that provides the basic visual structure of the screen
      //it provides:
      //-appBar = top bar of the app
      appBar: AppBar(
        title: InkWell(
          onTap: UrlManager.openLink,
          child: Image.asset('assets/f1_logo.png', height: 40),
        ),
        centerTitle: true,
      ),
      //we added an image title with a clickable link in the app bar and we centered it
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
                  children: [
                    Text(
                      _currentPage2 == 0 ? "Next Race" : "Next Qualifying",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(
                      height: 120,
                      child: PageView(
                        controller: _pageController2,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage2 = index;
                          });
                        },

                        children: [
                          FutureBuilder<RaceData>(
                            future: nextRaceData,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Text("Error: ${snapshot.error}");
                              }

                              if (!snapshot.hasData) {
                                return Text("No data");
                              }

                              final raceData = snapshot.data!;

                              final raceDate = DateTime.parse(
                                raceData.dateComputations,
                              );
                              final now = DateTime.now();
                              final days = raceDate.difference(now).inDays;

                              final raceStartUTC = DateTime.parse(
                                "${raceData.dateComputations}T${raceData.timeComputations}Z",
                              );

                              final raceStartLocal = raceStartUTC
                                  .toLocal(); //conversion to local timezone is done client side (frontend), not server side (backend), because it depends on the user machine, not on the backend machine
                              final raceStartLocalPretty =
                                  "${raceStartLocal.hour.toString().padLeft(2, '0')}:"
                                  "${raceStartLocal.minute.toString().padLeft(2, '0')}";

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    raceData.name,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(raceData.datePretty),
                                  SizedBox(height: 8),
                                  Text(
                                    "Race starts in ${days} days",
                                    style: TextStyle(color: Colors.redAccent),
                                  ),

                                  Text(
                                    raceStartLocalPretty,
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ],
                              );
                            },
                          ),

                          FutureBuilder<RaceData>(
                            future: nextQualiData,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }

                              if (!snapshot.hasData) {
                                return Text("No data");
                              }

                              final qualiData = snapshot.data!;
                              final qualiDate = DateTime.parse(
                                qualiData.dateComputations,
                              );
                              final now = DateTime.now();

                              final days = qualiDate.difference(now).inDays;

                              final qualiStartUTC = DateTime.parse(
                                "${qualiData.dateComputations}T${qualiData.timeComputations}Z",
                              );

                              final qualiStartLocal = qualiStartUTC.toLocal();

                              final qualiStartLocalPretty =
                                  "${qualiStartLocal.hour.toString().padLeft(2, '0')}:"
                                  "${qualiStartLocal.minute.toString().padLeft(2, '0')}";

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    qualiData.name,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(qualiData.datePretty),
                                  SizedBox(height: 8),
                                  Text(
                                    "Qualifying starts in ${days} days",
                                    style: TextStyle(color: Colors.redAccent),
                                  ),

                                  Text(
                                    qualiStartLocalPretty,
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(2, (index) {
                        final bool isActive = _currentPage2 == index;
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 10 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.redAccent : Colors.grey,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Last Race",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),

                        Icon(Icons.chevron_right),
                      ],
                    ),

                    SizedBox(height: 8),
                    FutureBuilder<RaceData>(
                      future: lastRaceData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (!snapshot.hasData) {
                          return Text('No data');
                        }

                        final raceData = snapshot.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              raceData.name,
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(raceData.datePretty),
                          ],
                        );
                      },
                    ),

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

                        // return Column(
                        //   //drivers is a List<Driver> (it was wrapped in a Future object)
                        //   //so we need to convert each Driver object into a DriverTile card
                        //   //and also make it a list at the end because children: needs a list
                        //   children: drivers
                        //       .map(
                        //         (driver) => DriverTile(
                        //           null,
                        //           driver.name,
                        //           driver.team,
                        //           driver.pos,
                        //           null,
                        //         ),
                        //       )
                        //       .toList(),
                        // );

                        return LastRaceStandingsCard(standings: drivers);
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Standings",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Icon(Icons.chevron_right),
                      ],
                    ),

                    // DriverTile(
                    //   null,
                    //   "Max Verstappen",
                    //   "Red Bull",
                    //   "1",
                    // ), //null first because we pass no Key key argument
                    // DriverTile(null, "Lewis Hamilton", "Ferrari", "2"),
                    // DriverTile(null, "Lando Norris", "McLaren", "3"),
                    SizedBox(
                      height: 220,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        children: [
                          FutureBuilder<List<DriverWithPoints>>(
                            future: top3ChampionshipFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Text("Error: ${snapshot.error}");
                              }

                              if (!snapshot.hasData) {
                                return Text("No data");
                              }

                              final drivers = snapshot.data!;
                              return StandingsCard(standings: drivers);
                            },
                          ),

                          FutureBuilder<List<Constructor>>(
                            future: top3ConstructorsChampionshipFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Text("Error: ${snapshot.error}");
                              }

                              if (!snapshot.hasData) {
                                return Text("No data");
                              }

                              final constructors = snapshot.data!;

                              return StandingsConstructorsCard(
                                standings: constructors,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(2, (index) {
                        final bool isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 10 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.redAccent : Colors.grey,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
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
