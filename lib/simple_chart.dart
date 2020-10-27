import 'dart:async';
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'common_util.dart';

class SimpleLineChart extends StatefulWidget {
  final Key key;
  final String title;
  final Color titleColor;
  final List<List<double>> lines;
  final List<Color> lineColors;
  final List<String> xTitles;
  List<String> topTitles;
  final double areaLine;

  final List<String> indicators;
  final List<Color> indicatorColors;
  final List<double> extraLines;
  final List<Color> extraLineColors;

  final bool showZeroPoint; // TODO
  final bool showZeroY;
  final int yIntervalLineNum; // TODO

  SimpleLineChart({
    this.key,
    this.title,
    this.titleColor,
    this.lines,
    this.lineColors,
    this.xTitles,
    this.topTitles,
    this.areaLine,
    this.indicators,
    this.indicatorColors,
    this.extraLines,
    this.extraLineColors,
    this.showZeroPoint = false,
    this.showZeroY = false,
    this.yIntervalLineNum,
  }) {
    assert(null != title);
    for (final line in lines) {
      assert(2 <= line.length);
      assert(line.length <= xTitles.length);
    }
    if (null != topTitles) {
      assert(topTitles.length == xTitles.length);
    }
    if (null != lineColors) {
      assert(lineColors.length == lines.length);
    }
    if ((null != extraLineColors) && (extraLineColors.isNotEmpty)) {
      assert(null != extraLines);
      assert(extraLineColors.length == extraLines.length);
    }
    if ((null != indicatorColors) && (indicatorColors.isNotEmpty)) {
      assert(null != indicators);
      assert(indicatorColors.length == indicators.length);
    }
    _getMaxMinY();
    _calcParameters();

    // 把 topTitles 都转成竖行的
    if (null != topTitles){
    topTitles = topTitles.map((element) {
      // var b = element.split("").join("\n");
      var b = element.split("").last;
      return b;
    }).toList();
    }
    return;
  }

  @override
  State<StatefulWidget> createState() {
    return SimpleLineChartState();
  }

  double _maxY;
  double _minY;
  _getMaxMinY() {
    _minY = _maxY = lines[0][0];
    int i = 0;
    lines.forEach((line) {
      line.forEach((e) {
        if (_maxY < e) {
          _maxY = e;
        }
        if (e < _minY) {
          _minY = e;
        }
      });
    });

    if (null != extraLines) {
      for (final e in extraLines) {
        if (_maxY < e) {
          _maxY = e;
        }
        if (e < _minY) {
          _minY = e;
        }
      }
    }

    assert(0 <= _maxY); //可能有问题，暂未处理
    return;
  }

  final double _width = MediaQueryData.fromWindow(window).size.width;
  int _statusType = 0;
  final _statusTypeLimit = 4;
  double _showMaxY;
  double _showMinY;
  double _leftSize;
  double _yInterval;
  bool _showZeroY = true;
  bool _showOnLinePoint = false;

