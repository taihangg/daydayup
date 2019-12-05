import 'dart:ui';
import '../common_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'assignment_data.dart';
import 'assignment_replenish_report.dart';

class ShowAllDailyDataView extends StatefulWidget {
  final AssignmentData assignmentData;
  ShowAllDailyDataView(this.assignmentData);

  @override
  State<StatefulWidget> createState() {
    return ShowAllDailyDataViewState();
  }
}

class ShowAllDailyDataViewState extends State<ShowAllDailyDataView> {
  ShowAllDailyDataViewState() {}

  double _width = MediaQueryData.fromWindow(window).size.width;
  double _height = MediaQueryData.fromWindow(window).size.height;

  List<DailyData> _allDailyDatas = [];
  int _year;
  bool _moreData = true;

  double _rowHeight;
  double _fontSize;
  @override
  initState() {
    super.initState();

    _fontSize = _width / 18;
    _rowHeight = _width * 10 / 100;
  }

  DailyData _getDailyData(int i) {
    if (i < _allDailyDatas.length) {
      return _allDailyDatas[i];
    }

    _getPrevoursYearData();

    return null;
  }

  _getPrevoursYearData() async {
    if (true != _moreData) {
      return;
    }
    final m = await widget.assignmentData.getPrevousYearNonZeroDailyData(_year);
    if (null == m) {
      _moreData = false;
      return;
    }

    assert(1 == m.length);
    m.forEach((int y, List<DailyData> datas) {
      _year = y;
      _allDailyDatas.addAll(datas);
    });

    setState(() {});
  }

  _onReplenishReportCommit(DateTime date, int oldNum, int newNum) async {
    assert(null != oldNum);
    assert(null != newNum);

    if (oldNum == newNum) {
      return;
    }

    _updateDailyData(date, newNum);

    if (oldNum < newNum) {
      await widget.assignmentData.addDailyDone(date, newNum - oldNum);
    } else {
      await widget.assignmentData.reduceDailyDone(date, oldNum - newNum);
    }
    setState(() {});
  }

  void _updateDailyData(DateTime date, int newNum) {
    final dateInt = DateInt(date);
    for (final e in _allDailyDatas) {
      if (e.date == dateInt.data) {
        e.done = newNum;
        break;
      }
    }
    return;
  }

  Widget _buildVerticalDivider([bool show = true]) {
    show = false;
    return Container(
//                color: Colors.red,
      width: _width * 2 / 100,
      height: _rowHeight,
      child: (true != show)
          ? null
          : VerticalDivider(
//                  thickness: 1.0,
//                  color: Colors.grey,
              ),
    );
  }

