import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_weather_forecast_brazil/src/models/city_br.dart';
import 'package:flutter_weather_forecast_brazil/src/models/state_br.dart';
import 'package:flutter_weather_forecast_brazil/src/models/weather_forecast.dart';
import 'package:flutter_weather_forecast_brazil/src/services/ibge/locality/locality_service.dart';
import 'package:flutter_weather_forecast_brazil/src/services/inmet/weatherForecast/weather_forecast_service.dart';

import 'package:flutter_weather_forecast_brazil/src/views/components/info_weather_forecast.dart';
import 'package:flutter_weather_forecast_brazil/src/views/components/title_weather_forecast.dart';

class WeatherForecastBrazilHome extends StatefulWidget {
  @override
  _WeatherForecastBrazilHome createState() => _WeatherForecastBrazilHome();
}

class _WeatherForecastBrazilHome extends State<WeatherForecastBrazilHome> {
  StateBr _selectedState;
  CityBr _selectedCity;
  List<StateBr> _states = [];
  List<CityBr> _cities = [];
  Future<List<WeatherForecast>> _futureWeatherForecasts;

  @override
  void initState() {
    super.initState();
    LocalityService()
        .getStates()
        .then((value) => _futureStateBrCallback(value));
  }

  void _futureStateBrCallback(List<StateBr> list) {
    setState(() {
      _states = list;
      _selectedState = list[0];
    });
    LocalityService()
        .getCities(_selectedState.id)
        .then((value) => _futureCityBrCallback(value));
  }

  void _futureCityBrCallback(List<CityBr> list) {
    setState(() {
      _cities = list;
      _selectedCity = list[0];
    });
    _futureWeatherForecasts =
        WeatherForecastService().getWeatherForecast(_selectedCity.id);
    _futureWeatherForecasts
        .then((value) => _futureWeatherForecastCallback(value));
  }

  void _futureWeatherForecastCallback(List<WeatherForecast> list) {
    EasyLoading.dismiss();
  }

  _WeatherForecastBrazilHome() : super();

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
                          EasyLoading.show(status: 'loading...');
                          setState(() {
                            _selectedState = _states
                                .firstWhere((element) => element.id == value);
                          });
                          LocalityService()
                              .getCities(value)
                              .then((value) => _futureCityBrCallback(value));
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
                          EasyLoading.show(status: 'loading...');
                          setState(() {
                            _selectedCity = _cities
                                .firstWhere((element) => element.id == value);
                          });
                          _futureWeatherForecasts = WeatherForecastService()
                              .getWeatherForecast(value);

                          _futureWeatherForecasts.then(
                              (value) => _futureWeatherForecastCallback(value));
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
                              padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
                              child: Column(
                                children: [
                                  TitleWeatherForecast(
                                    date: snapshot.data[index].date,
                                    stateInitials: this._selectedState.initials,
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
                                        InfoWeatherForecast(
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
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Failed to load"),
              ],
            ),
          );
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
  }
}