  _calcParameters() {
    switch (_statusType) {
      case 0:
        {
          _showZeroY = true;
          _showOnLinePoint = true;
          break;
        }
      case 1:
        {
          _showZeroY = true;
          _showOnLinePoint = false;
          break;
        }
      case 2:
        {
          _showZeroY = false;
          _showOnLinePoint = false;
          break;
        }
      case 3:
        {
          _showZeroY = false;
          _showOnLinePoint = true;
          break;
        }
    }

    final newYIntervalLineNum = yIntervalLineNum ?? 4;

    _showMaxY = _maxY;
    _showMinY = _minY;

    // 计算_yInterval
    if (_showZeroY) {
      if (0 < _minY) {
        _showMinY = 0;
      } else if (_maxY < 0) {
        _showMaxY = 0;
      }
    }
    _yInterval = (_showMaxY - _showMinY) / newYIntervalLineNum;

    // 修正_yInterval，只留前两位数
    // _yInterval<10，则以 0.5 为刻度
    if (_yInterval <= 0.5) {
      _yInterval = 0.5;
    } else if (_yInterval < 10) {
      _yInterval = (_yInterval + 0.1).ceilToDouble(); // 下一个数
    } else {
      // 10<=_yInterval，则只保留前两位数为非0
      final zeroCount = _yInterval.toInt().toString().length - 2;
      int unit = 1;
      for (int i = 0; i < zeroCount; i++) {
        unit *= 10;
      }
      _yInterval = (_yInterval / unit).ceilToDouble() * unit;
    }

    final mid = ((_showMaxY + _showMinY) / 2).floorToDouble();
    _showMaxY = mid + 2 * _yInterval;
    _showMinY = mid - 2 * _yInterval;

    if ((0 <= _minY) || (_maxY <= 0)) {
      if ((0 <= _minY) && (_showMinY <= 0)) {
        // _showMinY下移跨过了y=0
        _showMaxY += -_showMinY;
        _showMinY = 0;
      } else if ((_maxY <= 0) && (0 <= _showMaxY)) {
        // _showMaxY上移跨过了y=0
        _showMinY -= _showMaxY;
        _showMaxY = 0;
      }

      // 多显示一部分，不然最上面的线可能不显示
      if (0 <= _minY) {
        _showMaxY += _yInterval * 2 / 10;
      } else if (_maxY <= 0) {
        _showMaxY += _yInterval * 2 / 10;
//        _showMinY -= _yInterval * 2 / 10;
      }
    } else {
      // 要显示y=0轴
      _showMaxY = (_maxY / _yInterval).ceil() * _yInterval;
      _showMinY = -((-_minY) / _yInterval).ceil() * _yInterval;
    }

//    print(
//        "_showZeroY=$_showZeroY _maxY=${_maxY} _minY=${_minY} _showMaxY=$_showMaxY _showMinY=$_showMinY _yInterval=$_yInterval");

    assert(0.0 < _yInterval);
    assert(_showMaxY != _showMinY);

    // 计算显示y坐标需要预留的左边距宽度
    final intervalLen = _yTitle(_yInterval).length;
    final maxYLen = _yTitle(_showMaxY).length;
    final minYLen = _yTitle(_showMinY).length;
    int leftSize = intervalLen;
    if (leftSize < maxYLen) {
      leftSize = maxYLen;
    }
    if (leftSize < minYLen) {
      leftSize = minYLen;
    }
    _leftSize = leftSize * (_width * 2 / 100);

    return;
  }

