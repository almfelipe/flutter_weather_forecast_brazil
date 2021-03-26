import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:flutter_weather_forecast_brazil/src/models/StateBr.dart';
import 'package:flutter_weather_forecast_brazil/src/models/CityBr.dart';
import 'package:flutter_weather_forecast_brazil/src/models/WeatherForecast.dart';
import 'package:flutter_weather_forecast_brazil/src/services/ibge/locality/LocalityService.dart';
import 'package:flutter_weather_forecast_brazil/src/services/inmet/weatherForecast/WeatherForecastService.dart';

void main() => runApp(WeatherForecastBrazil());

class WeatherForecastBrazil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('flutter_weather_forecast_brazil'),
        ),
        body: LocationInfo(),
      ),
    );
  }
}

class LocationInfo extends StatefulWidget {
  @override
  _LocaltionInfo createState() => _LocaltionInfo();
}

class _LocaltionInfo extends State<LocationInfo> {
  StateBr _selectedState;
  CityBr _selectedCity;
  List<StateBr> _states = [];
  List<CityBr> _cities = [];
  Future<List<WeatherForecast>> _futureWeatherForecasts;

  @override
  void initState() {
    super.initState();
    LocalityService().getStates().then((value) => futureStateBrCallback(value));
  }

  void futureStateBrCallback(List<StateBr> list) {
    setState(() {
      _states = list;
      _selectedState = list[0];
    });

    LocalityService()
        .getCities(_selectedState.id)
        .then((value) => futureCityBrCallback(value));
  }

  void futureCityBrCallback(List<CityBr> list) {
    setState(() {
      _cities = list;
      _selectedCity = list[0];
    });

    _futureWeatherForecasts =
        WeatherForecastService().getWeatherForecast(_selectedCity.id);
  }

  _LocaltionInfo() : super();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WeatherForecast>>(
        future: _futureWeatherForecasts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      children: [
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: 'State',
                          ),
                          value: _selectedState.id,
                          items: _states
                              .map((e) => DropdownMenuItem(
                                    key: Key(e.id.toString()),
                                    child: Text(e.name),
                                    value: e.id,
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedState = _states
                                  .firstWhere((element) => element.id == value);
                            });
                            LocalityService()
                                .getCities(value)
                                .then((value) => futureCityBrCallback(value));
                          },
                        ),
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: 'City',
                          ),
                          value: _selectedCity.id,
                          items: _cities
                              .map((e) => DropdownMenuItem(
                                    key: Key(e.id.toString()),
                                    child: Text(e.name),
                                    value: e.id,
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCity = _cities
                                  .firstWhere((element) => element.id == value);
                            });
                            _futureWeatherForecasts = WeatherForecastService()
                                .getWeatherForecast(value);
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 100.0,
                      child: ListView(
                        children: [
                          for (int index = 0;
                              index < snapshot.data.length;
                              index++)
                            Card(
                              child: Padding(
                                  padding:
                                      EdgeInsets.only(top: 8.0, bottom: 16.0),
                                  child: Column(
                                    children: [
                                      TitleWeatherForecastWidget(
                                        date: snapshot.data[index].date,
                                        stateInitials:
                                            this._selectedState.initials,
                                        cityName: this._selectedCity.name,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          for (int dayshifIndex = 0;
                                              dayshifIndex <
                                                  snapshot
                                                      .data[index]
                                                      .dayshiftWeatherForecasts
                                                      .length;
                                              dayshifIndex++)
                                            WeatherForecastWidget(
                                              dayShift: snapshot
                                                  .data[index]
                                                  .dayshiftWeatherForecasts[
                                                      dayshifIndex]
                                                  .dayShift,
                                              tempMax: snapshot
                                                  .data[index]
                                                  .dayshiftWeatherForecasts[
                                                      dayshifIndex]
                                                  .tempMax,
                                              tempMin: snapshot
                                                  .data[index]
                                                  .dayshiftWeatherForecasts[
                                                      dayshifIndex]
                                                  .tempMin,
                                              iconBase64: snapshot
                                                  .data[index]
                                                  .dayshiftWeatherForecasts[
                                                      dayshifIndex]
                                                  .iconBase64,
                                            )
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text("Failed to load");
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          );
        });
  }
}

class TitleWeatherForecastWidget extends StatelessWidget {
  final DateTime date;
  final String cityName;
  final String stateInitials;

  TitleWeatherForecastWidget({this.date, this.cityName, this.stateInitials});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(DateFormat(DateFormat.WEEKDAY, 'en_US').format(date)),
      subtitle: Text(DateFormat(DateFormat.YEAR_MONTH_DAY).format(date) +
          ". " +
          this.cityName +
          ' - ' +
          this.stateInitials),
    );
  }
}

class WeatherForecastWidget extends StatelessWidget {
  final String dayShift;
  final String iconBase64;
  final int tempMin;
  final int tempMax;
  final String tempUnit = "ºC";

  WeatherForecastWidget(
      {this.dayShift, this.iconBase64, this.tempMin, this.tempMax});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(this.dayShift),
      Image.memory(
        base64.decode(this.iconBase64),
        fit: BoxFit.contain,
      ),
      Text(this.tempMin.toString() +
          ' - ' +
          this.tempMax.toString() +
          ' ' +
          this.tempUnit),
    ]);
  }
}
