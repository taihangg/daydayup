import 'dart:ui';

import 'package:flutter/material.dart';

import '../common_util.dart';
import 'assignment_data.dart';

class _AssignmentBarUtil {
  final double _width = MediaQueryData.fromWindow(window).size.width;
  final double _height = MediaQueryData.fromWindow(window).size.height;
  double defaultBoxWidth;
  double defaultBoxHeight;
  double buttonWidth;
  double fontSize;
  _AssignmentBarUtil() {
    defaultBoxWidth = _width * 15 / 100;
    defaultBoxHeight = _width * 15 / 100;
    buttonWidth = _width * 17 / 100;
    fontSize = _width / 10;
  }

  Widget buildRadiusBox(Widget child, Color color, [double width]) {
    width = width ?? defaultBoxWidth;
    return Container(
//      alignment: Alignment.center,
      width: width,
      height: defaultBoxHeight,
      child: Container(
        width: width,
        height: defaultBoxHeight,
        margin: EdgeInsets.all(_width * 0.5 / 100),
        decoration: BoxDecoration(
          color: color,
//          border: Border.all(width: 1.0, color: Colors.black38),
          borderRadius: BorderRadius.all(Radius.circular(7.0)),
        ),
        child: FittedBox(fit: BoxFit.fill, child: child),
      ),
    );
  }

  Widget buildTitleStringBox(String msg,
      {Color textColor, Color backgroundColor, double width}) {
    return buildRadiusBox(
        Text(msg, style: TextStyle(fontSize: fontSize, color: textColor)),
        backgroundColor,
        width);
  }

  String dateString(DateInt dateInt) {
    return "${dateInt.month}.${dateInt.day}";
  }

  Widget buildBox(Widget child, bool hasLeftBar, [Color color, double width]) {
    width = width ?? defaultBoxWidth;
    return Container(
      decoration: BoxDecoration(
        color: color,
//        border: Border.all(width: 0.3, color: Colors.black38),
        border: hasLeftBar
            ? Border.lerp(
                null,
                Border(left: BorderSide(width: 0.8, color: Colors.black38)),
                1.0,
              )
            : null,
      ),
      alignment: Alignment.center,
      width: width,
      height: defaultBoxHeight,
      child: FittedBox(child: child),
    );
  }

  Widget buildStringBox(
    String msg, {
    Color textColor,
    bool hasLeftBar = true,
    Color backgroundColor,
    double width,
  }) {
    return buildBox(
      Text(msg,
//            textAlign: TextAlign.center,
          style: TextStyle(fontSize: fontSize, color: textColor)),
      hasLeftBar,
      backgroundColor,
      width,
    );
  }

//  Widget buildNumBox(int num,
//      {Color textColor, Color backgroundColor, double width}) {
//    return buildBox(
//        Text(numString(num, true),
//            style: TextStyle(fontSize: fontSize, color: textColor)),
//        backgroundColor,
//        width);
//  }
}

class AssignmentBar extends StatefulWidget {
  final AssignmentData a;
  final Color color;

  final Function(int) onTapTitle;

  AssignmentBar(this.a, this.color, this.onTapTitle)
      : super(key: ValueKey(a.ID));

  @override
  State<StatefulWidget> createState() {
    return _AssignmentBarState();
  }

  static Widget title() {
    _AssignmentBarUtil util = _AssignmentBarUtil();
    DateInt todayInt = DateInt(DateTime.now());
    return Card(
//        color: Color(0xffFFFACD),
//        elevation: 10.0,
//        semanticContainer: false,
        child: Column(
      children: <Widget>[
        FittedBox(
            child: Container(
                alignment: Alignment.center,
                height: util.defaultBoxHeight * 1.5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    util.buildTitleStringBox("课程",
                        backgroundColor: Color(0xFF00F5FF),
                        width: util.defaultBoxWidth * 2),
                    util.buildTitleStringBox(
                      util.dateString(todayInt.prevousDay.prevousDay),
                      backgroundColor: Colors.grey[350],
                    ),
                    util.buildTitleStringBox(
                      util.dateString(todayInt.prevousDay),
                      backgroundColor: Color(0xFF00F5FF),
                    ),
                    util.buildTitleStringBox(
                      util.dateString(todayInt),
                      backgroundColor: Colors.grey[350],
                    ),
                    util.buildTitleStringBox(
                      "修改报数",
                      backgroundColor: Color(0xFF00F5FF),
                      width: util.buttonWidth * 2,
                    ),
                  ],
                ))),
//        Divider(),
      ],
    ));
  }
}

