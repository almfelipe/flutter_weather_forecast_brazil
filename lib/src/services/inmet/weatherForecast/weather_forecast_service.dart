import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:flutter_weather_forecast_brazil/src/models/weather_forecast.dart';
import 'package:flutter_weather_forecast_brazil/src/models/dayshift_weather_forecast.dart';

class WeatherForecastService {
  final String _apiHost = "apiprevmet3.inmet.gov.br";

  Future<List<WeatherForecast>> getWeatherForecast(int idCity) async {
    final List<String> dayShifts = [
      "Morning",
      "Afternoon",
      "Night",
      "day-long",
    ];
    final response = await http.get(Uri.https(
      _apiHost,
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
}
