import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../city_picker/city_data_manager.dart';
import '../city_picker/city_picker.dart';
import '../common_util.dart';
import '../file_storage.dart';
import '../simple_chart.dart';
import 'get_city_by_ip.dart';
import 'network_weather_data_tianqiapi.dart';
import 'weather_data.dart';

class WeatherPage extends StatefulWidget {
  WeatherPage();

  @override
  State<StatefulWidget> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final double _width = MediaQueryData.fromWindow(window).size.width;
  final double _height = MediaQueryData.fromWindow(window).size.height;

  _WeatherPageState() {
    _init();
  }

  @override
  initState() {
    super.initState();
  }

  final KeyValueFile _keyValueFile = KeyValueFile();
  final String _weatherSaveKey = "weatherSaveKey";
  static WeatherSave _weatherSave = WeatherSave();
  static WeatherData _weatherData;

  _init() async {
    await _loadLocalSave();

    _startRefreshDataFromNetwork();
  }

  static bool _first = true;
  _loadLocalSave() async {
    if (_first) {
      _first = false;
      final str = await _keyValueFile.getString(key: _weatherSaveKey);
      if (null != str) {
        try {
          final jsonMap = json.decode(str);
          final newSave = WeatherSave.fromJson(jsonMap);
          if (null != newSave) {
            _weatherSave = newSave;
            if (null != _weatherSave.body) {
              // 一定时间内，用旧数据
              _weatherData = NetworkWeatherData_tianqiapi.parse(
                  _weatherSave.fullCityName,
                  _weatherSave.cityCode,
                  _weatherSave.body);
              if (null != _weatherData) {
                setState(() {});
                return;
              }
            }
          }
        } catch (err) {
//        _weatherSave = WeatherSave();
        }
      } else {
//      _weatherSave = WeatherSave();
      }
    }
  }

  bool _trying = false;
  _startRefreshDataFromNetwork() {
    if (_trying) {
      return;
    }
    _trying = true;

    _timedTryRefreshDataFromNetwork();
  }

  Future<void> _timedTryRefreshDataFromNetwork() async {
//    await Future.delayed(Duration(seconds: 100));

    _statusText = "正在获取天气数据……";
    if (null == _weatherSave.cityCode) {
      _weatherSave.cityCode = await _getCityCodeFromNetWork();
      // 自动定位的cityCode不保存
      if (null == _weatherSave.cityCode) {
        _timedTask(5, _timedTryRefreshDataFromNetwork);
      }
    }

    if ((null == _weatherData) ||
        (null == _weatherSave.timestamp) ||
        (6 < DateTime.now().difference(_weatherSave.timestamp).inHours)) {
      assert(null != _weatherSave.cityCode);

      final newWeatherData =
          await NetworkWeatherData_tianqiapi.getDataFromNetwork(
              _weatherSave.fullCityName, _weatherSave.cityCode);

      if (null != newWeatherData) {
        if (newWeatherData.ok) {
          _weatherData = newWeatherData;
          _weatherSave.setFrom(_weatherData);
          _keyValueFile.setString(
              key: _weatherSaveKey, value: json.encode(_weatherSave));
          if (mounted) {
            setState(() {});
          }
        }
        _statusText = "获取天气数据失败";
        _trying = false;
      } else {
        // 继续定时更新
        _statusText = "获取天气数据失败";
        _timedTask(5, _timedTryRefreshDataFromNetwork);
      }
    } else {
      _trying = false;
    }
  }

  Future<String> _getCityCodeFromNetWork() async {
    final List<String> names = await _getCityNameFromNetwork();

    String cityName = "";
    for (final name in names) {
      cityName += " " + name;
    }
    cityName = cityName.trimLeft();

    List<CityLevel> items = CityDataMgr.findMatchedCities(cityName);
    if (items.isEmpty) {
      return null;
    }

    String cityCode;
    for (final item in items) {
      if (3 == item.level) {
        final String thisCode = item.cityCode.toString();
        if (null == cityCode) {
          cityCode = thisCode;
        }
        if (names.last == item.name) {
          cityCode = thisCode;
          break;
        }
      }
    }

    return cityCode;
  }

  String _statusText = "正在获取天气数据……";
  String _delayText = "";

  _timedTask(int sec, Future<void> Function() fn) async {
    if (sec <= 0) {
      _delayText = "";
      if (mounted) {
        setState(() {});
      }
      await fn();
    } else {
      _delayText = "$sec秒后重新尝试更新";
      if (mounted) {
        setState(() {});
      } else {
//        return;
      }
      Future.delayed(Duration(seconds: 1), () {
        _timedTask(sec - 1, fn);
      });
    }
  }