  Widget _buildTitleRow(
      {String sequenceStr,
      String dateStr,
      Color dateColor,
      String numStr,
      Color numColor}) {
    return Container(
//      color: Colors.yellow,
//      height: _width * 10 / 100,
//      width: _width * 10 / 100,
      alignment: Alignment.center,
      child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
//                  color: Colors.blue,
                  width: _width * 10 / 100,
                  height: _rowHeight,
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                      child: Text(sequenceStr,
                          style: TextStyle(
                            fontSize: _fontSize,
                            color: dateColor ?? Colors.blueAccent,
                          )))),
              _buildVerticalDivider(false),
              Container(
//                  color: Colors.red,
                  width: _width * 30 / 100,
                  height: _rowHeight,
                  alignment: Alignment.center,
                  child: FittedBox(
                      child: Text(dateStr,
                          style: TextStyle(
                              fontSize: _fontSize,
                              color: dateColor ?? Colors.grey[600])))),
              _buildVerticalDivider(false),
              Container(
//                  color: Colors.orange,
                  width: _width * 20 / 100,
                  height: _rowHeight,
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                      child: Text(numStr,
//                      textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: _fontSize,
                              color: numColor ?? Colors.grey[600])))),
              _buildVerticalDivider(false),
              Container(
//                color: Colors.cyanAccent,
                width: _width * 10 / 100,
                height: _rowHeight,
                alignment: Alignment.center,
              ),
            ],
          )),
    );
  }

  Widget _buildDataRow(
      {String sequenceStr,
      String dateStr,
      Color dateColor,
      int num,
      Color numColor}) {
    return Container(
//      color: Colors.yellow,
//      height: _width * 10 / 100,
//      width: _width * 10 / 100,
      alignment: Alignment.center,
      child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
//                  color: Colors.blue,
                  width: _width * 10 / 100,
                  height: _rowHeight,
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                      child: Text(sequenceStr,
                          style: TextStyle(
                            fontSize: _fontSize,
                            color: dateColor ?? Colors.blueAccent,
                          )))),
              _buildVerticalDivider(),
              Container(
//                  color: Colors.red,
                  width: _width * 30 / 100,
                  height: _rowHeight,
                  alignment: Alignment.center,
                  child: FittedBox(
                      child: Text(dateStr,
                          style: TextStyle(
                              fontSize: _fontSize,
                              color: dateColor ?? Colors.grey[600])))),
              _buildVerticalDivider(),
              Container(
//                  color: Colors.orange,
                  width: _width * 20 / 100,
                  height: _rowHeight,
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                      child: Text(numString(num),
//                      textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: _fontSize,
                              color: numColor ?? Colors.grey[600])))),
              _buildVerticalDivider(),
              Container(
//                color: Colors.cyanAccent,
                width: _width * 10 / 100,
                height: _rowHeight,
                alignment: Alignment.center,
                child: GestureDetector(
                  child: FittedBox(
                      child: Text("修改",
                          style: TextStyle(
                            fontSize: _fontSize,
                            color: Colors.lightBlueAccent,
                          ))),
                  onTap: () async {
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ReplenishReportPage.fromFixedDate(
                            dateStr: dateStr,
                            step: widget.assignmentData.step,
                            oldNum: num,
                            onCommitFn: _onReplenishReportCommit,
                          );
                        });
                    setState(() {});
                    return;
                  },
                ),
              ),
            ],
          )),
    );
  }

  String _formatDate(int date) {
    final dateInt = DateInt.fromInt(date);
    return "${dateInt.year}-" +
        ((dateInt.month < 10) ? "0" : "") +
        "${dateInt.month}-" +
        ((dateInt.day < 10) ? "0" : "") +
        "${dateInt.day}";
  }

  Widget _buildBody() {
    return Container(
      alignment: Alignment.topCenter,
      width: _width * 100 / 100,
      height: _height * 5 / 10,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (BuildContext context, int i) {
          // 从0开示

          final index = i ~/ 2;

          if (i.isOdd) {
            if (index + 1 < _allDailyDatas.length) {
              return Container(
                height: 5,
                child: Divider(
                  thickness: 0.3,
                  color: Colors.deepPurpleAccent,
                ),
              );
            } else {
              //最后一根分割线不显示
              return Container(
                  height: _width / 10, alignment: Alignment.center);
            }
          }

          final dailyData = _getDailyData(index);
          if (null != dailyData) {
            return _buildDataRow(
                sequenceStr: "${index + 1}:",
                dateStr: _formatDate(dailyData.date),
                num: dailyData.done);
          }

          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Center(
          child: FittedBox(
              child: Text(
        "${widget.assignmentData.name}",
        style: TextStyle(color: Colors.orange, fontSize: _width / 12),
      ))),
      children: [
        _buildTitleRow(
            sequenceStr: " ",
            dateStr: "日期",
            dateColor: Colors.black87,
            numStr: "数量",
            numColor: Colors.black87),
        SizedBox(height: _width / 50),
        SizedBox(
            height: 2,
//            color: Colors.yellow,
//            alignment: Alignment.bottomCenter,
            child: Divider(height: _width / 10, color: Colors.grey[800])),
        _buildBody(),
        SizedBox(
            height: 2,
            child: Divider(height: _width / 10, color: Colors.grey[800])),
        FlatButton(
          child: Text('返回',
              style: TextStyle(
                  color: Colors.lightBlueAccent, fontSize: _width / 15)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
