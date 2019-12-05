import 'dart:ui';
import 'package:flutter/material.dart';
import 'plugins/color_loader_2.dart';
import 'plugins/color_loader_3.dart';

String ValidateNumFn(String value) {
  if (value.isEmpty) {
    return null;
  }

  if ("0" == value) {
    return null;
  }

  final numEP = RegExp(r'^[1-9][0-9]*$');
  if (numEP.hasMatch(value)) {
    return null;
  }
  return '请输入正确的数字';
}

String numString(int num, [bool doubleLine]) {
  assert(null != num);

  bool negative = false;
  if (num < 0) {
    negative = true;
    num = -num;
  }

  if (0 == num) {
    return "0";
  }

  String text = negative ? "-" : "";
  int wan = (num / 10000).toInt();
  int left = num % 10000;

  if (0 != wan) {
    text = "$wan万";
  }

  if (0 != left) {
    if (("" != text) && (true == doubleLine)) {
      text += "\n";
    }
    text += "$left";
  }

  return text;
}

bool isToday(DateTime dt) {
  return isSameDay(dt, DateTime.now());
}

bool isSameDay(DateTime dt1, DateTime dt2) {
  if ((null != dt1) &&
      (null != dt2) &&
      (dt1.day == dt2.day) &&
      (dt1.month == dt2.month) &&
      (dt1.year == dt2.year)) {
    return true;
  }
  return false;
}

class DateInt {
  int _data;
  DateInt(DateTime date) {
    assert(null != date);
    _data = _dt2Int(date);
//    _test();
  }
  DateInt.fromInt(int dt) {
    _data = dt;
  }

  int _dt2Int(DateTime date) {
    if (null != date) {
      return (date.year * 10000 + date.month * 100 + date.day);
    }
    return null;
  }

  DateTime get dt {
    if (null != _data) {
      return DateTime(year, month, day);
    }
    return null;
  }

  int get data => _data;

  int get year {
    assert(null != _data);
    return (_data ~/ 10000);
  }

  int get month {
    (_data ~/ 10000);
    return (_data % 10000 ~/ 100);
  }

  int get day {
    (_data ~/ 10000);
    return (_data % 100);
  }

  bool isSameDay(DateInt other) {
    assert(null != _data);
    assert(null != other);
    assert(null != other._data);

    return (_data == other._data);

//    if ((null != _data) &&
//        (null != other) &&
//        (null != other._data) &&
//        (_data == other._data)) {
//      return true;
//    }
//    return false;
  }

  DateInt get prevousDay {
    assert(null != _data);

    if (1 != day) {
      return DateInt.fromInt(_data - 1);
    }

    // 1==day
    //  1  2  3  4  5  6  7  8  9 10 11 12
    // 31 2? 31 30 31 30 31 31 30 31 30 31
    switch (month) {
      case 1 + 1: // 2
      case 3 + 1: // 4
      case 5 + 1: // 6
      case 7 + 1: // 8
      case 8 + 1: // 9
      case 10 + 1: // 11
        {
          // 同一年内，上一个月是31天
          return DateInt.fromInt(_data - 100 + 30);
        }
      case 4 + 1: // 5
      case 6 + 1: // 7
      case 9 + 1: // 10
      case 11 + 1: // 12
        {
          // 同一年内，上一个月是30天
          return DateInt.fromInt(_data - 100 + 29);
        }
      case 3:
        {
          // 2月特殊处理
          return DateInt(DateTime(year, 3, 0));
        }
      case 1:
        {
          // 1月1日
          return DateInt.fromInt(_data - 10000 + 11 * 100 + 30);
        }
      default:
        {
          assert(false);
        }
    }
  }

  DateInt get nextDay {
    assert(null != _data);

    //  1  2  3  4  5  6  7  8  9 10 11 12
    // 31 2? 31 30 31 30 31 31 30 31 30 31

    final m = month;
    final d = day;

    if (d < 28) {
      return DateInt.fromInt(_data + 1);
    }

    if (2 == month) {
      return DateInt(DateTime(year, month, d + 1));
    }

    if (d < 30) {
      return DateInt.fromInt(_data + 1);
    }

//    return DateInt(DateTime(year, month, _d + 1));

    assert(30 <= d);

    {
      // 年、月 都不变得情况
      if ((30 == d) &&
          ((1 == m) ||
              (3 == m) ||
              (5 == m) ||
              (7 == m) ||
              (8 == m) ||
              (10 == m) ||
              (12 == m))) {
        return DateInt.fromInt(_data + 1);
      }

      if (12 != month) {
        // 跨月
        return DateInt.fromInt(_data + 100 - d + 1);
      } else {
        // 12.31 跨年
        return DateInt.fromInt(_data + 10000 - 11 * 100 - 30);
      }
    }
  }

  static _testPrevousDay() {
    Map<int, int> _pairs = {
      20190101: 20181231,
      20190201: 20190131,
      20190301: 20190228,
      20190401: 20190331,
      20190501: 20190430,
      20190601: 20190531,
      20190701: 20190630,
      20190801: 20190731,
      20190901: 20190831,
      20191001: 20190930,
      20191101: 20191031,
      20191201: 20191130,
    };

    _pairs.forEach((int day, int prevousDay) {
      if (DateInt.fromInt(day).prevousDay.data != prevousDay) {
        print("_testPrevousDay $day!=$prevousDay");
        assert(false);
      }
    });
  }

  static void _testNextDay() {
    Map<int, int> _pairs = {
      // 最后一天
      20190131: 20190201,
      20190228: 20190301,
      20190331: 20190401,
      20190430: 20190501,
      20190531: 20190601,
      20190630: 20190701,
      20190731: 20190801,
      20190831: 20190901,
      20190930: 20191001,
      20191031: 20191101,
      20191130: 20191201,
      20191231: 20200101,

      // 所有月的29
      20190129: 20190130,
      20190329: 20190330,
      20190429: 20190430,
      20190529: 20190530,
      20190629: 20190630,
      20190729: 20190730,
      20190829: 20190830,
      20190929: 20190930,
      20191029: 20191030,
      20191129: 20191130,
      20191229: 20191230,

      // 大月的30
      20190130: 20190131,
      20190330: 20190331,
      20190530: 20190531,
      20190730: 20190731,
      20190830: 20190831,
      20191030: 20191031,
      20191230: 20191231,
    };

    _pairs.forEach((int day, int nextDay) {
      if (DateInt.fromInt(day).nextDay.data != nextDay) {
        print("_testNextDay $day!=$nextDay");
        assert(false);
      }
    });
  }

  static bool _tested;
  static _test() {
    if (true == _tested) {
      return;
    }
    _tested = true;

    _testPrevousDay();
    _testNextDay();
  }
}

Widget buildLoadingView({double topPadding, double height}) {
  final double _width = MediaQueryData.fromWindow(window).size.width;
  final double _height = MediaQueryData.fromWindow(window).size.height;
  return Container(
//      color: Colors.orange,
      alignment: Alignment.topCenter,
      height: height ?? (_height / 2),
      child: Padding(
          padding: EdgeInsets.only(top: topPadding ?? (_height / 5)),
//        children: [
//          SizedBox(height: paddingHeight ?? (height / 5)),
          child: Stack(
            alignment: AlignmentDirectional.center,
            overflow: Overflow.visible,
            children: [
//              CircularProgressIndicator(),
              ColorLoader2(),
              ColorLoader3(radius: _width / 8, dotRadius: _width / 20),
            ],
          )
//        ],
          ));
}
