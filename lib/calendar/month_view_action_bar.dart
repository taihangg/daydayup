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
  });

  @override
  Widget build(BuildContext context) {
//    lineTitle.add(
//      SizedBox(width: screenWidth / 50),
//    );

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
      SizedBox(width: width / 50),
      _buildTitleLineDateButton(context),
      SizedBox(width: width / 50),
      _buildTitleLineButton1(Colors.yellowAccent, "返回\n今日", Colors.red, () {
        onDateChangeFn(DateTime.now());
        return;
      }),
    ];

    return FittedBox(
      child: Container(
        width: width * 8 / 9,
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        decoration: BoxDecoration(
          //color: Colors.redAccent,
          border: Border.all(width: 0.5, color: Colors.black38),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: FittedBox(
            child: Column(
          children: [
            Container(
                height: width / 5,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: actionLineChildren)),
            Container(
                height: width / 5,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: titleLineChildren)),
          ],
        )),
      ),
    );
  }

  _toPrevYearFn() {
    final lastMonth = DateTime(showMonth.year - 1, showMonth.month, 1);
    onDateChangeFn(lastMonth);
    return;
  }

  _toNextYearFn() {
    final nextMonth = DateTime(showMonth.year + 1, showMonth.month, 1);
    onDateChangeFn(nextMonth);
    return;
  }

  _toPrevMonthFn() {
    var lastMonth =
        DateTime(showMonth.year, showMonth.month - 1, showMonth.day);
    if (lastMonth.day != showMonth.day) {
      lastMonth = DateTime(showMonth.year, showMonth.month, 0);
    }

    onDateChangeFn(lastMonth);
    return;
  }

  _toNextMonthFn() {
    var nextMonth =
        DateTime(showMonth.year, showMonth.month + 1, showMonth.day);
    if (nextMonth.day != showMonth.day) {
      nextMonth = DateTime(showMonth.year, showMonth.month + 2, 0);
    }
    onDateChangeFn(nextMonth);
    return;
  }

  Widget _buildActionLineButton(Color color, IconData icon, String title,
      bool iconAtHead, VoidCallback onPressed) {
    List<Widget> children = [
      Text(title, style: TextStyle(fontSize: width / 10))
    ];
    if (iconAtHead) {
      children.insert(0, Container(child: Icon(icon)));
    } else {
      children.add(Container(child: Icon(icon)));
    }
    return Container(
      child: RaisedButton(
        color: color,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: children,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildTitleLineButton1(Color backgroundColor, String text,
      Color textColor, GestureTapCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width * 2 / 10,
        height: width * 2 / 10,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(width: 2.0, color: Colors.black38),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: FittedBox(
          child: Text(text,
              style: TextStyle(color: textColor, fontSize: width / 10)),
        ),
      ),
    );
  }

  Widget _buildTitleLineDateButton(BuildContext context) {
    return Container(
      width: width * 10 / 10,
      height: width * 2 / 10,
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
            style: TextStyle(fontSize: width / 10, color: Colors.black),
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
