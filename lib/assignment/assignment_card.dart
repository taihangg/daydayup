import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'assignment_data.dart';
import 'assignment_add_edit_page.dart';
import '../simple_chart.dart';
import 'assignment_replenish_report.dart';
import 'assignment_show_all_daily_data_view.dart';
import '../common_util.dart';

class AssignmentCard extends StatefulWidget {
  final AssignmentData data;
  AssignmentCard(this.data);

  @override
  State<StatefulWidget> createState() {
    return _AssignmentCardState();
  }
}

class _AssignmentCardState extends State<AssignmentCard>
    with SingleTickerProviderStateMixin {
  final double _width = MediaQueryData.fromWindow(window).size.width;
  double _bigBoxWidth;
  double _smallBoxWidth;
  double _smallBoxHeight;

  _AssignmentCardState() {
//    _bigBoxWidth = _width * 9 / 10;
    _smallBoxWidth = _width * 22 / 100;
    _smallBoxHeight = _width * 8 / 100;
    _bigBoxWidth = _smallBoxWidth * 4;
  }

  AnimationController _animationController;

  @override
  initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _animationController.forward(); // 运行一下，否则刚打开的时候会停在默认起始值
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildCard(widget.data);
  }

  Widget _buildCard(AssignmentData assignmentData) {
    int lastTodayDone = assignmentData.lastTodayDone;
    List<Widget> wrapChildren = [
      FutureBuilder<int>(
        future: assignmentData.todayDone(),
        initialData: lastTodayDone,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if ((ConnectionState.done != snapshot.connectionState) ||
              (lastTodayDone == snapshot.data) ||
              ((lastTodayDone - snapshot.data).abs() <= 1)) {
            return _buildTag("今日完成", Colors.orange, numString(snapshot.data));
          } else {
            if (snapshot.hasError) {
              return _buildTag("今日完成", Colors.orange, '错误: ${snapshot.error}');
            }

            Animation animation =
                IntTween(begin: lastTodayDone, end: snapshot.data)
                    .animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOutExpo,
//                curve: Curves.easeOutCirc,
            ));
            _animationController.reset();
            _animationController.forward();

            return AnimatedBuilder(
                animation: _animationController,
                builder: (BuildContext context, Widget child) {
                  return _buildTag(
                      "今日完成", Colors.orange, numString(animation.value));
                });
          }
        },
      ),

      _buildTag(
          "连续天数", Colors.orange, assignmentData.continuousDaysCountString()),
      _buildTag("开始日期", Colors.green, assignmentData.startDateString()),
      _buildTag("截止日期", Colors.green, assignmentData.endDateString()),
      _buildTag("目标", Colors.green, assignmentData.targetString()),
      _buildTag("已完成", Colors.orange, assignmentData.periodSumString()),
      _buildTag("进度", Colors.orange, assignmentData.progressString()),
      _buildTag("剩余天数", Colors.orange, assignmentData.leftDaysCountString()),
      _buildTag("过去平均", Colors.orange, assignmentData.pastDoneAverageString()),
      _buildTag(
          "剩余平均", Colors.orange, assignmentData.futureAverageDoneString()),
//      _buildButtonModifyPair(assignmentData),
      _buildTag("总已完成", Colors.orange, assignmentData.allSumString()),
      _buildAllDailyDataViewButton(assignmentData),
    ];

    return Container(
        key: ValueKey(assignmentData.ID),
        width: _width * 95 / 100,
        height: _width * 120 / 100,
        alignment: Alignment.center,
        margin: EdgeInsets.fromLTRB(_width * 2 / 100, _width * 2 / 100,
            _width * 2 / 100, _width * 2 / 100),
        decoration: BoxDecoration(
//          color: Colors.orange,
          border: Border.all(width: 1.0, color: Colors.blue),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: _width * 1 / 100),
            _buildTitle(assignmentData.name),
            SizedBox(height: _width * 1 / 100),
            Wrap(
              alignment: WrapAlignment.start,
              children: wrapChildren,
            ),
            SizedBox(height: _width * 1 / 100),
            Container(
//                width: _width,
//                height: _smallBoxHeight * 1.5,
//                alignment: Alignment.center,
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildButtonStepPair(assignmentData),
                _buildButtonModifyPair(assignmentData),
              ],
            )),
            SizedBox(height: _width * 2 / 100),
            Expanded(child: _buildLineChart1(assignmentData)),
            SizedBox(height: _width * 2 / 100),