  static final List<String> _levels = ["省", "市", "区", "县"];
  Future<List<String>> _getCityNameFromNetwork() async {
    final List<String> cities = await GetCityByIP.get();
    if (null == cities) {
      return null;
    }

    for (int i = 0; i < cities.length; i++) {
      final city = cities[i];
      if (2 < city.length) {
        for (final l in _levels) {
          if (city.endsWith(l)) {
            cities[i] = city.substring(0, city.length - 1);
            break;
          }
        }
      }
    }

    return cities;
  }

  @override
  Widget build(BuildContext context) {
//    print("xxx build");

    return Container(
      width: _width,
      height: _height,
      child: (null != _weatherData) ? _buildWeather() : _buildLoading(),
    );
  }

  DateFormat _fmt = DateFormat("M-d HH:mm");
  Widget _buildWeather() {
    final List<String> xTitles = _buildXTitles(_weatherData.dates);
    final List<String> indicators = ["白天气温", "夜间气温"];
//    indicators.add("pm2.5 ${_weatherData.pm25}");
//    indicators.add("湿度 ${_weatherData.shidu}");
    indicators.add(_fmt.format(_weatherData.timestamp));

    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        RotatedBox(
          quarterTurns: 1,
          child: Container(
            width: _height,
            child: SimpleLineChart(
              title: _weatherData.fullCityName,
              lines: [_weatherData.highTemps, _weatherData.lowTemps],
              lineColors: [Colors.orange, Colors.blueAccent],
              xTitles: xTitles,
              topTitles: _weatherData.types,
              indicators: indicators,
              indicatorColors: [
                Colors.orange,
                Colors.blueAccent,
                Colors.grey[600],
//                Colors.grey[600],
//                Colors.grey[600],
              ],
              showZeroPoint: true,
            ),
          ),
        ),
        _buildCityPicker(),
      ],
    );
  }

  List<String> _buildXTitles(List<DateInt> dates) {
    int index = 0;
    final todayInt = DateInt(DateTime.now());
    return dates.map((e) {
      index++;
      String title;
      if ((1 == e.day) || (1 == (index % 7))) {
        title = "${e.month}.${e.day}";
      } else {
        title = "${e.day}";
      }
      if (todayInt.isSameDay(e)) {
        title += "(今)";
      }
      return title;
    }).toList();
  }

  String _trimLast(String fullName) {
    String upLevel = "";
    if (null != fullName) {
      final end = fullName.lastIndexOf(" ");
      if (0 < end) {
        upLevel = fullName.substring(0, end);
      }
    }
    return upLevel;
  }

  Widget _buildLoading() {
    return Stack(alignment: AlignmentDirectional.topEnd, children: [
      Column(
//              mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: _height * 10 / 100),
          Text(
            _statusText,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30),
          ),
          Text(
            _delayText,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30),
          ),
          buildLoadingView(topPadding: _height * 5 / 100),
        ],
      ),
      _buildCityPicker(),
    ]);
  }

  Widget _buildCityPicker() {
    return RotatedBox(
      quarterTurns: 1,
      child: Container(
        width: _height,
        child: Container(
//                    color: Colors.greenAccent,
          width: _height * 30 / 100,
//      height: _width,
          alignment: Alignment.topRight,
          margin: EdgeInsets.only(top: _width / 80, right: _height * 5 / 100),
          child: OutlineButton(
            child: Text("切换城市", style: TextStyle(fontSize: _width / 15)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return Scaffold(
                      appBar: AppBar(title: Text("选择城市")),
                      body: Container(
                        alignment: Alignment.topCenter,
                        width: _width,
//                        height: _height,
                        margin: EdgeInsets.only(top: _height * 2 / 100),
                        child: Container(
                          width: _width * 80 / 100,
//                          height: _height,
//                          alignment: Alignment.topCenter,
                          child: CityPicker(
                            autoFoucus: true,
                            initCity: _trimLast(_weatherSave.fullCityName),
                            onSelectedFn:
                                (String fullCityName, String cityCode) {
                              final changed = _weatherSave.setCityInfo(
                                  fullCityName, cityCode);

                              if (changed) {
                                _keyValueFile.setString(
                                    key: _weatherSaveKey,
                                    value: json.encode(_weatherSave));
                                _weatherData = null;
                                _startRefreshDataFromNetwork();
                              }

                              Navigator.of(context).pop();
                            },
                            hintText: "请输入城市",
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