  _calcParameters2() {
    switch (_statusType) {
      case 0:
        {
          _showZeroY = true;
          _showOnLinePoint = false;
          break;
        }
      case 1:
        {
          _showZeroY = true;
          _showOnLinePoint = true;
          break;
        }
      case 2:
        {
          _showZeroY = false;
          _showOnLinePoint = true;
          break;
        }
      case 3:
        {
          _showZeroY = false;
          _showOnLinePoint = false;
          break;
        }
    }

    final newYIntervalLineNum = yIntervalLineNum ?? 4;

    _showMaxY = _maxY;
    _showMinY = _minY;

//    assert(_showMinY != _showMaxY);

    // 计算_yInterval
//    _yInterval = (_showMaxY - _showMinY) / newYIntervalLineNum;
    if (_showZeroY) {
      if (0 < _minY) {
        _showMinY = 0;
        _yInterval = _showMaxY / newYIntervalLineNum;
      } else if (_maxY < 0) {
        _showMaxY = 0;
        _yInterval = (-_showMinY) / newYIntervalLineNum;
      } else {
        _yInterval = (_showMaxY - _showMinY) / newYIntervalLineNum;
      }
    } else {
      _yInterval = (_showMaxY - _showMinY) / newYIntervalLineNum;
    }

    // 修正_yInterval，只留前两位数
    if (_yInterval < 10) {
      // _yInterval<10，则以 0.5 为刻度
      if (_yInterval <= 0.5) {
        _yInterval = 0.5;
      } /*else if (_yInterval.floorToDouble() == _yInterval) {
        // 不变
      } else if (_yInterval <= _yInterval.floorToDouble() + 0.5) {
        _yInterval = _yInterval.floorToDouble() + 0.5;
      } */
      else {
        _yInterval = _yInterval.ceilToDouble();
//        _yInterval = _yInterval.floorToDouble();
      }
    } else {
      // 10<=_yInterval，则只保留前两位数为非0
      final zeroCount = _yInterval.toInt().toString().length - 2;
      int unit = 1;
      for (int i = 0; i < zeroCount; i++) {
        unit *= 10;
      }
      _yInterval = (_yInterval / unit).ceilToDouble() * unit;
    }
    assert(0.0 < _yInterval);

    if ((0 <= _minY) || (_maxY <= 0)) {
      if (_showMaxY == _showMinY) {
        // 相等的情况
        _showMaxY += _yInterval;
        _showMinY -= _yInterval;
        if ((0 <= _minY) && (_showMinY <= 0)) {
          _showMaxY -= _showMinY;
          _showMinY = 0;
        } else if ((_maxY <= 0) && (0 <= _showMaxY)) {
          _showMinY -= _showMaxY;
          _showMaxY = 0;
        }
      } else {
        _showMaxY += _yInterval / 2;
        _showMinY -= _yInterval / 2;
        // 不能跨过y=0线
        if (0 <= _minY) {
          if ((_showZeroY) || (_showMinY < 0)) {
            _showMinY = 0;
          }
        } else if (_maxY <= 0) {
          if ((_showZeroY) || (0 < _showMaxY)) {
            _showMaxY = 0;
          }
        }
      }
    } else {
      // 要显示y=0轴
      _showMaxY = (_maxY / _yInterval).ceil() * _yInterval;
      _showMinY = -((-_minY) / _yInterval).ceil() * _yInterval;
    }

    // 根据_showMaxY和_showMinY所在范围，修正_showMaxY和_showMinY
//    if (0 <= _showMinY) {
//      // 0 <= _showMinY < _showMaxY
////      _calcParametersAllPositive();
//      _showMaxY = _yInterval * newYIntervalLineNum + _showMinY;
//      _showMaxY = ((_showMaxY - _showMinY) / _yInterval).ceil() * _yInterval +
//          _showMinY;
//    } else if (_showMaxY <= 0) {
//      // _showMinY < _showMaxY <= 0
////      _calcParametersAllNegative();
////      _showMinY = _showMinY =
////          -((_showMaxY - _showMinY) / _yInterval).ceil() * _yInterval +
////              _showMaxY;
//    } else {
//      // _showMinY < 0 < _showMaxY
//      // 需要显示y=0这个刻度线
////      _calcParametersOnePositiveOneNegative();
//      _showMaxY = (_showMaxY / _yInterval).ceil() * _yInterval;
//      _showMinY = -((-_showMinY) / _yInterval).ceil() * _yInterval;
//    }

//    print(
//        "_showZeroY=$_showZeroY _maxY=${_maxY} _minY=${_minY} _showMaxY=$_showMaxY _showMinY=$_showMinY _yInterval=$_yInterval");

    assert(_showMaxY != _showMinY);
    // 计算显示y坐标需要预留的左边距宽度
    final intervalLen = _yTitle(_yInterval).length;
    final maxYLen = _yTitle(_showMaxY).length;
    final minYLen = _yTitle(_showMinY).length;
    int leftSize = intervalLen;
    if (leftSize < maxYLen) {
      leftSize = maxYLen;
    }
    if (leftSize < minYLen) {
      leftSize = minYLen;
    }
    _leftSize = leftSize * (_width * 2 / 100);

    return;
  }

