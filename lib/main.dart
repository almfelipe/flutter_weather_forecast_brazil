import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';

void main() => runApp(WeatherForecastBrazil());

class WeatherForecastBrazil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('flutter_weather_forecast_brazil'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [LocationInfo()],
          ),
        ),
      ),
    );
  }
}

class LocationInfo extends StatelessWidget {
  final State selectedState = State(29, 'BA', 'Bahia');
  final City selectedCity = City(2927408, 'Salvador');

  final List<State> states = [
    State(29, 'BA', 'Bahia'),
    State(26, 'PE', 'Pernambuco'),
  ];

  final List<City> citiesBA = [
    City(2927408, 'Salvador'),
    City(2921708, 'Morro do Chapéu'),
  ];

  final List<City> citiesPE = [
    City(2611606, 'Recife'),
    City(2611101, 'Petrolina'),
  ];

  final List<Forecast> ssaForecast = [
    Forecast(
      '22/03/2021',
      null,
      [
        ForecastData("icon", "22", "32"),
        ForecastData("icon", "23", "33"),
        ForecastData("icon", "24", "34"),
      ],
    ),
    Forecast(
      '23/03/2021',
      null,
      [
        ForecastData("icon", "25", "35"),
        ForecastData("icon", "26", "36"),
        ForecastData("icon", "27", "37"),
      ],
    ),
    Forecast(
      '24/03/2021',
      ForecastData("icon", "28", "38"),
      null,
    ),
    Forecast(
      '25/03/2021',
      ForecastData("icon", "29", "39"),
      null,
    ),
    Forecast(
      '26/03/2021',
      ForecastData("icon", "30", "40"),
      null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField(
          decoration: InputDecoration(
            labelText: 'State',
          ),
          value: selectedState.id,
          items: states
              .map((e) => DropdownMenuItem(
                    key: Key(e.id.toString()),
                    child: Text(e.name),
                    value: e.id,
                  ))
              .toList(),
          onChanged: (value) {
            debugPrint(value.toString());
          },
        ),
        DropdownButtonFormField(
          decoration: InputDecoration(
            labelText: 'City',
          ),
          value: selectedCity.id,
          items: citiesBA
              .map((e) => DropdownMenuItem(
                    key: Key(e.id.toString()),
                    child: Text(e.name),
                    value: e.id,
                  ))
              .toList(),
          onChanged: (value) {
            debugPrint(value.toString());
          },
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                title: Text("Monday"),
                subtitle: Text("22nd March 2021, Salvador - BA"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(children: [
                    ForecastBigLayout(
                      'Morning',
                      ssaForecast.first.dayShiftForecastData.first.iconFinal,
                      ssaForecast.first.dayShiftForecastData.first.tempMin,
                      ssaForecast.first.dayShiftForecastData.first.tempMax,
                    ),
                  ]),
                  Column(children: [
                    ForecastBigLayout(
                      'Afternoon',
                      ssaForecast.first.dayShiftForecastData.first.iconFinal,
                      ssaForecast.first.dayShiftForecastData.first.tempMin,
                      ssaForecast.first.dayShiftForecastData.first.tempMax,
                    ),
                  ]),
                  Column(children: [
                    ForecastBigLayout(
                      'Night',
                      ssaForecast.first.dayShiftForecastData.first.iconFinal,
                      ssaForecast.first.dayShiftForecastData.first.tempMin,
                      ssaForecast.first.dayShiftForecastData.first.tempMax,
                    ),
                  ]),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

class ForecastBigLayout extends StatelessWidget {
  final String dayShift;
  final String iconBase64;
  final String tempMin;
  final String tempMax;
  final String tempUnit = "ºC";

  ForecastBigLayout(this.dayShift, this.iconBase64, this.tempMin, this.tempMax);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(this.dayShift),
      Image.memory(
        base64.decode(this.iconBase64),
      ),
      Text(this.tempMin + ' - ' + this.tempMax + ' ' + this.tempUnit),
    ]);
  }
}

class ForecastSmallLayout extends StatelessWidget {
  final String dayOfTheWeek;
  final String dayShift;
  final String iconBase64;
  final String tempMin;
  final String tempMax;
  final String tempUnit = "ºC";

  ForecastSmallLayout(this.dayOfTheWeek, this.dayShift, this.iconBase64,
      this.tempMin, this.tempMax);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(this.dayOfTheWeek),
      Text(this.dayShift),
      Image.memory(
        base64.decode(this.iconBase64),
      ),
      Text(this.tempMin + ' - ' + this.tempMax + ' ' + this.tempUnit),
    ]);
  }
}

class State {
  final int id;
  final String initials;
  final String name;

  State(this.id, this.initials, this.name);
}

class City {
  final int id;
  final String name;

  City(this.id, this.name);
}

class Forecast {
  final String date;
  final ForecastData dayLongForecastData;
  final List<ForecastData> dayShiftForecastData;

  Forecast(this.date, this.dayLongForecastData, this.dayShiftForecastData);
}

class ForecastData {
  final String iconFinal =
      "iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAYAAABw4pVUAAAAnUlEQVR42u3RAQ0AAAgDoNu/mp20hnNQgUqmwxklRAhChCBECEKEIESIECEIEYIQIQgRghAhCEGIEIQIQYgQhAhBCEKEIEQIQoQgRAhCECIEIUIQIgQhQhCCECEIEYIQIQgRghCECEGIEIQIQYgQhCBECEKEIEQIQoQgBCFCECIEIUIQIgQhCBGCECEIEYIQIQgRIkQIQoQgRAhCvltdsbOxjRgSSAAAAABJRU5ErkJggg==";
  final String icon;
  final String tempMin;
  final String tempMax;

  ForecastData(this.icon, this.tempMin, this.tempMax);
}
