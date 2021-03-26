import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:flutter_weather_forecast_brazil/src/models/StateBr.dart';
import 'package:flutter_weather_forecast_brazil/src/models/CityBr.dart';
import 'package:flutter_weather_forecast_brazil/src/models/WeatherForecast.dart';
import 'package:flutter_weather_forecast_brazil/src/models/DayshiftWeatherForecast.dart';
import 'package:flutter_weather_forecast_brazil/src/services/ibge/locality/Locality.dart';

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
    Locality().getStates().then((value) => futureStateBrCallback(value));
  }

  void futureStateBrCallback(List<StateBr> list) {
    debugPrint("States carregado");
    setState(() {
      _states = list;
      _selectedState = list[0];
    });

    Locality()
        .getCities(_selectedState.id)
        .then((value) => futureCityBrCallback(value));
  }

  void futureCityBrCallback(List<CityBr> list) {
    debugPrint("Ciites carregado");
    setState(() {
      _cities = list;
      _selectedCity = list[0];
    });

    _futureWeatherForecasts = fetchForecasts(_selectedCity.id);
  }

  // Future<List<StateBr>> fetchStates() async {
  //   final response = await http.get(Uri.https(
  //     "servicodados.ibge.gov.br",
  //     "api/v1/localidades/estados",
  //     {"orderBy": "nome"},
  //   ));

  //   if (response.statusCode == 200) {
  //     List<dynamic> jsonList = jsonDecode(response.body);
  //     List<StateBr> stateList = [];

  //     jsonList.forEach((element) {
  //       stateList.add(StateBr.fromJson(element));
  //     });

  //     return stateList;
  //   } else {
  //     throw Exception('Failed to load');
  //   }
  // }

  // Future<List<CityBr>> fetchCities(int idStateBr) async {
  //   final response = await http.get(Uri.https(
  //       "servicodados.ibge.gov.br",
  //       "api/v1/localidades/estados/" + idStateBr.toString() + "/municipios",
  //       {"orderBy": "nome"}));

  //   if (response.statusCode == 200) {
  //     List<dynamic> jsonList = jsonDecode(response.body);
  //     List<CityBr> cityList = [];

  //     jsonList.forEach((element) {
  //       cityList.add(CityBr.fromJson(element));
  //     });

  //     return cityList;
  //   } else {
  //     throw Exception('Failed to load');
  //   }
  // }

  Future<List<WeatherForecast>> fetchForecasts(int idCity) async {
    final List<String> dayShifts = [
      "Morning",
      "Afternoon",
      "Night",
      "day-long",
    ];
    final response = await http.get(Uri.https(
      "apiprevmet3.inmet.gov.br",
      "previsao/" + idCity.toString(),
    ));

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      Map<String, dynamic> json2 = json.values.toList()[0];
      List<WeatherForecast> weatherForecasts = [];
      List<String> forecastDates = json.values.toList()[0].keys.toList();

      forecastDates.forEach((forecastDate) {
        WeatherForecast weatherForecast =
            WeatherForecast(DateFormat('dd/MM/yyyy').parse(forecastDate));

        List<String> keys = json2[forecastDate].keys.toList();

        if (keys.length == 3) {
          keys.asMap().forEach((index, key) {
            DayshiftWeatherForecast dayshiftWeatherForecast =
                DayshiftWeatherForecast.fromJson((json2[forecastDate])[key]);
            dayshiftWeatherForecast.dayShift = dayShifts[index];
            weatherForecast.dayshiftWeatherForecasts
                .add(dayshiftWeatherForecast);
          });
        } else {
          DayshiftWeatherForecast dayshiftWeatherForecast =
              DayshiftWeatherForecast.fromJson((json2[forecastDate]));
          dayshiftWeatherForecast.dayShift = dayShifts[3]; //day-long dayshift
          weatherForecast.dayshiftWeatherForecasts.add(dayshiftWeatherForecast);
        }
        weatherForecasts.add(weatherForecast);
      });

      return weatherForecasts;
    } else {
      throw Exception('Failed to load');
    }
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
                            Locality()
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
                            _futureWeatherForecasts = fetchForecasts(value);
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
