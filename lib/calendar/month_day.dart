import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:marquee_widget/marquee_widget.dart';

class TitleDay extends StatelessWidget {
  final double screenWidth;

  TitleDay(this.num, this.screenWidth)
      : assert(1 <= num),
        assert(num <= 7);
  final int num;

  final List<String> _weekDayName = ["一", "二", "三", "四", "五", "六", "天"];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth / 8,
      height: screenWidth / 8 / 10 * 6,
      decoration: BoxDecoration(
        color: Colors.blue[300],
        border: Border.all(width: 0.5, color: Colors.black38),
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
      ),
      child: Center(
        child: FittedBox(
          child: Text(
            _weekDayName[num - 1],
            style: TextStyle(fontSize: screenWidth / 20, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class DayBox extends StatelessWidget {
  static final double _width = MediaQueryData.fromWindow(window).size.width;
//  final double _width;
  final DateTime date;
  final bool showNoteIcon;
  final bool noteActive;
  final bool selected;
  final bool baskgroundGrey;
  final bool isToday;
  final List<TextSpan> gregorianFestivalStrs;
  final String lunarStr;
  final List<TextSpan> lunarFestivialStrs;
  final Function(DateTime, bool) onSelectCallback;

  double _boxWidth;
  double _boxItemHight;
  DayBox(this.date, this.lunarStr,
      {this.showNoteIcon = false,
      this.noteActive = true,
      this.selected = false,
      this.baskgroundGrey = false,
      this.isToday = false,
      this.gregorianFestivalStrs,
      this.lunarFestivialStrs,
      this.onSelectCallback}) {
    _boxWidth = _width / 8;
    _boxItemHight = (_width / 8) * 2 / 5;
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    if (true == isToday) {
      backgroundColor = Color(0xFFFFD700);
    } else if (baskgroundGrey) {
      backgroundColor = Colors.grey[300];
    }

    List<Widget> stackChildren = [];

    List<Widget> columnChildren = [];

    // // 添加任务图标
    // if (showNoteIcon) {
    //   stackChildren.add(Container(
    //       alignment: Alignment.centerLeft,
    //       child: Icon(Icons.event_note,
    //           size: _width / 27,
    //           color: noteActive ? Colors.orange : Colors.grey)));
    // }

    // 需要显示月份的情况
    // if (null != gregorianStrs) {
    columnChildren.add(_buildRichText(gregorianFestivalStrs));
    // }

    // 日期数字
    BoxDecoration decoration = BoxDecoration(
      // color: Colors.cyan,
      border: Border.all(width: 0.5, color: Colors.cyan),
      // borderRadius: BorderRadius.all(Radius.circular(8.0)),
    );
    // decoration = null;

    columnChildren.add(Container(
        // decoration: decoration,
        alignment: Alignment.center,
        width: _boxWidth,
        height: _boxItemHight,
        child: FittedBox(
            fit: BoxFit.fill,
            child: Text("${date.day}",
                style:
                    TextStyle(fontSize: _width / 10, color: Colors.black)))));

    // 农历日期
    columnChildren.add(Container(
        // decoration: decoration,
        alignment: Alignment.center,
        width: _boxWidth,
        height: _boxItemHight,
        child: FittedBox(
            fit: BoxFit.fill,
            child: Text(lunarStr,
                style: TextStyle(
                    fontSize: _width / 10, color: Colors.grey[600])))));

    // 将公历日期与农历合到一行？？？
    // columnChildren.add(_buildRichText(
    //   [
    //     TextSpan(text: "${date.day}", style: TextStyle(color: Colors.black)),
    //     TextSpan(text: lunarStr, style: TextStyle(color: Colors.grey[600])),
    //   ],
    // ));

    columnChildren.add(_buildRichText(lunarFestivialStrs));

    stackChildren.add(FittedBox(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: columnChildren,
    )));

    // 用一个单独的Container来处理选中时候的效果
    // 如果直接在显示层处理选中效果，点击选中的时候显示内容会有细微的大小变化
    // 背景放在最底层，否则会覆盖其他显示内容
    stackChildren.insert(
        0,
        Container(
            width: _boxWidth,
            height: _boxItemHight * columnChildren.length,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(
                  width: selected ? 2.0 : 0.1,
                  color: selected ? Colors.red : Colors.black38),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            )));

    return GestureDetector(
        onTap: () {
          if (null != onSelectCallback) {
            onSelectCallback(date, !selected);
          }
        },
        child: Container(
            width: _boxWidth,
            // height: _boxItemHight * columnChildren.length,
            child: Stack(children: stackChildren)));
  }

  Widget _buildRichText(List<TextSpan> strs) {
    BoxDecoration decoration = BoxDecoration(
      // color: Colors.cyan,
      border: Border.all(width: 0.5, color: Colors.cyan),
      // borderRadius: BorderRadius.all(Radius.circular(8.0)),
    );
    decoration = null;

    if (null == strs) {
      return Container(
        alignment: Alignment.center,
        width: _boxWidth,
        height: _boxItemHight,
        decoration: decoration,
        child: Text(""),
      );
    }

    int length = 0;
    strs.forEach((var e) {
      length += e.text.length;
    });
    final richText = RichText(text: TextSpan(children: strs));

    return Container(
      // alignment: alignment,
      alignment: Alignment.center,
      width: _boxWidth,
      height: _boxItemHight,
      decoration: decoration,
      child: (length < 5)
          ? richText
          : FittedBox(
              child: Container(
                width: _boxWidth,
                height: _boxItemHight,
                child: Marquee(
                  animationDuration: Duration(milliseconds: 2000),
                  backDuration: Duration(milliseconds: 2000),
                  pauseDuration: Duration(milliseconds: 1000),
                  forwardAnimation: Curves.easeOut,
                  child: richText,
                ),
              ),
            ),
    );
  }

  ///////////////////////////////////////

  Widget build0(BuildContext context) {
    Color backgroundColor;
    if (true == isToday) {
      backgroundColor = Color(0xFFFFD700);
    } else if (baskgroundGrey) {
      backgroundColor = Colors.grey[300];
    }

    List<Widget> stackChildren = [];

    // 用一个单独的Container来处理选中时候的效果
    // 如果直接在显示层处理选中效果，点击选中的时候显示内容会有细微的大小变化
    stackChildren.add(Container(
        decoration: BoxDecoration(
      color: backgroundColor,
      border: Border.all(
          width: selected ? 2.0 : 1.5,
          color: selected ? Colors.red : Colors.black38),
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    )));

    // 日期数字
    stackChildren.add(Container(
        alignment: Alignment.center,
        child: Text("${date.day}",
            style: new TextStyle(fontSize: _width / 20, color: Colors.black))));

    // 添加任务图标
    if (showNoteIcon) {
      stackChildren.add(Container(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.event_note,
              size: _width / 27,
              color: noteActive ? Colors.orange : Colors.grey)));
    }

    // 需要显示月份的情况
    if (null != gregorianFestivalStrs) {
      stackChildren.add(_buildRichText(gregorianFestivalStrs));
    }

    if (null != lunarFestivialStrs) {
      stackChildren.add(_buildRichText(lunarFestivialStrs));
    }

    return GestureDetector(
        onTap: () {
          if (null != onSelectCallback) {
            onSelectCallback(date, !selected);
          }
        },
        child: Container(
            width: _width / 8,
            // height: _width / 20 * 3,
            child: Stack(children: stackChildren)));
  }
}
