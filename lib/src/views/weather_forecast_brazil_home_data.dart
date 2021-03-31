import 'package:flutter_weather_forecast_brazil/src/models/city_br.dart';
import 'package:flutter_weather_forecast_brazil/src/models/state_br.dart';
import 'package:flutter_weather_forecast_brazil/src/models/weather_forecast.dart';

class WeatherForecastBrazilHomeData {
  final List<StateBr> states;
  final StateBr selectedState;
  final List<CityBr> cities;
  final CityBr selectedCity;
  final List<WeatherForecast> weatherForecasts;

  WeatherForecastBrazilHomeData(this.states, this.selectedState, this.cities,
      this.selectedCity, this.weatherForecasts);
}
