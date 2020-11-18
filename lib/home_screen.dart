import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'weather_item.dart';
import 'weather_data.dart';
import 'forecast_data.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'weather.dart';


class HomeScreen extends StatefulWidget {


  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;
  WeatherData weatherData;
  ForecastData forecastData;
  String url = 'http://api.openweathermap.org/data/2.5';
  String APIkey = 'd41d0a7e14f9387917a9ec91f6836644';

  loadWeather() async {
    setState(() {
      isLoading = true;
    });

    Position position;
    try {
      // ignore: deprecated_member_use
      position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      print(e);
    }

    if (position !=null) {
      final lat = position.latitude;
      final lon = position.longitude;

      final weatherResponse = await http.get('$url/weather?APPID=$APIkey&lat=${lat.toString()}&lon=${lon.toString()}');
      final forecastResponse = await http.get('$url/forecast?APPID=$APIkey&lat=${lat.toString()}&lon=${lon.toString()}');

      if (weatherResponse.statusCode == 200 && forecastResponse.statusCode == 200) {
        return setState(() {
          weatherData = WeatherData.fromJson(jsonDecode(weatherResponse.body));
          forecastData = ForecastData.fromJson(jsonDecode(forecastResponse.body));
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadWeather();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Location Weather'),
      ),
      body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: weatherData != null ? Weather(weather: weatherData): Container(),
                    ),
                    isLoading ? CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation(Colors.white),

                    ) : IconButton(
                      icon: Icon(Icons.refresh),
                      tooltip: 'Refresh',
                      onPressed: loadWeather,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 200.0,
                    child: forecastData != null ? ListView.builder(
                      itemCount: forecastData.list.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => WeatherItem(
                        weather: forecastData.list.elementAt(index),
                      ),
                    ) : Container()
                  ),
                ),
              )
            ],
          )),
    );
  }
}