  _calcParameters1() {
    switch (_statusType) {
      case 0:
        {
          _showZeroY = true;
          _showOnLinePoint = false;
          break;
        }
      case 1:
        {
          _showZeroY = true;
          _showOnLinePoint = true;
          break;
        }
      case 2:
        {
          _showZeroY = false;
          _showOnLinePoint = true;
          break;
        }
      case 3:
        {
          _showZeroY = false;
          _showOnLinePoint = false;
          break;
        }
    }

    final newYIntervalLineNum = yIntervalLineNum ?? 4;

    _showMaxY = (_maxY + 1).floorToDouble();

    final minY = _minY.floor();
    if (0 != minY) {
      _showMinY = minY - 1.0;
    } else {
      _showMinY = minY.toDouble();
    }
//    _showMinY = (_minY - 1).ceilToDouble();

//    if (_showMaxY.toInt() == _showMinY.toInt()) {
//      _showMaxY = (_showMaxY.toInt() + 1).toDouble();
////      _minY = (_minY.toInt() - 1).toDouble();
//    }
    assert(_showMinY != _showMaxY);

    // 计算_yInterval
//    _yInterval = (_showMaxY - _showMinY) / newYIntervalLineNum;
    if (_showZeroY) {
      if (0 < _showMinY) {
        _showMinY = 0;
        _yInterval = _showMaxY / newYIntervalLineNum;
      } else if (_showMaxY < 0) {
        _showMaxY = 0;
        _yInterval = (-_showMinY) / newYIntervalLineNum;
      } else {
        _yInterval = (_showMaxY - _showMinY) / newYIntervalLineNum;
      }
    } else {
      _yInterval = (_showMaxY - _showMinY) / newYIntervalLineNum;
    }

//    if (0 < _showMaxY * _showMinY) {
//      // 范围没有跨越y=0,同为正数或负数
//
//    } else {
//      // 一正一副，或者有0，0<=_showMaxY,_showMinY<=0，就需要显示y=0轴
////      _showZeroY = true;
//    }

    // 一正一副，或者有0，0<=_showMaxY,_showMinY<=0，就需要显示y=0轴
//    if (_showMaxY * _showMinY <= 0) {
//      _showMinY = _yInterval * (_showMinY / _yInterval).floor();
//    }

    // 修正_yInterval，只留前两位数
    if (_yInterval < 10) {
      // _yInterval<10，则以 0.5 为刻度
      if (_yInterval <= 0.5) {
        _yInterval = 0.5;
      } else if (_yInterval.floorToDouble() == _yInterval) {
        // 不变
      } else if (_yInterval < _yInterval.floorToDouble() + 0.5) {
        _yInterval = _yInterval.floorToDouble() + 0.5;
      } else {
        _yInterval = _yInterval.ceilToDouble();
      }
    } else {
      // 10<=_yInterval，则只保留前两位数为非0
      final zeroCount = _yInterval.toInt().toString().length - 2;
      int unit = 1;
      for (int i = 0; i < zeroCount; i++) {
        unit *= 10;
      }
      _yInterval = (_yInterval / unit).ceilToDouble() * unit;
    }
    assert(0.0 <= _yInterval);

    // 根据_showMaxY和_showMinY所在范围，修正_showMaxY和_showMinY
    if (0 <= _showMinY) {
      // 0 <= _showMinY < _showMaxY
//      _calcParametersAllPositive();
      _showMaxY = _yInterval * newYIntervalLineNum + _showMinY;
      _showMaxY = ((_showMaxY - _showMinY) / _yInterval).ceil() * _yInterval +
          _showMinY;
    } else if (_showMaxY <= 0) {
      // _showMinY < _showMaxY <= 0
//      _calcParametersAllNegative();
//      _showMinY = _showMinY =
//          -((_showMaxY - _showMinY) / _yInterval).ceil() * _yInterval +
//              _showMaxY;
    } else {
      // _showMinY < 0 < _showMaxY
      // 需要显示y=0这个刻度线
//      _calcParametersOnePositiveOneNegative();
      _showMaxY = (_showMaxY / _yInterval).ceil() * _yInterval;
      _showMinY = -((-_showMinY) / _yInterval).ceil() * _yInterval;
    }

    print(
        "_maxY=${_maxY} _minY=${_minY} _showMaxY=$_showMaxY _showMinY=$_showMinY _yInterval=$_yInterval");

    // 计算显示y坐标需要预留的左边距宽度
    final intervalLen = _yTitle(_yInterval).length;
    final maxYLen = _yTitle(_showMaxY).length;
    final minYLen = _yTitle(_showMinY).length;
    int leftSize = intervalLen;
    if (leftSize < maxYLen) {
      leftSize = maxYLen;
    }
    if (leftSize < minYLen) {
      leftSize = minYLen;
    }
    _leftSize = leftSize * (_width * 2 / 100);

    return;
  }

