import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Driver.dart';
import '../models/DriverWithPoints.dart';
import '../models/RaceData.dart';
import '../models/Constructor.dart';

//we create a static class that holds the functions for our api service
class ApiService {
  static final apiBaseUrl = 'https://f1-backend-fylt.onrender.com';
  //because in flutter http requests are an asynchronised task, we need to return a Future object
  //the Future objects holds a list of Driver objects, because our api endpoint returns data for 3 drivers
  static Future<List<Driver>> fetchLastRaceTop3() async {
    //we also set the async keyword

    //observe the async await mechanism
    //http.get doesn't accept a string, instead we need to pass a Uri.parse(our api endpoint)
    final response = await http.get(
      Uri.parse('$apiBaseUrl/last_race/standings'),
    );

    //we check the status code of the request
    if (response.statusCode == 200) {
      //if the request went well
      final List data = jsonDecode(
        response.body,
      ); //we transform from json to a list

      //data is a List<Map <String, dynamic>>, because it it is a list that contains multiple json objects
      //like this:
      //[
      //   {"name": "Max Verstappen", "team": "Red Bull", "pos": 1},
      //   {"name": "Oscar Piastri", "team": "McLaren", "pos": 2},
      //   {"name": "Lando Norris", "team": "McLaren", "pos": 3}
      // ]

      //but our function returns Future <List<Driver>>
      //so we need to take every map from the list and convert it into a Driver object, using the method we wrote in Driver
      //to do this, we use the .map() method
      //we transform each "jsonMap" into a Driver object
      //also, at the end, we convert the result to a list using .toList()
      return data.map((jsonMap) => Driver.fromJson(jsonMap)).toList();
    } else {
      throw Exception("Failed to load last race standings");
    }
  }

  static Future<List<DriverWithPoints>> fetchStandingsTop3() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/championship/standings'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((jsonMap) => DriverWithPoints.fromJson(jsonMap)).toList();
    } else {
      throw Exception("Failed to load championship standings");
    }
  }

  static Future<RaceData> fetchLastRaceData() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/last_race/data'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return RaceData.fromJson(data);
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  static Future<RaceData> fetchNextRaceData() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/next_race/data'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return RaceData.fromJson(data);
    } else {
      throw Exception("Failed to load next race data");
    }
  }

  static Future<RaceData> fetchNextQualiData() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/next_quali/data'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return RaceData.fromJson(data);
    } else {
      throw Exception('Failed to load next quali data');
    }
  }

  static Future<List<Constructor>> fetchConstructorsStandings() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/championship/constructors/standings'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map((constructorJsonMap) => Constructor.fromJson(constructorJsonMap))
          .toList();
    } else {
      throw Exception("Failed to load constructors standings");
    }
  }
}
