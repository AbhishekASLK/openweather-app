import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weather_application/main.dart';
import 'package:weather_application/models/current_weather_model.dart';
import 'package:weather_application/models/constants.dart';
import 'package:weather_application/widgets/weather_item.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String cityName = 'London';
  var currentWeather;
  String weatherType = 'assets/lightcloud.png';
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    checkInternetConnectivity();
  }

  checkInternetConnectivity()async{
    isInternet = await InternetConnection().hasInternetAccess;
    String? temp =  prefs!.getString('cityName');
    cityName = temp.toString();
    if(isInternet){
      getCurrentWeather(cityName);
      // prefs!.setString('cityName', cityName);
    }
    else {
        localData = await getLocalData();
    }
  }

  Future<void> getCurrentWeather(String cityName) async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName&APPID=$openWeatherAPIKey',
        ),
      );
      currentWeather = jsonDecode(res.body);
      String weatherTemp = currentWeather['weather'][0]['main'];
      if(weatherTemp=='Clouds'){
          weatherType = 'assets/lightcloud.png';
      }
      else if(weatherType=='Rain'){
        weatherType = 'assets/heavyrain.png';
      }
      else {
        weatherType = 'assets/clear.png';
      }
      if (currentWeather['cod'] != 200) {
        throw 'An unexpected error occurred!';
      }
      // creating an object to store in local
      CurrentWeatherModel obj = CurrentWeatherModel(id: 1, city: currentWeather['name'], weatherType: currentWeather['weather'][0]['main'], temp: currentWeather['main']['temp'].toString(), windSpeed: currentWeather['wind']['speed'].toString(), humidity: currentWeather['main']['humidity'].toString(), maxTemp: currentWeather['main']['temp_max'].toString());
      // storing the data to sqflite
      await insertCurrentWeather(obj);
      await getLocalData();
    } catch (e) {
      throw e.toString();
    }
  }

  Future insertCurrentWeather(CurrentWeatherModel obj) async {
    final localDB = await database;
    await localDB.insert(
      'CurrentWeatherTable',
      obj.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String,dynamic>>> getLocalData() async {
    final localDB = await database;
    List<Map<String, dynamic>> listOfMap = await localDB.query('CurrentWeatherTable');
    return listOfMap;
  }

  @override
  Widget build(BuildContext context) {
    return (isInternet)?
    FutureBuilder(
      future: getCurrentWeather(cityName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                ),
              ),
            ),
          );
        }
        return Scaffold(
          resizeToAvoidBottomInset:false,
          backgroundColor: Colors.white,
          appBar: AppBar(
            titleSpacing: 0,
            title: const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Weather Forecast',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            actions: [
              Image.asset(
                'assets/pin.png',
                width: 20,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(currentWeather['name']),
              const SizedBox(
                width: 15,
              ),
              IconButton(
                onPressed:()async{
                  if(await checkInternet()){
                    setState(() {
                      isInternet = true;
                    });
                  }
                },
                icon:const Icon(Icons.refresh,size: 30,),),
              const SizedBox(width: 20,),
            ],
          ),
          body: SingleChildScrollView(
        child:
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50.0,
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (value)async {
                        cityName = value;
                        await prefs!.setString('cityName', value);
                        getCurrentWeather(cityName);
                        _searchController.clear();
                        setState((){});

                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: primaryColor.withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor: Colors.blue.withOpacity(0.2),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10.0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: primaryColor.withOpacity(0.5),
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: primaryColor.withOpacity(0.5),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  currentWeather['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.5),
                        offset: const Offset(0, 25),
                        blurRadius: 10,
                        spreadRadius: -12,
                      )
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -40,
                        left: 20,
                        child: Image.asset(
                          weatherType,
                          width: 150,
                        ),
                      ),
                      Positioned(
                        bottom: 30,
                        left: 20,
                        child: Text(
                          currentWeather['weather'][0]['main'],
                          style:const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 80,
                        right: 20,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                currentWeather['main']['temp'].toString(),
                                style: TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ),
                            Text(
                              'o',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WeatherItem(
                        text: 'Wind Speed',
                        value: currentWeather['wind']['speed'].toString(),
                        unit: ' km/h',
                        imageUrl: 'assets/windspeed.png',
                      ),
                      WeatherItem(
                          text: 'Humidity',
                          value: currentWeather['main']['humidity'].toString(),
                          unit: '',
                          imageUrl: 'assets/humidity.png'),
                      WeatherItem(
                        text: 'Max Temp',
                        value: currentWeather['main']['temp_max'].toString(),
                        unit: ' C',
                        imageUrl: 'assets/max-temp.png',
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),)
        );
      },
    ): (localData.length != 0)?Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'Weather Forecast',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          Image.asset(
            'assets/pin.png',
            width: 20,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(localData[0]['city']),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 50.0,
              child: TextField(
                controller: _searchController,
                onSubmitted: (value) {

                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: primaryColor.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: Colors.blue.withOpacity(0.2),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 10.0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: primaryColor.withOpacity(0.5),
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: primaryColor.withOpacity(0.5),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              localData[0]['city'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.5),
                    offset: const Offset(0, 25),
                    blurRadius: 10,
                    spreadRadius: -12,
                  )
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -40,
                    left: 20,
                    child: Image.asset(
                      weatherType,
                      width: 150,
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    child: Text(
                      localData[0]['temp'],
                      style:const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    right: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            localData[0]['temp'],
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                        Text(
                          'o',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WeatherItem(
                    text: 'Wind Speed',
                    value: localData[0]['windSpeed'],
                    unit: ' km/h',
                    imageUrl: 'assets/windspeed.png',
                  ),
                  WeatherItem(
                      text: 'Humidity',
                      value: localData[0]['humidity'],
                      unit: '',
                      imageUrl: 'assets/humidity.png'),
                  WeatherItem(
                    text: 'Max Temp',
                    value: localData[0]['maxTemp'],
                    unit: ' C',
                    imageUrl: 'assets/max-temp.png',
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    ): Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Please check your internet connection!'),
          const SizedBox(height: 10,),
          IconButton(
              onPressed:()async{
                if(await checkInternet()){
                  setState(() {
                    isInternet = true;
                  });
                }
              },
              icon:const Icon(Icons.refresh,size: 40,),
          )
        ],
      ),
    );
  }

  Future<bool> checkInternet()async{
    return await InternetConnection().hasInternetAccess;
  }
}
