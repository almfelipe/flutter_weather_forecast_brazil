import 'dart:convert';
import 'package:http/http.dart' as http;

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
    final response = await http.get(Uri.https(
      "apiprevmet3.inmet.gov.br",
      "previsao/" + idCity.toString(),
    ));

    if (response.statusCode == 200) {
      List<WeatherForecast> forecastList = [];
      Map<String, dynamic> json = jsonDecode(response.body);

      for (var i = 0; i < 3; i++) {
        Map<String, dynamic> fcjson =
            json.values.toList()[0].values.toList()[0].values.toList()[i];
        WeatherForecast wfc = WeatherForecast.fromJson(fcjson);

        switch (i) {
          case 0:
            wfc.dayShift = "Morning";
            break;
          case 1:
            wfc.dayShift = "Afternoon";
            break;
          case 2:
            wfc.dayShift = "Night";
            break;
        }

        forecastList.add(wfc);
      }

      setState(() {
        forecasts = forecastList;
      });

      return forecastList;
    } else {
      throw Exception('Failed to load');
    }
  }

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
                  Expanded(
                    child: SizedBox(
                      height: 200.0,
                      child: ListView.builder(
                          padding: EdgeInsets.all(8),
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(snapshot.data[index].dayShift),
                                    subtitle: Text(snapshot.data[index].tempMin
                                            .toString() +
                                        "-" +
                                        snapshot.data[index].tempMax
                                            .toString() +
                                        " " +
                                        snapshot.data[index].tempUnit),
                                    leading: Image.memory(
                                      base64.decode(
                                          snapshot.data[index].iconBase64),
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                ],
                              ),
                            );
                          }),
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

    // return FutureBuilder<List<StateBr>>(
    //   future: futureState,
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       return Expanded(
    //         child: SizedBox(
    //           height: 200.0,
    //           child: ListView.builder(
    //               padding: EdgeInsets.all(8),
    //               itemCount: snapshot.data.length,
    //               itemBuilder: (BuildContext context, int index) {
    //                 return Card(
    //                   child: Column(
    //                     children: [
    //                       if (index == 0)
    //                         DropdownButtonFormField(
    //                           decoration: InputDecoration(
    //                             labelText: 'State',
    //                           ),
    //                           value: selectedState.id,
    //                           items: states
    //                               .map((e) => DropdownMenuItem(
    //                                     key: Key(e.id.toString()),
    //                                     child: Text(e.name),
    //                                     value: e.id,
    //                                   ))
    //                               .toList(),
    //                           onChanged: (value) {
    //                             debugPrint(value.toString());
    //                           },
    //                         ),
    //                       ListTile(
    //                         title: Text(snapshot.data[index].id.toString()),
    //                         subtitle: Text(snapshot.data[index].initials),
    //                         trailing: Text(snapshot.data[index].name),
    //                       )
    //                     ],
    //                   ),
    //                 );
    //               }),
    //         ),
    //       );
    //     } else if (snapshot.hasError) {
    //       return Text("${snapshot.error}");
    //     }
    //     // By default, show a loading spinner.
    //     return CircularProgressIndicator();
    //   },
    // );

    // return Column(
    //   children: [
    //     DropdownButtonFormField(
    //       decoration: InputDecoration(
    //         labelText: 'State',
    //       ),
    //       value: selectedState.id,
    //       items: states
    //           .map((e) => DropdownMenuItem(
    //                 key: Key(e.id.toString()),
    //                 child: Text(e.name),
    //                 value: e.id,
    //               ))
    //           .toList(),
    //       onChanged: (value) {
    //         debugPrint(value.toString());
    //       },
    //     ),
    //     DropdownButtonFormField(
    //       decoration: InputDecoration(
    //         labelText: 'City',
    //       ),
    //       value: selectedCity.id,
    //       items: citiesBA
    //           .map((e) => DropdownMenuItem(
    //                 key: Key(e.id.toString()),
    //                 child: Text(e.name),
    //                 value: e.id,
    //               ))
    //           .toList(),
    //       onChanged: (value) {
    //         debugPrint(value.toString());
    //       },
    //     ),
    //     Padding(
    //       padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
    //       child: Card(
    //         clipBehavior: Clip.antiAlias,
    //         child: Column(
    //           children: [
    //             ListTile(
    //               title: Text("Monday"),
    //               subtitle: Text("22nd March 2021, Salvador - BA"),
    //             ),
    //             Padding(
    //               padding: EdgeInsets.only(top: 16.0, bottom: 24.0),
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                 children: [
    //                   Column(children: [
    //                     ForecastBigLayout(
    //                       'Morning',
    //                       ssaForecast
    //                           .first.dayShiftForecastData.first.iconFinal,
    //                       ssaForecast.first.dayShiftForecastData.first.tempMin,
    //                       ssaForecast.first.dayShiftForecastData.first.tempMax,
    //                     ),
    //                   ]),
    //                   Column(children: [
    //                     ForecastBigLayout(
    //                       'Afternoon',
    //                       ssaForecast
    //                           .first.dayShiftForecastData.first.iconFinal,
    //                       ssaForecast.first.dayShiftForecastData.first.tempMin,
    //                       ssaForecast.first.dayShiftForecastData.first.tempMax,
    //                     ),
    //                   ]),
    //                   Column(children: [
    //                     ForecastBigLayout(
    //                       'Night',
    //                       ssaForecast
    //                           .first.dayShiftForecastData.first.iconFinal,
    //                       ssaForecast.first.dayShiftForecastData.first.tempMin,
    //                       ssaForecast.first.dayShiftForecastData.first.tempMax,
    //                     ),
    //                   ]),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ],
    // );
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
        fit: BoxFit.contain,
      ),
      Text(this.tempMin + ' - ' + this.tempMax + ' ' + this.tempUnit),
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
  String dayShift;
  final String iconBase64;
  final int tempMin;
  final int tempMax;
  final String tempUnit = "ºC";

  WeatherForecast({this.dayShift, this.iconBase64, this.tempMin, this.tempMax});

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
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
