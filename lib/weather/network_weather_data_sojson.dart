import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../common_util.dart';
import 'weather_data.dart';

class NetworkWeatherDataSojson {
  static DateTime _lastTs;
  static int _count = 0;
  static Future<WeatherData> getDataFromNetwork(
      String fullCityName, String cityCode) async {
//    return _test(); // for test

    // 做个访问控制，不然容易被封IP
    final now = DateTime.now();
    if ((null != _lastTs) && (now.difference(_lastTs).inSeconds < 2)) {
      _count++;
      print("2秒内访问$_count次");
      return null;
    }
    _lastTs = now;
    _count = 0;

    String url;
//    url = "http://t.weather.sojson.com/api/weather/city/101042600"; // 大足
//    url = "http://t.weather.sojson.com/api/weather/city/101040700"; // 渝北
//    url = "http://www.tianqi.com/dazu/30/";
//    url = "https://www.tq321.com/chongqing/";

    url = "http://t.weather.sojson.com/api/weather/city/$cityCode";
    print("从网络获取天气数据: $url");

    http.Response response;
    try {
      response = await http.get(url);
    } catch (e) {
      final log = "从网络获取数据失败: $e";
      print(log);
      return null;
    }

    print(response.body);
//    String body = utf8.decode(response.bodyBytes);

    return parse(fullCityName, cityCode, response.body);
  }

  static WeatherData _test() {
    // for test
    final data = WeatherData();
    data
      ..ok = true
      ..fullCityName = "a b c"
      ..cityCode = "0001"
      ..body = "abc"
      ..timestamp = DateTime.now()
//      ..pm25 = 1.0
      ..city = "c"
      ..highTemps = [1, 2, 3, 4, 5, 6, 7]
      ..lowTemps = [-1, -2, -3, -4, -5, -6, -7]
      ..types = ["a", "a", "a", "a", "a", "a", "a"]
      ..dates = [
        DateInt.fromInt(20191120),
        DateInt.fromInt(20191120),
        DateInt.fromInt(20191120),
        DateInt.fromInt(20191120),
        DateInt.fromInt(20191120),
        DateInt.fromInt(20191120),
        DateInt.fromInt(20191120),
      ];

    return data;
  }

  String _body;
//  int _status;
//  String _message;
  DateTime _timestamp;
  String _shidu;
  double _pm25;
  double _pm10;
  String _quality;

  String _city;
  List<_WeatherDataDay> _days;

  static WeatherData parse(String fullCityName, String cityCode, String body) {
    final sojsonWeatherData = NetworkWeatherDataSojson();
    final msg = sojsonWeatherData._parse(body);
    if ((null != msg) && ("" != msg)) {
      print(msg);
      final weatherData = WeatherData();
      weatherData.ok = false;
      return weatherData;
    }

    final weatherData = sojsonWeatherData.convert2WeatherData();
    if (null != weatherData) {
      weatherData.fullCityName = fullCityName;
      weatherData.cityCode = cityCode;
    }

    return weatherData;
  }

