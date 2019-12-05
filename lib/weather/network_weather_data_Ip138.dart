import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:http/http.dart' as http;
import '../common_util.dart';
import 'weather_data.dart';

class NetworkWeatherDataIp138 {
  static Future<WeatherData> getDataFromNetwork() async {
    String url;
    //    url= "http://qq.ip138.com/weather/sichuan/chengdu_15tian.htm";
    url = "http://qq.ip138.com/weather/chongqing/dazu_15tian.htm";

    //    print("从网络获取天气数据");
//    print(url);

    http.Response response;
    try {
      response = await http.get(url);
    } catch (e) {
      print("从网络获取数据失败: $e");
      return null;
    }

    String body = gbk.decode(response.bodyBytes);

    NetworkWeatherDataIp138 ip138NetworkData =
        NetworkWeatherDataIp138.parse(body);

    return ip138NetworkData.convert2WeatherData();
  }

  static final DateFormat _fmt = DateFormat('yyyy-MM-dd');
  static List<DateInt> _parseDates(String data) {
    // <td width="20%">2019-5-19 星期日</td>
    final dateRE =
        RegExp(r'<td[^>]*>([\d]{4}-[\d]{1,2}-[\d]{1,2}) *[^<]*</td>');
    final dateMatches = dateRE.allMatches(data);

    List<DateInt> dataList = [];
    for (final match in dateMatches) {
      assert(1 == match.groupCount);

      final dt = _fmt.parse(match.group(1));
      final dateInt = DateInt(dt);
      dataList.add(dateInt);
    }

    return dataList;
  }

  static List<List<double>> _parseTemperatureDataIp138(String data) {
    //<td>24℃～18℃</td>
    var tempRE = RegExp(r'<td>(-?[\d]{1,2})℃～*(-?[\d]{1,2})℃</td>');
    var tempMatches = tempRE.allMatches(data);

    final List<double> highTempLine = [];
    final List<double> lowTempLine = [];
    for (var match in tempMatches) {
      assert(2 == match.groupCount);

      final int high = int.parse(match.group(1));
      final int low = int.parse(match.group(2));
      highTempLine.add(high.toDouble());
      lowTempLine.add(low.toDouble());
    }

    return [highTempLine, lowTempLine];
  }

  String _city;
  List<DateInt> _dates;
  List<List<double>> _temps;

  static NetworkWeatherDataIp138 parse(String body) {
    NetworkWeatherDataIp138 networkIp138 = NetworkWeatherDataIp138();
    networkIp138._city = "大足";
    networkIp138._dates = _parseDates(body);
    networkIp138._temps = _parseTemperatureDataIp138(body);

    return networkIp138;
  }

  static int sortByDateAsc(
      NetworkWeatherDataIp138 a, NetworkWeatherDataIp138 b) {
//    if (a.date.data < b.date.data) {
//      return -1;
//    } else if (b.date.data < a.date.data) {
//      return 1;
//    } else {
//      return 0;
//    }
  }

  WeatherData convert2WeatherData() {
    final WeatherData weatherData = WeatherData();

    weatherData.ok = true;
    weatherData.city = _city;

    weatherData.highTemps = _temps[0];
    weatherData.lowTemps = _temps[1];
    weatherData.dates = _dates;

    return weatherData;
  }
}
