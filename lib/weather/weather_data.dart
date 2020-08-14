import 'package:intl/intl.dart';

import '../common_util.dart';

class WeatherData {
  bool ok;
//  String message;

  String fullCityName;
  String cityCode;

  String body;

  DateTime timestamp;
//  String shidu;
//  double pm25;
//  double pm10;
//  String quality;

  String city;
  List<double> highTemps = [];
  List<double> lowTemps = [];
  List<String> types = [];
  List<DateInt> dates = [];
}

class WeatherSave {
  String fullCityName;
  String cityCode;
  DateTime timestamp;
  String body;

  final DateFormat _fmt = DateFormat("yyyy-MM-dd HH:mm");
  WeatherSave();

  bool setCityInfo(String newFullCityName, String newCityCode) {
    bool changed = false;
    if (cityCode != newCityCode) {
      fullCityName = newFullCityName;
      cityCode = newCityCode;
      timestamp = null;
      body = null;
      changed = true;
    }
    return changed;
  }

  setFrom(WeatherData weatherData) {
    fullCityName = weatherData.fullCityName;
    cityCode = weatherData.cityCode;
    timestamp = weatherData.timestamp;
    body = weatherData.body;
  }

  WeatherSave.fromJson(Map<String, dynamic> m) {
    fullCityName = m["fullCityName"];
    cityCode = m["cityCode"];

    final updateTimeStr = m["timestamp"];
    if (null != updateTimeStr) {
      try {
        timestamp = _fmt.parse(updateTimeStr);
      } catch (err) {}
    }

    body = m["body"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = {};

    // 先判空，否则取出来的时候值是"null"
    if (null != fullCityName) {
      jsonMap["fullCityName"] = fullCityName;
    }

    if (null != cityCode) {
      jsonMap["cityCode"] = cityCode;
    }

    if (null != timestamp) {
      jsonMap["timestamp"] = _fmt.format(timestamp);
    }

    if (null != body) {
      jsonMap["body"] = body;
    }

    return jsonMap;
  }
}

class Weather {
  static Future<WeatherData> getDataFromNetwork(String cityCode) async {
//    return await NetworkWeatherDataIp138.getDataFromNetwork();
//    return await NetworkWeatherDataSojson.getDataFromNetwork(cityCode);
  }
}
