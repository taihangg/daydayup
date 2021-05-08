import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../common_util.dart';
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

    return;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
          child: FittedBox(
              child: Text("${widget.assignmentData.name}",
                  style:
                      TextStyle(color: Colors.orange, fontSize: _width / 12)))),
      titlePadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      children: [
        _buildTitleRow(
            sequenceStr: " ",
            dateStr: "日期",
            dateColor: Colors.black87,
            numStr: "数量",
            numColor: Colors.black87),
        SizedBox(height: _width * 1 / 100),
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

  DailyData _getDailyData(int i) {
    if (i < _allDailyDatas.length) {
      return _allDailyDatas[i];
    }

    _fetchPrevYearData();

    return null;
  }

  _fetchPrevYearData() async {
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

    if (mounted) {
      setState(() {});
    }

    return;
  }

  void _onReplenishReportCommit_setNum(
      DateTime date, int line1Num, int line2Num) async {
    assert(null != line1Num);
    assert(null != line2Num);

    if (line1Num == line2Num) {
      return;
    }

    _updateDailyData(date, line2Num);

    if (line1Num < line2Num) {
      await widget.assignmentData.addDailyDone(date, line2Num - line1Num);
    } else {
      await widget.assignmentData.reduceDailyDone(date, line1Num - line2Num);
    }
    setState(() {});
    return;
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
      int date,
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
                      child: Text(_formatDate(date),
                          style: TextStyle(
                              fontSize: _fontSize,
                              color: dateColor ?? Colors.cyan[600])))),
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
                          // return ReplenishReportPage.fromFixedDate(
                          //   dateStr: date,
                          //   step: widget.assignmentData.step,
                          //   oldNum: num,
                          //   onCommitFn: _onReplenishReportCommit,
                          // );
                          return ReplenishReportPage(
                            pageTitle: "修改数量",
                            initDate: DateInt.fromInt(date),
                            isDateChangeable: false,
                            line1_title: "(旧)数量：",
                            line1_getNumOnDateChangeFn: (DateTime date) async {
                              return num; // 因为日期固定不变，所以只需要返回固定值；
                            },
                            line2_title: "(新)数量：",
                            line2_getNumOnDateChangeFn: (DateTime date) async {
                              return num; // 因为日期固定不变，所以只需要返回固定值；
                            },
                            step: widget.assignmentData.step,
                            onCommitFn: _onReplenishReportCommit_setNum,
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
                date: dailyData.date,
                num: dailyData.done);
          }

          return null;
        },
      ),
    );
  }
}