//            _buildLineChartExample(assignmentData),
          ],
        ));
  }

  Widget _buildStringBox(String title, Color color) {
    return Container(
      decoration:
          BoxDecoration(border: Border.all(width: 0.5, color: Colors.black38)),
      alignment: Alignment.center,
      width: _smallBoxWidth,
      height: _smallBoxHeight,
//        decoration: BoxDecoration(border: Border(left: BorderSide(width: 1.0), right: BorderSide(width: 1.0))),
      child: FittedBox(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: _width / 15, color: color),
        ),
      ),
    );
  }

  Widget _buildTag(String title, Color titleColor, String data,
      [Color dataColor]) {
    return Container(
//      width: _smallBoxWidth,
//      height: _smallBoxHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStringBox(title, titleColor),
          _buildStringBox(data, dataColor),
        ],
      ),
    );
  }

  Widget _buildButton2(
      {IconData icon, String text, void Function() onPressed}) {
    final textColor = Colors.black;

    double fontSize;
    fontSize = _width / 12;

    Widget button;
    if (null != icon) {
      button = FlatButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: fontSize, color: textColor),
        label:
            Text(text, style: TextStyle(fontSize: fontSize, color: textColor)),
//        color: Colors.orange,
      );
    } else {
      button = FlatButton(
        onPressed: onPressed,
        child:
            Text(text, style: TextStyle(fontSize: fontSize, color: textColor)),
//        color: Colors.orange,
      );
    }

    return Container(
        width: _smallBoxWidth,
        height: _smallBoxHeight,
//        color: Colors.blue,
        child: Container(
          width: _smallBoxWidth,
          height: _smallBoxHeight,
          margin: EdgeInsets.only(left: 1, right: 1),
          decoration: BoxDecoration(
//            color: Colors.blue,
            border: Border.all(width: 1, color: Colors.black),
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          child: FittedBox(fit: BoxFit.fill, child: button),
        ));
  }

  Widget _buildAllDailyDataViewButton(AssignmentData assignmentData) {
    return _buildButton2(
        text: "所有数据",
        onPressed: () async {
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return ShowAllDailyDataView(assignmentData);
              });

          //AllDailyDataView中可以修改数据，所以返回后需要刷新一下
          setState(() {});

          return;
        });
  }

  Widget _buildButtonStepPair(AssignmentData assignmentData) {
    return Container(
//      width: _smallBoxWidth * 2,
      height: _smallBoxHeight,
      child: Row(
//        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildButton2(
            icon: Icons.remove,
            text: "${assignmentData.step}",
            onPressed: () async {
              final changed = await assignmentData.todayDoneReduceStep();
              if (true == changed) {
                setState(() {});
              }
            },
          ),
          _buildButton2(
            icon: Icons.add,
            text: "${assignmentData.step}",
            onPressed: () async {
              await assignmentData.todayDoneAddStep();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButtonModifyPair(AssignmentData assignmentData) {
    _onReplenishReportCommit(DateTime date, int oldNum, int newNum) async {
      assert(null != newNum);

      if (null == oldNum) {
        if (0 == newNum) {
          return;
        }
        await assignmentData.addDailyDone(date, newNum);
      } else {
        if (oldNum == newNum) {
          return;
        }
        if (oldNum < newNum) {
          await assignmentData.addDailyDone(date, newNum - oldNum);
        } else {
          await assignmentData.reduceDailyDone(date, oldNum - newNum);
        }
      }

      setState(() {});
    }

    return Container(
//      width: _smallBoxWidth * 2,
      height: _smallBoxHeight,
      child: Row(
//        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildButton2(
              text: "修改信息",
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return AssignmentAddEditPage.edit(
                    oldAssignmentData: assignmentData,
                    onCommitFn: (AssignmentData value) async {
                      return assignmentData.updateAfterEdit(value);
                    },
                    onDeleteFn: () async {
                      String msg = await assignmentData.remove();
                      if ((null == msg) || ("" == msg)) {
                        setState(() {});
                      }
                      return msg;
                    },
                  );
                }));
              }),
          _buildButton2(
              text: "补报/修改",
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ReplenishReportPage(
                        step: assignmentData.step,
                        getOldNumFn: assignmentData.getDailyDoneAsync,
                        onCommitFn: _onReplenishReportCommit,
                      );
                    });
                return;
              }),
        ],
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            alignment: Alignment.center,
            width: _bigBoxWidth,
            height: _smallBoxHeight * 1.5,
            child: FittedBox(
                child: RichText(
                    text: TextSpan(
              children: [
                TextSpan(
                    text: title,
                    style:
                        TextStyle(fontSize: _width / 11, color: Colors.orange)),
              ],
            )))),
      ],
    );
  }

  Widget _buildLineChart1(AssignmentData assignmentData) {
    final defaultDatas = [0.0, 0.0];
    final defaultTags = [" ", " "];

    return Container(
      width: _width * 90 / 100,
      height: _width * 40 / 100,
      child: FutureBuilder<List<List>>(
        future: assignmentData.getLatestLineTagData(),
        initialData: assignmentData
            .getLastLatestLineTagData(), //[defaultDatas, defaultTags],
        builder: (BuildContext context, AsyncSnapshot<List<List>> snapshot) {
          if (ConnectionState.done == snapshot.connectionState) {
            if (snapshot.hasError) {
              return Center(
                  child: Text(
                '错误: ${snapshot.error}',
                style: TextStyle(fontSize: _width / 10),
              ));
            }
          }

          List<double> datas = defaultDatas;
          List<String> tags = defaultTags;
          if (snapshot.data[0] is List<double>) {
            datas = snapshot.data[0];
          }

          if (snapshot.data[1] is List<String>) {
            tags = snapshot.data[1];
          }

          final List<double> extraLines = [];
          final List<String> indicators = [];
          final List<Color> indicatorColors = [];

//          final planOnAverage = assignmentData.planOnAverage();
//          if (null != planOnAverage) {
//            extraLines.add(planOnAverage);
//            indicators.add("计划平均(${planOnAverage.toStringAsFixed(1)})");
//            indicatorColors.add(Colors.orange);
//          }

          final pastDoneAverage = assignmentData.pastDoneAverage();
          if (null != pastDoneAverage) {
            extraLines.add(pastDoneAverage);

            indicators.add("过去平均(${assignmentData.pastDoneAverageString()})");
            indicatorColors.add(Colors.deepPurpleAccent);
          }

          final futureAverageDone = assignmentData.futureAverageDone();
          if (null != futureAverageDone) {
            extraLines.add(futureAverageDone);
            indicators.add("剩余平均(${assignmentData.futureAverageDoneString()})");
            indicatorColors.add(Colors.orange);
          }

          return SimpleLineChart(
//            key: ValueKey(assignmentData.ID),
            title: "${assignmentData.name}",
            titleColor: Colors.orange,
            lines: [datas],
//            lineColors: [Colors.blueAccent],
            xTitles: tags,
            extraLines: extraLines,
            extraLineColors: indicatorColors,
            indicators: indicators,
            indicatorColors: indicatorColors,
            areaLine: futureAverageDone,
            showZeroPoint: false,
          );
        },
      ),
    );
  }
}
