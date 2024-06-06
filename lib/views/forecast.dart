import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:weather_application/main.dart';
import 'package:weather_application/models/constants.dart';

class Forecast extends StatefulWidget {
  const Forecast({super.key});

  @override
  State<Forecast> createState() => _ForecastState();
}

class _ForecastState extends State<Forecast> {
  String cityName = 'London';
  Image rainImage = Image.asset('assets/heavyrain.png', width: 30);
  Image cloudImage = Image.asset('assets/heavycloud.png', width: 30);
  Image clearImage = Image.asset('assets/clear.png', width: 30);
  List<List<Map<String,dynamic>>> nestedList = List.generate(5, (_) => List.generate(8,(_)=>{}));
  var data;
  @override
  void initState() {
    super.initState();
    checkInternetConnectivity();
  }

  checkInternetConnectivity()async{
    isInternet = await InternetConnection().hasInternetAccess;
    String? temp =  prefs!.getString('cityName');
    cityName = temp.toString();
    if(isInternet) {
      getForecast(cityName);
    }
  }

  Future getForecast(String cityName) async {
    await prefs!.setString('selectedCity', cityName);
    try {
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey',
        ),
      );
      data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'An unexpected error occurred!';
      }
      for(int i=0;i<data['list'].length;i++){
        int dayIndex = i~/8;
        int subIndex = i%8;
        nestedList[dayIndex][subIndex]=data['list'][i];
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build forecast');
    checkInternet();
    return (isInternet)?
    FutureBuilder(
        future: getForecast(cityName),
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
                const SizedBox(
                  width: 15,
                ),
              ],
            ),
            body: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: 5,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 246, 244, 244)
                          .withOpacity(0.9),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 1),
                          blurRadius: 5,
                          color: const Color.fromARGB(255, 244, 131, 131)
                              .withOpacity(0.5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            DateFormat('d MMM yyyy').format(DateTime.parse(nestedList[index][0]['dt_txt'])
                            ),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  width: 100,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: const Offset(0, 1),
                                        blurRadius: 5,
                                        color: primaryColor,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        nestedList[index][0]['main']['temp'].toString(),
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.white.withOpacity(0.8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 7,),
                                      (nestedList[index][0]['weather'][0]['main']=='Clouds')?cloudImage:(nestedList[index][0]['weather'][0]['main']=='Rain')?rainImage:clearImage,
                                      const SizedBox(height: 7,),
                                      Text(
                                          DateFormat('j').format(
                                              DateTime.parse(nestedList[index][0]['dt_txt'])
                                          ),
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.white.withOpacity(0.8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  width: 100,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: const Offset(0, 1),
                                          blurRadius: 5,
                                          color: primaryColor,
                                        ),
                                      ]),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        nestedList[index][1]['main']['temp'].toString(),
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.white.withOpacity(0.8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 7,),
                                      (nestedList[index][1]['weather'][0]['main']=='Clouds')?cloudImage:(nestedList[index][1]['weather'][0]['main']=='Rain')?rainImage:clearImage,
                                      const SizedBox(height: 7,),
                                      Text(
                                          DateFormat('j').format(
                                              DateTime.parse(nestedList[index][1]['dt_txt'])
                                          ),
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.white.withOpacity(0.8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  width: 100,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: const Offset(0, 1),
                                          blurRadius: 5,
                                          color: primaryColor,
                                        ),
                                      ]),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        nestedList[index][1]['main']['temp'].toString(),
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.white.withOpacity(0.8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 7,),
                                      (nestedList[index][2]['weather'][0]['main']=='Clouds')?cloudImage:(nestedList[index][2]['weather'][0]['main']=='Rain')?rainImage:clearImage,
                                      const SizedBox(height: 7,),
                                      Text(
                                          DateFormat('j').format(
                                              DateTime.parse(nestedList[index][2]['dt_txt'])
                                          ),
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.white.withOpacity(0.8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }): Center(
      child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('For forecast please check your internet connection'),
          IconButton(
              onPressed: ()async{
                if(await checkInternet()) {
                  setState(() {
                    isInternet = true;
                  });
                }
              },
              icon: const Icon(Icons.refresh,size: 30,)
          ),
        ],
      ) ,
    );
  }

  Future<bool> checkInternet()async{
    return await InternetConnection().hasInternetAccess;
  }
}
