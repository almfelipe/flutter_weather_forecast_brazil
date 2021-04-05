import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather_forecast_brazil/src/cubit/weather_forecast_cubit.dart';

import 'package:flutter_weather_forecast_brazil/src/services/ibge/locality/locality_service.dart';
import 'package:flutter_weather_forecast_brazil/src/services/inmet/weatherForecast/weather_forecast_service.dart';

import 'package:flutter_weather_forecast_brazil/src/views/components/info_weather_forecast.dart';
import 'package:flutter_weather_forecast_brazil/src/views/components/nav_bar.dart';
import 'package:flutter_weather_forecast_brazil/src/views/components/title_weather_forecast.dart';
import 'package:flutter_weather_forecast_brazil/src/views/weather_forecast_brazil_home_data.dart';

class WeatherForecastBrazilHome extends StatefulWidget {
  @override
  _WeatherForecastBrazilHome createState() => _WeatherForecastBrazilHome();
}

class _WeatherForecastBrazilHome extends State<WeatherForecastBrazilHome> {
  _WeatherForecastBrazilHome() : super();

  Widget buildLoading() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget buildTextMessage(String message) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message),
          ],
        ),
      ),
    );
  }

  Widget buildWeather(
      WeatherForecastBrazilHomeData data, BuildContext context) {
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
                  value: data.selectedState.id,
                  items: data.states
                      .map((e) => DropdownMenuItem(
                            key: Key(e.id.toString()),
                            child: Text(e.name),
                            value: e.id,
                          ))
                      .toList(),
                  onChanged: (value) => _onChangeState(context, data, value),
                ),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: 'City',
                  ),
                  value: data.selectedCity.id,
                  items: data.cities
                      .map((e) => DropdownMenuItem(
                            key: Key(e.id.toString()),
                            child: Text(e.name),
                            value: e.id,
                          ))
                      .toList(),
                  onChanged: (value) => _onChangeCity(context, data, value),
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
                      index < data.weatherForecasts.length;
                      index++)
                    Card(
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
                        child: Column(
                          children: [
                            TitleWeatherForecast(
                              date: data.weatherForecasts[index].date,
                              stateInitials: data.selectedState.initials,
                              cityName: data.selectedCity.name,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                for (int dayshifIndex = 0;
                                    dayshifIndex <
                                        data.weatherForecasts[index]
                                            .dayshiftWeatherForecasts.length;
                                    dayshifIndex++)
                                  InfoWeatherForecast(
                                    dayShift: data
                                        .weatherForecasts[index]
                                        .dayshiftWeatherForecasts[dayshifIndex]
                                        .dayShift,
                                    tempMax: data
                                        .weatherForecasts[index]
                                        .dayshiftWeatherForecasts[dayshifIndex]
                                        .tempMax,
                                    tempMin: data
                                        .weatherForecasts[index]
                                        .dayshiftWeatherForecasts[dayshifIndex]
                                        .tempMin,
                                    iconBase64: data
                                        .weatherForecasts[index]
                                        .dayshiftWeatherForecasts[dayshifIndex]
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
  }

  void _onChangeState(
      BuildContext context, WeatherForecastBrazilHomeData data, int idState) {
    final weatherForecastCubit = BlocProvider.of<WeatherForecastCubit>(context);

    final selectedState =
        data.states.firstWhere((state) => state.id == idState);

    weatherForecastCubit.getWeather(
        data.states, data.cities, selectedState, null);
  }

  void _onChangeCity(
      BuildContext context, WeatherForecastBrazilHomeData data, int idCity) {
    final weatherForecastCubit = BlocProvider.of<WeatherForecastCubit>(context);

    final selectedCity = data.cities.firstWhere((city) => city.id == idCity);

    weatherForecastCubit.getWeather(
        data.states, data.cities, data.selectedState, selectedCity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      bottomNavigationBar: NavBar(),
      body: Container(
        child: BlocProvider<WeatherForecastCubit>(
          create: (context) =>
              WeatherForecastCubit(LocalityService(), WeatherForecastService()),
          child: BlocBuilder<WeatherForecastCubit, WeatherForecastState>(
            builder: (context, state) {
              if (state is WeatherForecastLoading) {
                return buildLoading();
              } else if (state is WeatherForecastLoaded) {
                return buildWeather(
                    state.weatherForecastBrazilHomeData, context);
              } else if (state is WeatherForecastError) {
                return buildTextMessage(state.message);
              } else {
                return buildTextMessage('invalid state');
              }
            },
          ),
        ),
      ),
    );
  }
}
