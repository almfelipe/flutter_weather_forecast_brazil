import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_weather_forecast_brazil/src/models/StateBr.dart';
import 'package:flutter_weather_forecast_brazil/src/models/CityBr.dart';

class LocalityService {
  final String _apiHost = "servicodados.ibge.gov.br";
  final String _apiBaseEndpoint = "api/v1/localidades/";

  Future<List<StateBr>> getStates() async {
    final response = await http.get(Uri.https(
      _apiHost,
      _apiBaseEndpoint + "/estados",
      {"orderBy": "nome"},
    ));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      List<StateBr> stateList = [];

      jsonList.forEach((element) {
        stateList.add(StateBr.fromJson(element));
      });

      return stateList;
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<List<CityBr>> getCities(int idStateBr) async {
    final response = await http.get(Uri.https(
        _apiHost,
        _apiBaseEndpoint + "/estados/" + idStateBr.toString() + "/municipios",
        {"orderBy": "nome"}));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      List<CityBr> cityList = [];

      jsonList.forEach((element) {
        cityList.add(CityBr.fromJson(element));
      });

      return cityList;
    } else {
      throw Exception('Failed to load');
    }
  }
}