  String _yTitle(value) {
    if ((_yInterval < 10) && (0 != value)) {
      //显示一位小数
      return "${value.toStringAsFixed(1)}";
    }
    return "${value.toInt()}";
  }
}

class SimpleLineChartState extends State<SimpleLineChart> {
  double _titleWidth;
  double _indicatorWidth;
  double _indicatorHeight;

  final StreamController<LineTouchResponse> _controller = StreamController();

  @override
  void initState() {
    super.initState();

    _controller.stream.distinct().listen((LineTouchResponse response) {});
    _indicatorWidth = widget._width * 40 / 100;
    _titleWidth = _indicatorWidth;
    _indicatorHeight = widget._width * 5 / 100;
//    _getMaxMinY();
//    _calcParameters();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    _calcParameters();
    return AspectRatio(
      aspectRatio: 1.23,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(color: Colors.black, blurRadius: 8, spreadRadius: 0)
          ],
          gradient: LinearGradient(
            colors: [
              //背景色
//              Colors.cyanAccent[100], Colors.cyanAccent[100],
//              Colors.grey[50], Colors.grey[50],
//              Color(0xFFBFEFFF), Color(0xFFBFEFFF),
//              Color(0xFFFFFACD), Color(0xFFFFFACD),
              Color(0xFFFFFFF0), Color(0xFFFFFFF0),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
//          color: Color(0xff232d37),
        ),
        child: Stack(
          children: <Widget>[
            _buildTitleLine(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: widget._width * 16 / 100), // 上边距
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(right: 15.0), //右边距
                        child: LineChart(_lineChartData(),
                            swapAnimationDuration:
                                Duration(milliseconds: 400)))),
                SizedBox(height: widget._width / 30),
              ],
            ),
          ],
        ),
      ),
    );
  }

  final List<Color> _colors = [
    Colors.blueAccent,
    Colors.orange,
    Colors.purpleAccent,
//    Color(0xff845bef),
//    Colors.deepOrangeAccent,
    Colors.yellow,
    Colors.cyanAccent,

    Colors.indigo,
    Colors.redAccent,
  ];
  Color _getColor(List<Color> colors, int index) {
    return _getAppointedColor(colors, index) ?? _getDefaultColor(index);
  }

  Color _getAppointedColor(List<Color> colors, int index) {
    if ((null != colors) && (index < colors.length)) {
      return colors[index];
    } else {
      return null;
    }
  }

  Color _getDefaultColor(int index) {
    return _colors[index % _colors.length];
  }

  String _topTitle(value) {
    // return "";
    return widget.topTitles[value.toInt()];
  }

  Widget _buildTitleLine() {
    final double size = widget._width / 10;
    final double padding = widget._width * 2 / 100;
    final datas = <Widget>[
      SizedBox(width: padding),
      Container(
          width: _indicatorHeight * 2,
          height: _indicatorHeight * 2,
          alignment: Alignment.center,
          child: GestureDetector(
            child: Container(
                width: _indicatorHeight * 2,
                height: _indicatorHeight * 2,
                margin: EdgeInsets.only(top: widget._width * 0.7 / 100),
                decoration: BoxDecoration(
                  color: Colors.indigoAccent,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[700], blurRadius: 8, spreadRadius: 0)
                  ],
                ),
                child: FittedBox(
                    child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Icon(Icons.refresh,
//                    size: _width * 15 / 100,
                        color: Colors.cyanAccent.withOpacity(
                            (0 == (widget._statusType & 1)) ? 1.0 : 0.7)),
                    Text("${widget._statusType + 1}",
                        style: TextStyle(color: Colors.white)),
                  ],
                ))),
            onTap: () {
              widget._statusType =
                  (widget._statusType + 1) % widget._statusTypeLimit;
//              _getMaxMinY();
              widget._calcParameters();
              setState(() {});
            },
          )),
      SizedBox(width: padding),
      Container(
          width: _titleWidth,
          height: _indicatorHeight * 2,
          alignment: Alignment.centerLeft,
          child: FittedBox(
              child: Text(
            widget.title,
            style: TextStyle(
              color: widget.titleColor ?? _getDefaultColor(0),
              fontSize: size * 1.5,
              fontWeight: FontWeight.bold,
//          letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ))),
      SizedBox(width: padding),
//      Container(
//          height: _indicatorHeight,
//          child: FittedBox(
//              child: Indicator(
//            color: _colors[0],
//            text: "数据",
//            textColor: _colors[0],
//            isSquare: true,
//            size: size,
//          ))),
    ];

    if (null != widget.indicators) {
      for (int index = 0; index < widget.indicators.length;) {
        List<Widget> children = [];
        final color = _getAppointedColor(widget.indicatorColors, index) ??
            _getDefaultColor(
                index + widget.lines.length); // 跳开数据线的个数，跟默认数据颜色区分一下
        children.add(Container(
//            color: Colors.greenAccent,
//            width: _indicatorWidth,
            height: _indicatorHeight,
            alignment: Alignment.centerLeft,
            child: FittedBox(
                child: Indicator(
              color: color,
              text: widget.indicators[index],
              textColor: color,
              isSquare: true,
              size: size * 2,
            ))));
        index++;

        if (index < widget.indicators.length) {
          final color = _getAppointedColor(widget.indicatorColors, index) ??
              _getDefaultColor(
                  index + widget.lines.length); // 跳开数据线的个数，跟默认数据颜色区分一下
          children.add(Container(
//              color: color,
//              width: _indicatorWidth,
              height: _indicatorHeight,
              alignment: Alignment.centerLeft,
              child: FittedBox(
                  child: Indicator(
                color: color,
                text: widget.indicators[index],
                textColor: color,
                isSquare: true,
                size: size * 2,
              ))));
          index++;
        }

        assert(children.isNotEmpty);
        datas.add(Padding(
            padding: EdgeInsets.only(right: 5),
            child: Container(
//            width: _indicatorWidth,
//            height: _indicatorHeight * 2,
//        alignment: Alignment.centerLeft,
                child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ))));
      }

      datas.add(SizedBox(width: padding));
    }

    return Container(
        // 放最下面，显示在最底层
        height: _indicatorHeight * 2,
        alignment: Alignment.topLeft,
        child: FittedBox(
//          fit: BoxFit.fitHeight,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: datas,
          ),
        ));
  }

  List<MapEntry<int, List<LineBarSpot>>> _buildShowingTooltipIndicators(
      List<LineChartBarData> lines) {
    List<MapEntry<int, List<LineBarSpot>>> list = [];

    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      for (int x = 0; x < line.spots.length; x++) {
        list.add(MapEntry(x, [LineBarSpot(line, lineIndex, line.spots[x])]));
      }
    }
    return list;
  }

  LineChartData _lineChartData() {
//    _calcParameters();

    final List<LineChartBarData> lines = _buildDatalines();
    final List<MapEntry<int, List<LineBarSpot>>> tooltipIndicators =
        _buildShowingTooltipIndicators(lines);

    final LineTouchData lineTouchData = _buildLineTouchData();

//    lines.addAll(_buildAveragelines());
    _addSpecialLine(lines);

    final _extraLines = _buildExtraLines();

    assert(0 < widget._yInterval);

    return LineChartData(
      showingTooltipIndicators: tooltipIndicators,
      lineTouchData: lineTouchData,
      extraLinesData: _extraLines,
      gridData: FlGridData(
        show: true, // 显示横线
        horizontalInterval: widget._yInterval,
        drawVerticalGrid: widget._showOnLinePoint ? false : true, // 不显示点的时候显示竖线
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 10, //下边距
          textStyle: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: widget._width / 30,
          ),
          margin: widget._width * 1 / 100, // x轴与x坐标标记的间距
          getTitles: (value) {
            final x = value.toInt();
            if (x < widget.xTitles.length) {
              return "${widget.xTitles[x]}";
            }
            return ".$x";
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          textStyle: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: widget._width / 30,
          ),
          interval: widget._yInterval,
          getTitles: widget._yTitle,
          margin: widget._width * 2 / 100, // 左边距(数据区与y轴的距离)
          reservedSize: widget._leftSize, //y轴左边距
        ),
        topTitles: SideTitles(
          showTitles: (null == widget.topTitles) ? false : true,
          textStyle: TextStyle(
            color: Colors.deepPurpleAccent,
            fontWeight: FontWeight.bold,
            fontSize: widget._width / 30,
          ),
//          interval: _yInterval,
          getTitles: _topTitle,
          margin: widget._width * 1 / 100, // 坐标部分与顶部title的距离
          reservedSize: widget._width / 100, //顶部title与上边的距离
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 1), // x轴
            left: BorderSide(color: Colors.grey, width: 1), // y轴
            right: BorderSide(color: Colors.transparent),
            top: BorderSide(color: Colors.transparent),
          )),
