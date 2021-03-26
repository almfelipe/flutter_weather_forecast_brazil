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
}
