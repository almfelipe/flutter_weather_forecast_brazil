import 'package:flutter/material.dart';

class About extends StatelessWidget {
  final String aboutText =
      "This App consults APIs from INMET (National Institute of Meteorology) and IBGE (Brazilian Institute of Geography and Statistics) to provide weather forecasts for Brazilian cities. This project uses BLoC design pattern. For more information access: https://github.com/almfelipe/flutter_weather_forecast_brazil.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                aboutText,
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