//      minX: 0,
//      maxX: 0,
      minY: widget._showMinY,
      /*(0 <= widget._minY)
          ? (widget.showZeroY ? 0 : (widget._minY / 1.1).floorToDouble())
          : (widget._minY * 1.1).floorToDouble(),*/
      maxY: widget._showMaxY, //(widget._maxY * 1.1).ceilToDouble(),
      lineBarsData: lines,
    );
  }

  LineTouchData _buildLineTouchData() {
    return LineTouchData(
      enabled: false,
      touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipRoundedRadius: 8,
          tooltipBottomMargin: 1,
          getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
            return lineBarsSpot.map((LineBarSpot spot) {
              return LineTooltipItem(
                numString(spot.y.toInt()),
                TextStyle(
                    fontSize: widget._width / 25,
                    color: _getColor(widget.lineColors, spot.barIndex)
                        .withOpacity(0.7),
//                    color: (0 == spot.barIndex) ? Colors.red : Colors.grey,
                    fontWeight: FontWeight.bold),
              );
            }).toList();
          }),
    );
  }

  List<LineChartBarData> _buildDatalines() {
    final double barWidth = widget._width * 1 / 100;

    List<LineChartBarData> lines;
    if (!widget.showZeroPoint &&
        ((0 == widget._statusType) || (1 == widget._statusType))) {
      lines = _data2NoZeroLine(barWidth);
    } else {
      lines = _data2SimpleLines(barWidth);
    }

    return lines;
  }

  ExtraLinesData _buildExtraLines() {
    final double barWidth = widget._width * 1 / 100;

    List<VerticalLine> lines = [];

    if (null != widget.extraLines) {
      for (int i = 0; i < widget.extraLines.length; i++) {
        lines.add(VerticalLine(
          y: widget.extraLines[i],
          color: _getAppointedColor(widget.extraLineColors, i) ??
              _getDefaultColor(i + widget.lines.length), // 跳开数据线的个数，跟默认数据颜色区分一下
          strokeWidth: barWidth,
        ));
      }
    }

    return ExtraLinesData(
      showHorizontalLines: false,
      horizontalLines: [],
      showVerticalLines: lines.isNotEmpty,
      verticalLines: lines,
    );
  }

  _addSpecialLine(List<LineChartBarData> lines) {
    // 防止显示变形，加一条不可见的线
    final double barWidth = widget._width * 1 / 100;
    // 如果没有线，则需要构造一个不显示的线，否则不显示坐标
    final double d = widget.lines[0][0];
    lines.add(LineChartBarData(
      spots: List.generate(widget.xTitles.length, (int i) {
        return FlSpot(i.toDouble(), d);
      }),
      isCurved: true,
      colors: [Colors.transparent], // 透明色
      barWidth: barWidth,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false), // 显示数据点
    ));
  }

  BarAreaData _barAreaData(bool show, Color color, double cutOffY) {
    return BarAreaData(
      show: show,
      colors: [color],
      cutOffY: cutOffY,
      applyCutOffY: true,
    );
  }

  BarAreaData _aboveBarData() {
    return _barAreaData(
      (null == widget.areaLine) ? false : true,
      Colors.lightGreenAccent.withOpacity(0.6),
      widget.areaLine ?? 0,
    );
  }

  BarAreaData _belowBarData() {
    return _barAreaData(
      (null == widget.areaLine) ? false : true,
      Colors.cyanAccent.withOpacity(0.6),
      widget.areaLine ?? 0,
    );
  }

  FlDotData _buildDotData(int pointCount, double barWidth, int colorIndex) {
    return FlDotData(
      show: ((1 == pointCount) || widget._showOnLinePoint) ? true : false,
      dotSize: barWidth * 1.1,
      dotColor: _getColor(widget.lineColors, colorIndex),
    );
  }

  List<LineChartBarData> _data2SimpleLines(double barWidth) {
    final List<LineChartBarData> lines = [];

    for (int lineIndex = 0; lineIndex < widget.lines.length; lineIndex++) {
      final line = widget.lines[lineIndex];
      double x = 0.0; // x坐标
      List<FlSpot> points = line.map((e) {
        assert(null != e);
        return FlSpot(x++, e);
      }).toList();

      lines.add(LineChartBarData(
//      show: false,
        spots: points,
        isCurved: true,
        colors: [_getColor(widget.lineColors, lineIndex)],
        barWidth: barWidth,
        isStrokeCapRound: true, // 端点圆滑
        dotData: _buildDotData(points.length, barWidth, lineIndex), // 显示数据点
        belowBarData: _belowBarData(),
        aboveBarData: _aboveBarData(),
      ));
    }

    return lines;
  }

  List<LineChartBarData> _data2NoZeroLine(double barWidth) {
    final List<LineChartBarData> lines = [];

    for (int lineIndex = 0; lineIndex < widget.lines.length; lineIndex++) {
      final line = widget.lines[lineIndex];

      List<FlSpot> points = [];
      double x = 0.0;

      for (final d in line) {
        if ((null != d) && (0.0 != d)) {
          points.add(FlSpot(x, d));
        } else {
          if (points.isNotEmpty) {
            lines.add(LineChartBarData(
              spots: points,
              isCurved: true,
              colors: [_getColor(widget.lineColors, lineIndex)],
              barWidth: barWidth,
              isStrokeCapRound: true,
              dotData:
                  _buildDotData(points.length, barWidth, lineIndex), // 显示数据点
              belowBarData: _belowBarData(),
              aboveBarData: _aboveBarData(),
            ));
            points = [];
          }
        }
        x++;
      }

      if (points.isNotEmpty) {
        lines.add(LineChartBarData(
          spots: points,
          isCurved: true,
          colors: [_getColor(widget.lineColors, lineIndex)],
          barWidth: barWidth,
          isStrokeCapRound: true,
          dotData: _buildDotData(points.length, barWidth, lineIndex), // 显示数据点
          belowBarData: _belowBarData(),
          aboveBarData: _aboveBarData(),
        ));
        points = [];
      }
    }

    return lines;
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    Key key,
    this.color,
    this.text,
    this.isSquare,
    this.size = 16,
    this.textColor = const Color(0xff505050),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
//      mainAxisAlignment: MainAxisAlignment.start,
//      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(width: size / 4),
        Text(
          text,
          style: TextStyle(
              fontSize: size, fontWeight: FontWeight.bold, color: textColor),
          softWrap: true,
        )
      ],
    );
  }
}
