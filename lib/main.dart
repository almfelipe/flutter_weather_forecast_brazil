import 'dart:convert';
import 'package:flutter_weather_forecast_brazil/StateBr.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
  StateBr selectedState;
  CityBr selectedCity;
  List<StateBr> states = [];
  List<CityBr> cities = [];
  List<WeatherForecast> forecasts = [];
  Future<List<StateBr>> futureStates;
  Future<List<CityBr>> futureCities;
  Future<List<WeatherForecast>> futureForecasts;

  @override
  void initState() {
    super.initState();
    futureStates = fetchStates();
  }

  Future<List<StateBr>> fetchStates() async {
    final response = await http.get(Uri.https(
      "servicodados.ibge.gov.br",
      "api/v1/localidades/estados",
      {"orderBy": "nome"},
    ));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      List<StateBr> stateList = [];

      jsonList.forEach((element) {
        stateList.add(StateBr.fromJson(element));
      });

      setState(() {
        states = stateList;
        selectedState = stateList[0];
      });

      futureCities = fetchCities(selectedState.id);

      return stateList;
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<List<CityBr>> fetchCities(int idStateBr) async {
    final response = await http.get(Uri.https(
        "servicodados.ibge.gov.br",
        "api/v1/localidades/estados/" + idStateBr.toString() + "/municipios",
        {"orderBy": "nome"}));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      List<CityBr> cityList = [];

      jsonList.forEach((element) {
        cityList.add(CityBr.fromJson(element));
      });

      setState(() {
        cities = cityList;
        selectedCity = cityList[0];
      });

      futureForecasts = fetchForecasts(selectedCity.id);

      return cityList;
    } else {
      throw Exception('Failed to load');
    }
  }

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

      setState(() {
        forecasts = weatherForecasts;
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
        future: futureForecasts,
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
                          value: selectedState.id,
                          items: states
                              .map((e) => DropdownMenuItem(
                                    key: Key(e.id.toString()),
                                    child: Text(e.name),
                                    value: e.id,
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedState = states
                                  .firstWhere((element) => element.id == value);
                            });
                            futureCities = fetchCities(value);
                          },
                        ),
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: 'City',
                          ),
                          value: selectedCity.id,
                          items: cities
                              .map((e) => DropdownMenuItem(
                                    key: Key(e.id.toString()),
                                    child: Text(e.name),
                                    value: e.id,
                                  ))
                              .toList(),
                          onChanged: (value) {
                            futureForecasts = fetchForecasts(value);
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
                                            this.selectedState.initials,
                                        cityName: this.selectedCity.name,
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

class StateBr {
  final int id;
  final String initials;
  final String name;

  StateBr({this.id, this.initials, this.name});

  factory StateBr.fromJson(Map<String, dynamic> json) {
    return StateBr(
      id: json['id'],
      initials: json['sigla'],
      name: json['nome'],
    );
  }
}

class CityBr {
  final int id;
  final String name;

  CityBr({this.id, this.name});

  factory CityBr.fromJson(Map<String, dynamic> json) {
    return CityBr(
      id: json['id'],
      name: json['nome'],
    );
  }
}

class WeatherForecast {
  final DateTime date;
  List<DayshiftWeatherForecast> dayshiftWeatherForecasts = [];

  WeatherForecast(this.date);

  @override
  String toString() {
    String strDayshiftWeatherForecast = " { ";
    dayshiftWeatherForecasts.forEach((element) {
      strDayshiftWeatherForecast += element.toString() + ",";
    });
    strDayshiftWeatherForecast += " }";

    return DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY, 'en_US').format(date) +
        strDayshiftWeatherForecast;
  }
}

class DayshiftWeatherForecast {
  String dayShift;
  final String iconBase64;
  final int tempMin;
  final int tempMax;
  final String tempUnit = "ºC";

  DayshiftWeatherForecast(
      {this.dayShift, this.iconBase64, this.tempMin, this.tempMax});

  factory DayshiftWeatherForecast.fromJson(Map<String, dynamic> json) {
    return DayshiftWeatherForecast(
      tempMin: json['temp_min'],
      tempMax: json['temp_max'],
      iconBase64: json['icone'].replaceAll('data:image/png;base64,', ''),
    );
  }

  @override
  String toString() {
    return "dayShift: $dayShift tempMin: $tempMin tempMax: $tempMax tempUnit: $tempUnit";
  }
}
