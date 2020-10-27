import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'user_defined_festirval_editor.dart';

class MonthViewActionBar extends StatelessWidget {
//  final double _width = MediaQueryData.fromWindow(window).size.width;
//  final double _height = MediaQueryData.fromWindow(window).size.height;
  final double width;
  final DateTime showMonth;
  final Function(DateTime month) onDateChangeFn;
  final String Function() getFestivalText;
  final String Function(String) onSaveFn;
  MonthViewActionBar({
    this.width,
    this.showMonth,
    this.onDateChangeFn,
    this.getFestivalText,
    this.onSaveFn,
  }) {
    _allWidth = width * 8 / 9;
    _boxHeight = _allWidth / 10;
    _fontSize = _allWidth / 5;
    _actionBoxWidth = _allWidth / 4 * 8 / 10;
  }

  double _allWidth;
  double _boxHeight;
  double _fontSize;
  double _actionBoxWidth;

  @override
  Widget build(BuildContext context) {
    // final double fontSize = width / 15;
    List<Widget> actionLineChildren = <Widget>[
      _buildActionLineButton(
          Color(0xFFFFD700), Icons.arrow_back_ios, "上一年", true, _toPrevYearFn),
      SizedBox(width: width / 100),
      _buildActionLineButton(Color(0xFFFFD700), Icons.arrow_forward_ios, "下一年",
          false, _toNextYearFn),
      SizedBox(width: width / 40),
      _buildActionLineButton(
          Color(0xFFFFB90F), Icons.arrow_back_ios, "上一月", true, _toPrevMonthFn),
      SizedBox(width: width / 100),
      _buildActionLineButton(Color(0xFFFFB90F), Icons.arrow_forward_ios, "下一月",
          false, _toNextMonthFn),
    ];

    _manageFestival() {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return UserDefinedFestirvalEditor(getFestivalText(), onSaveFn);
      }));
      return;
    }

    List<Widget> titleLineChildren = <Widget>[
      _buildTitleLineButton1(
          null, "节日\n管理", Colors.indigoAccent, _manageFestival),
      SizedBox(width: _allWidth / 20),
      _buildTitleLineDateButton(context, _boxHeight, _fontSize),
      SizedBox(width: _allWidth / 20),
      _buildTitleLineButton1(Colors.yellowAccent, "返回\n今日", Colors.red, () {
        onDateChangeFn(DateTime.now());
        return;
      }),
    ];

    BoxDecoration decoration = BoxDecoration(
      //color: Colors.redAccent,
      border: Border.all(width: 0.5, color: Colors.red),
      // borderRadius: BorderRadius.all(Radius.circular(8.0)),
    );

    return FittedBox(
      child: Container(
        width: _allWidth,
        height: _boxHeight * 2,
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        decoration: BoxDecoration(
          //color: Colors.redAccent,
          border: Border.all(width: 0.5, color: Colors.black38),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        // child: FittedBox(
        //     fit: BoxFit.contain,
        child: Column(
          children: [
            FittedBox(
                child: Container(
                    height: _boxHeight,
                    // decoration: decoration,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: actionLineChildren))),
            FittedBox(
                child: Container(
                    // decoration: decoration,
                    height: _boxHeight,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: titleLineChildren))),
          ],
        ),
        // ),
      ),
    );
  }

  _toPrevYearFn() {
    DateTime lastYear =
        DateTime(showMonth.year - 1, showMonth.month, showMonth.day);
    if (lastYear.day != showMonth.day) {
      //如果切换的日期没有这一天，可能会跑到指定日期的下一个月去了，那么就修改为目标月的最后一天
      lastYear = DateTime(lastYear.year, lastYear.month, 0);
    }

    onDateChangeFn(lastYear);
    return;
  }

  _toNextYearFn() {
    DateTime nextYear =
        DateTime(showMonth.year + 1, showMonth.month, showMonth.day);
    if (nextYear.day != showMonth.day) {
      //如果切换的日期没有这一天，可能会跑到指定日期的下一个月去了，那么就修改为目标月的最后一天
      nextYear = DateTime(nextYear.year, nextYear.month, 0);
    }
    onDateChangeFn(nextYear);
    return;
  }

  _toPrevMonthFn() {
    var lastMonth =
        DateTime(showMonth.year, showMonth.month - 1, showMonth.day);
    if (lastMonth.day != showMonth.day) {
      //如果切换的日期没有这一天，可能会跑到指定日期的下一个月去了，那么就修改为目标月的最后一天
      lastMonth = DateTime(showMonth.year, showMonth.month, 0);
    }

    onDateChangeFn(lastMonth);
    return;
  }

  _toNextMonthFn() {
    var nextMonth =
        DateTime(showMonth.year, showMonth.month + 1, showMonth.day);
    if (nextMonth.day != showMonth.day) {
      //如果切换的日期没有这一天，可能会跑到指定日期的下一个月去了，那么就修改为目标月的最后一天
      nextMonth = DateTime(showMonth.year, showMonth.month + 2, 0);
    }
    onDateChangeFn(nextMonth);
    return;
  }

  Widget _buildActionLineButton(Color color, IconData icon, String title,
      bool iconAtHead, VoidCallback onPressed) {
    List<Widget> children = [
      Text(title, style: TextStyle(fontSize: _fontSize))
    ];
    if (iconAtHead) {
      children.insert(0, Container(child: Icon(icon)));
    } else {
      children.add(Container(child: Icon(icon)));
    }
    return Container(
      width: _allWidth / 4,
      height: _actionBoxWidth,
      child: FittedBox(
        child: RaisedButton(
          color: color,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: children,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildTitleLineButton1(
    Color backgroundColor,
    String text,
    Color textColor,
    GestureTapCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _boxHeight,
        height: _boxHeight,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(width: 2.0, color: Colors.black38),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: FittedBox(
          child: Text(text,
              style: TextStyle(color: textColor, fontSize: _fontSize)),
        ),
      ),
    );
  }

  Widget _buildTitleLineDateButton(
    BuildContext context,
    double boxHeight,
    double fontSize,
  ) {
    BoxDecoration decoration = BoxDecoration(
      //color: Colors.redAccent,
      border: Border.all(width: 0.5, color: Colors.lightBlue),
      // borderRadius: BorderRadius.all(Radius.circular(8.0)),
    );

    return Container(
      // width: width * 6 / 10,
      height: boxHeight,
      // decoration: decoration,
      //alignment: Alignment.center,
      //padding: EdgeInsets.fromLTRB(screenWidth / 100, 0, screenWidth / 100, 0),
//      color: Colors.lightBlueAccent,
      child: FittedBox(
        child: FlatButton(
          color: Colors.orange[200], //Color(0xFFFFD700),
//          color: Colors.red,
          child: Text(
            "${showMonth.year}年" +
                ((showMonth.month < 10) ? " " : "") +
                "${showMonth.month}月" +
                ((showMonth.day < 10) ? " " : "") +
                "${showMonth.day}日",
            style: TextStyle(fontSize: fontSize, color: Colors.black),
          ),
          onPressed: () async {
//          var pickDate = await showDatePicker(
//            context: context,
//            initialDate: showMonth,
//            firstDate: DateTime(1900),
//            lastDate: DateTime(2100),
//            locale: Localizations.localeOf(context),
//          );
//
//          if (null != pickDate) {
//            onMonthChangeFn(pickDate);
//          }

//          showCupertinoDialog
            await showCupertinoModalPopup(
              //通过showDialog方法展示alert弹框
              context: context,
              builder: (context) {
                return Container(
//                width: screenWidth,
                  height: 300,
//                color: Colors.red,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: (DateTime pickDate) {
                      if (null != pickDate) {
                        onDateChangeFn(pickDate);
                      }
                    },
                    initialDateTime: showMonth,
                    minimumDate: DateTime(1900),
                    maximumDate: DateTime(2100),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
