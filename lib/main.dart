import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weather_application/views/connector.dart';

SharedPreferences? prefs;
dynamic database;
bool isInternet = true;
var localData;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  isInternet = await InternetConnection().hasInternetAccess;
  // =================== SETUP ======================
  database = await openDatabase(
    join(await getDatabasesPath(), 'weather_database105.db'),
    onCreate: (db, version) async {
      return await db.execute(
        "CREATE TABLE CurrentWeatherTable(id INTEGER PRIMARY KEY, city TEXT,weatherType TEXT,temp TEXT, windSpeed TEXT,humidity TEXT,maxSpeed TEXT,maxTemp TEXT)",
      );
    },
    version: 1,
  );
  localData = await getLocalData();
  runApp(const MyApp());
}

Future<List<Map<String,dynamic>>> getLocalData() async {
  final localDB = await database;
  List<Map<String, dynamic>> listOfMap = await localDB.query('CurrentWeatherTable');
  print(listOfMap);
  return listOfMap;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      home: Connector(),
    );
  }
}