class _AssignmentBarState extends State<AssignmentBar>
    with SingleTickerProviderStateMixin {
  _AssignmentBarUtil _util = _AssignmentBarUtil();
  AnimationController _animationController;

  @override
  initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _animationController.forward(); // 运行一下，否则会停在起始值
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<int> _showNumList = [0, 0, 0];
  @override
  Widget build(BuildContext context) {
//    List<int> lastLineData = widget.a.lastLineData;
    int i = 0;
    final futureBuilder = FutureBuilder<List<int>>(
      initialData: _showNumList, //lastLineData,
      future: widget.a.getLatestLineData(3),
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
        if ((ConnectionState.done == snapshot.connectionState) &&
            (snapshot.hasError)) {
          return Center(
              child: Text(
            '错误: ${snapshot.error}',
            style: TextStyle(fontSize: _util.fontSize),
          ));
        }

        return _buildDataRow(snapshot.data);
      },
    );

    return Card(
        key: ValueKey(widget.a.ID),
        elevation: 6.0,
        child: Container(
            height: _util.defaultBoxHeight * 1.2,
            alignment: Alignment.center,
            child: FittedBox(child: futureBuilder)));
  }

  Widget _buildDataRow(List<int> newData) {
//    assert(null != showNumList);
    assert(null != newData);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          child: _util.buildStringBox(
            widget.a.name,
            textColor: Color(0xFFFF8C00), //widget.color,
            hasLeftBar: false,
            width: _util.defaultBoxWidth * 2,
          ),
          onTap: () {
            widget.onTapTitle(widget.a.sortSequence);
          },
        ),
        _buildAnimatedNumBox(0, newData[0]),
        _buildAnimatedNumBox(1, newData[1]),
        _buildAnimatedNumBox(2, newData[2]),
        _buildReduceButtonBox(widget.a),
        _buildAddButtonBox(widget.a),
      ],
    );
  }

  Widget _buildAnimatedNumBox(int showNumIndex, int newNum) {
    assert(null != newNum);
//    print("showNumList[$showNumIndex]=${_showNumList[showNumIndex]}");
    if (_showNumList[showNumIndex] == newNum) {
      return _util.buildStringBox(
        numString(newNum, true),
        textColor: (0 == _showNumList[showNumIndex]) ? Colors.red : null,
      );
    } else {
      Animation animation =
          IntTween(begin: _showNumList[showNumIndex], end: newNum)
              .animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutExpo,
//                curve: Curves.easeOutCirc,
      ));

      return AnimatedBuilder(
          animation: _animationController,
          builder: (BuildContext context, Widget child) {
            _showNumList[showNumIndex] = animation.value;
            return _util.buildStringBox(numString(animation.value, true),
                textColor:
                    (0 == _showNumList[showNumIndex]) ? Colors.red : null);
          });
    }
  }

  Widget _buildButtonBox(IconData icon, String lable, VoidCallback onPressed,
      [Color color, double width]) {
    return _util.buildRadiusBox(
        FlatButton.icon(
//            color: Colors.red,
            onPressed: onPressed,
            icon: Icon(icon, size: _util.fontSize),
            label: Text(
              lable,
              style: TextStyle(fontSize: _util.fontSize * 1.2),
            )),
        color,
        _util.buttonWidth);
  }

  Widget _buildReduceButtonBox(AssignmentData a) {
    return _buildButtonBox(
      Icons.remove,
      "${a.step}",
      () async {
        bool b = await a.todayDoneReduceStep();
        if (b) {
          _animationController.reset();
          _animationController.forward();
          setState(() {});
        }
      },
      Colors.tealAccent,
    );
  }

  Widget _buildAddButtonBox(AssignmentData a) {
    return _buildButtonBox(
      Icons.add,
      "${a.step}",
      () async {
        await a.todayDoneAddStep();
        _animationController.reset();
        _animationController.forward();
        setState(() {});
      },
      Colors.amberAccent,
    );
  }
}
