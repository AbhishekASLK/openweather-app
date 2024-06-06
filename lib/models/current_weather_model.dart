import 'dart:math';

class CurrentWeatherModel {
  int id;
  String city;
  String weatherType;
  String temp;
  String windSpeed;
  String humidity;
  String maxTemp;

  CurrentWeatherModel({
    required this.id,
    required this.city,
    required this.weatherType,
    required this.temp,
    required this.windSpeed,
    required this.humidity,
    required this.maxTemp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'city':city,
      'weatherType':weatherType,
      'temp':temp,
      'windSpeed':windSpeed,
      'humidity':humidity,
      'maxTemp':maxTemp,
    };
  }
}