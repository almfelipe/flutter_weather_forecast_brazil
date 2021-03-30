import 'package:flutter/widgets.dart';
import 'dart:convert';

class InfoWeatherForecast extends StatelessWidget {
  final String dayShift;
  final String iconBase64;
  final int tempMin;
  final int tempMax;
  final String tempUnit = "ºC";

  InfoWeatherForecast(
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
