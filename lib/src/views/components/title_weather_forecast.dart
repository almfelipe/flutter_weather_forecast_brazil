import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class TitleWeatherForecast extends StatelessWidget {
  final DateTime date;
  final String cityName;
  final String stateInitials;

  TitleWeatherForecast({this.date, this.cityName, this.stateInitials});

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
