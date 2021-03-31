import 'package:bloc/bloc.dart';
import 'package:flutter_weather_forecast_brazil/src/models/city_br.dart';
import 'package:flutter_weather_forecast_brazil/src/models/state_br.dart';
import 'package:flutter_weather_forecast_brazil/src/models/weather_forecast.dart';
import 'package:flutter_weather_forecast_brazil/src/services/ibge/locality/locality_service.dart';
import 'package:flutter_weather_forecast_brazil/src/services/inmet/weatherForecast/weather_forecast_service.dart';
import 'package:flutter_weather_forecast_brazil/src/views/weather_forecast_brazil_home_data.dart';
import 'package:meta/meta.dart';

part 'weather_forecast_state.dart';

class WeatherForecastCubit extends Cubit<WeatherForecastState> {
  final LocalityService _localityService;
  final WeatherForecastService _weatherForecastService;

  WeatherForecastCubit(this._localityService, this._weatherForecastService)
      : super(WeatherForecastLoading()) {
    this.getWeather(null, null, null, null);
  }

  Future<void> getWeather(List<StateBr> states, List<CityBr> cities,
      StateBr selectedState, CityBr selectedCity) async {
    List<WeatherForecast> weatherForecasts;
    try {
      emit(WeatherForecastLoading());

      if (selectedState == null) {
        states = await this._localityService.getStates();
        selectedState = states[0];
      }

      if (selectedCity == null) {
        cities = await this._localityService.getCities(selectedState.id);
        selectedCity = cities[0];
      }

      weatherForecasts = await this
          ._weatherForecastService
          .getWeatherForecast(selectedCity.id);

      final WeatherForecastBrazilHomeData weatherForecastBrazilHomeData =
          WeatherForecastBrazilHomeData(
              states, selectedState, cities, selectedCity, weatherForecasts);
      emit(WeatherForecastLoaded(weatherForecastBrazilHomeData));
    } on Exception {
      emit(WeatherForecastError(
          "Couldn't fetch weather. Is the device online?"));
    }
  }
}
