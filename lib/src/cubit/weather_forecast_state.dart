part of 'weather_forecast_cubit.dart';

@immutable
abstract class WeatherForecastState {}

class WeatherForecastLoading extends WeatherForecastState {
  WeatherForecastLoading();
}

class WeatherForecastLoaded extends WeatherForecastState {
  final WeatherForecastBrazilHomeData weatherForecastBrazilHomeData;
  WeatherForecastLoaded(this.weatherForecastBrazilHomeData);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is WeatherForecastLoaded &&
        o.weatherForecastBrazilHomeData == weatherForecastBrazilHomeData;
  }

  @override
  int get hashCode => weatherForecastBrazilHomeData.hashCode;
}

class WeatherForecastError extends WeatherForecastState {
  final String message;
  WeatherForecastError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is WeatherForecastError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
