import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_weather_forecast_brazil/src/views/weather_forecast_brazil_home.dart';

class WeatherForecastBrazilApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('flutter_weather_forecast_brazil'),
        ),
        body: WeatherForecastBrazilHome(),
      ),
    );
  }
}