  String _parse(String body) {
    _body = body;
    Map<String, dynamic> json;

    try {
      json = jsonDecode(_body);
    } catch (err) {
      return "json decode error!";
    }

    final status = json["status"];
    if (200 != status) {
      return json["message"];
      return "status is not 200!";
    }

//    print(body);

    dynamic tmp;

    tmp = json["date"]; // "20191115"
    if ((null == tmp) || !(tmp is String)) {
      return "parse date error!";
    }
    DateInt di;
    try {
      di = DateInt.fromInt(int.parse(tmp));
    } catch (err) {
      return "parse date error!";
    }

    tmp = json["cityInfo"];
    if ((null == tmp) || !(tmp is Map<String, dynamic>)) {
      return "parse cityInfo error!";
    }
    final Map cityInfo = tmp;
    final String city = cityInfo["city"];
    final String parentCity = cityInfo["parent"];

    _city = "$parentCity $city";

    tmp = cityInfo["updateTime"]; // "12:23"
    if ((null == tmp) || !(tmp is String)) {
      return "parse updateTime error!";
    }

    // "20191115 12:23"
    try {
      _timestamp = DateFormat("yyyy-MM-dd hh:mm")
          .parse("${di.year}-${di.month}-${di.day} $tmp");
    } catch (err) {
      return "parse updateTime error: $err";
    }

    tmp = json["data"];
    if ((null == tmp) || !(tmp is Map<String, dynamic>)) {
      return "parse data error!";
    }
    final Map jsonData = tmp;

    tmp = jsonData["pm25"];
    if ((null == tmp) || !(tmp is double)) {
      return "parse pm25 error!";
    }
    _pm25 = tmp;

    tmp = jsonData["pm10"];
    if ((null == tmp) || !(tmp is double)) {
      return "parse pm10 error!";
    }
    _pm10 = tmp;

    tmp = jsonData["quality"];
    if ((null == tmp) || !(tmp is String)) {
      return "parse quality error!";
    }
    _quality = tmp;

    tmp = jsonData["shidu"];
    if ((null == tmp) || !(tmp is String)) {
      return "parse shidu error!";
    }
    _shidu = tmp;

    _days = [];
    final _WeatherDataDay yesterday =
        _WeatherDataDay.parse(jsonData["yesterday"]);
    if (null != yesterday) {
      _days.add(yesterday);
    }

    tmp = jsonData["forecast"];
    if ((null == tmp) || !(tmp is List)) {
      return "parse forecast error!";
    }
    final List jsonForecast = tmp;
    for (final e in jsonForecast) {
      final _WeatherDataDay item = _WeatherDataDay.parse(e);
      if (null != item) {
        _days.add(item);
      }
    }

    _days.sort(sortByDateAsc);

    return null;
  }

  static int sortByDateAsc(_WeatherDataDay a, _WeatherDataDay b) {
    if (a.date.data < b.date.data) {
      return -1;
    } else if (b.date.data < a.date.data) {
      return 1;
    } else {
      return 0;
    }
  }

  WeatherData convert2WeatherData() {
    final WeatherData weatherData = WeatherData();

    weatherData.ok = true;
    weatherData.body = _body;
    weatherData.timestamp = _timestamp;
//    weatherData.shidu = _shidu;
//    weatherData.pm25 = _pm25;
//    weatherData.pm10 = _pm10;
//    weatherData.quality = _quality;
    weatherData.city = _city;

//    final DateInt todayInt = DateInt(DateTime.now());

    for (final d in _days) {
      weatherData.dates.add(d.date);
      weatherData.highTemps.add(d.high.toDouble());
      weatherData.lowTemps.add(d.low.toDouble());
      weatherData.types.add(d.weatherType);
    }

    return weatherData;
  }
}

class _WeatherDataDay {
  final DateInt date;
  final int high;
  final int low;
  final String weatherType;
  _WeatherDataDay(this.date, this.high, this.low, this.weatherType);

  static _WeatherDataDay parse(dynamic json) {
    if ((null == json) || !(json is Map<String, dynamic>)) {
      return null;
    }

    final int hightTemp = _parseTemp(json["high"]);
    if (null == hightTemp) {
      return null;
    }

    final int lowTemp = _parseTemp(json["low"]);
    if (null == lowTemp) {
      return null;
    }

    final dt = _parseDate(json["ymd"]);
    if (null == dt) {
      return null;
    }

    dynamic tmp = json["type"];
    if ((null == tmp) || !(tmp is String)) {
      return null;
    }

    final String type = tmp;

    return _WeatherDataDay(dt, hightTemp, lowTemp, type);
  }

  // "高温 17℃", "低温 14℃",
  static final RegExp _tempRE = RegExp(r'(高温|低温) (-?[\d]{1,2})℃');
//  static final RegExp _lowTempRE = RegExp(r'低温 (-?[\d]{1,2})℃');
  static int _parseTemp(dynamic tempStr) {
    if ((null == tempStr) || !(tempStr is String)) {
      return null;
    }

    final match = _tempRE.firstMatch(tempStr);
    if (2 != match.groupCount) {
      return null;
    }
    final String highTempStr = match.group(2);
    int hightTemp;
    try {
      hightTemp = int.parse(highTempStr);
    } catch (err) {
      return null;
    }
    return hightTemp;
  }

  static final DateFormat _fmt = DateFormat('yyyy-MM-dd');
  static DateInt _parseDate(dynamic dateStr) {
    if ((null == dateStr) || !(dateStr is String)) {
      return null;
    }

    final DateTime dt = _fmt.parse(dateStr);
    if (null == dt) {
      return null;
    }

    return DateInt(dt);
  }
}
