import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import '../common_util.dart';

class ReplenishReportPage extends StatefulWidget {
  final int step;
  final void Function(DateTime date, int oldNum, int newNum) onCommitFn;
  Future<int> Function(DateTime date) getOldNumFn;
  ReplenishReportPage({this.step, this.getOldNumFn, this.onCommitFn}) {
    assert(null != step);
    assert(null != getOldNumFn);
    assert(null != onCommitFn);
  }

  String dateStr;
  int oldNum;
  ReplenishReportPage.fromFixedDate(
      {this.dateStr, this.step, this.oldNum, this.onCommitFn}) {
    assert(null != dateStr);
    assert(null != step);
    assert(null != oldNum);
    assert(null != onCommitFn);
  }

  @override
  State<StatefulWidget> createState() {
    return ReplenishReportPageState();
  }
}

class ReplenishReportPageState extends State<ReplenishReportPage>
    with SingleTickerProviderStateMixin {
  ReplenishReportPageState() {}

  final double _width = MediaQueryData.fromWindow(window).size.width;
  final double _height = MediaQueryData.fromWindow(window).size.height;

  final _fmt = DateFormat('yyyy-MM-dd');
  DateTime _date;
  int _oldNum = 0;

  TextEditingController _dateController = TextEditingController();
  TextEditingController _oldDoneController = TextEditingController();
  TextEditingController _newDoneController = TextEditingController();

  AnimationController _animationController;

  @override
  initState() {
    super.initState();

    if (null != widget.dateStr) {
      _date = _fmt.parse(widget.dateStr);
      _dateController.text = widget.dateStr;
      _oldNum = widget.oldNum;
      _oldDoneController.text = (null == _oldNum) ? "无" : "$_oldNum";
    } else {
      final today = DateTime.now();
      final yesterday = DateTime(today.year, today.month, today.day - 1);
      _updateDate(yesterday);
    }

    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
//    _animation = IntTween(begin: _oldNum, end: _oldNum).animate(CurvedAnimation(
//        parent: _animationController, curve: Curves.fastLinearToSlowEaseIn));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dateController.dispose();
    _oldDoneController.dispose();
    _newDoneController.dispose();
    super.dispose();
  }

  _updateDate(DateTime newDate) async {
    _date = newDate;

    String dateStr = _fmt.format(newDate);
    _dateController.text = dateStr;

    _oldNum = (await widget.getOldNumFn(newDate));

    _oldDoneController.text = (null == _oldNum) ? "无" : "$_oldNum";
  }

  Widget _buildDateInputBox() {
    return FittedBox(
        child: Row(
      children: [
        SizedBox(width: _width / 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
//            SizedBox(height: _width / 18),
            Container(
                alignment: Alignment.centerRight,
                width: _width / 4,
                height: _width / 10,
                child: FittedBox(
                    child: Text(
                  "日期：",
                  style: TextStyle(
                      fontSize: _width / 20,
                      color: (null != widget.dateStr) ? Colors.grey : null),
                ))),
          ],
        ),
        GestureDetector(
          child: Container(
            width: _width * 55 / 100,
            height: _width * 12 / 100,
            color:
                (null == widget.dateStr) ? Colors.grey[200] : Colors.grey[50],
            alignment: Alignment.centerLeft,
            child: Text(
              _fmt.format(_date),
              style: TextStyle(fontSize: _width / 20),
            ),
          ),
          onTap: () async {
            if (null != widget.dateStr) {
              return;
            }

            final today = DateTime.now();
            final newDate = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime(today.year - 1, 1, 1),
              lastDate: today,
              locale: Locale("zh", "CN"),
            );
            if ((null != newDate) && (!isSameDay(newDate, _date))) {
              _updateDate(newDate);
              setState(() {});
            }
          },
        ),
        SizedBox(width: _width / 20),
      ],
    ));
  }

  Widget _buildDoneInputBox(String title, TextEditingController controller,
      bool revisable, Function(String) onChanged) {
    return FittedBox(
        child: Row(children: [
      SizedBox(width: _width / 20),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: _width / 60),
          Container(
              alignment: Alignment.topRight,
              width: _width / 4,
              height: _width / 8,
              child: FittedBox(
                  child: Text(title,
                      style: TextStyle(
                          fontSize: _width / 20,
                          color:
                              (true == revisable) ? null : Colors.grey[500])))),
        ],
      ),
      Container(
        width: _width * 55 / 100,
        height: _width / 6,
        alignment: Alignment.topRight,
        child: TextFormField(
          enabled: (true == revisable),
          autofocus: false,
          style: TextStyle(
              fontSize: _width / 20,
              color: (true == revisable) ? null : Colors.grey[500]),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: (true == revisable) ? Colors.grey[100] : Colors.grey[50],
            errorStyle: TextStyle(fontSize: _width / 30),
          ),
          controller: controller,
          autovalidate: true,
          validator: ValidateNumFn,
          onChanged: onChanged,
        ),
      ),
      SizedBox(width: _width / 20),
    ]));
  }

  Widget _buildButton(
      IconData icon, String label, void Function() onPressedFn) {
    return Container(
      width: _width * 30 / 100,
      height: _width * 15 / 100,
      child: FittedBox(
        child: OutlineButton.icon(
          color: Colors.grey[100],
          icon: Icon(icon, size: _width / 15, color: Colors.lightBlueAccent),
          label: Text(
            label,
            style:
                TextStyle(fontSize: _width / 15, color: Colors.lightBlueAccent),
          ),
          onPressed: onPressedFn,
        ),
      ),
    );
  }

  Widget _buildStepButtonLine() {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildButton(Icons.remove, "${widget.step}", _reduceStep),
        _buildButton(Icons.add, "${widget.step}", _addStep),
      ],
    ));
  }

  void _reduceStep() {
    if ((null != _newDoneController.text) && ("" != _newDoneController.text)) {
      try {
        int oldNum = int.parse(_newDoneController.text);
      } catch (err) {
        _lastNewNum = null;
        //当前有非法输入值，就不做改变
        return;
      }
    }

    if ((null != _lastNewNum) && (0 != _lastNewNum)) {
      // 非null 非0，值有变化
      if (widget.step < _lastNewNum) {
        _thisNewNum = _lastNewNum - widget.step;
      } else {
        _thisNewNum = 0;
      }
      if (1 == widget.step) {
        //  step==1，不用动画，直接设置显示内容
        _lastNewNum = _thisNewNum;
        _newDoneController.text = "$_lastNewNum";
      } else {
        setState(() {});
      }
    } else {
      if (null == _lastNewNum) {
        _lastNewNum = 0;
        _newDoneController.text = "0";
      }
      _thisNewNum = 0; //显示0
    }
  }

  void _addStep() {
    if ((null != _newDoneController.text) && ("" != _newDoneController.text)) {
      try {
        int num = int.parse(_newDoneController.text);
      } catch (err) {
        _lastNewNum = null;
        //当前有非法输入值，就不做改变
        return;
      }
    }

    _lastNewNum = _lastNewNum ?? 0;
    _thisNewNum = _lastNewNum + widget.step;

    if (1 == widget.step) {
      //  step==1，不用动画，直接设置显示内容
      _lastNewNum = _thisNewNum;
      _newDoneController.text = "$_lastNewNum";
    } else {
      setState(() {});
    }

//    setState(() {});
  }

  Widget _buildButtonLine(BuildContext context2) {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          child: FittedBox(
            child: FlatButton(
              color: Colors.grey[200],
              child: Text(
                "返回",
                style: TextStyle(fontSize: _width / 20),
              ),
              onPressed: () {
                Navigator.of(context2).pop();
              },
            ),
          ),
        ),
        Container(
          child: FittedBox(
            child: FlatButton(
              color: Colors.grey[200],
              child: Text("提交", style: TextStyle(fontSize: _width / 20)),
              onPressed: () async {
                if (null == _thisNewNum) {
                  return;
                }

                widget.onCommitFn(_date, _oldNum, _thisNewNum);
                Navigator.of(context2).pop();
              },
            ),
          ),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
//    final children = [
//      SizedBox(height: _width / 5),
//      _buildDateInputBox(),
//      SizedBox(height: _width / 20),
////      _buildOldDoneInputBox(),
//      SizedBox(height: _width / 20),
////      _buildNewDoneInputBox(),
//      SizedBox(height: _width / 20),
//      Divider(),
//      SizedBox(height: _width / 20),
//      _buildButtonLine(context)
//    ];

    return SimpleDialog(
      title: Center(
          child: Text("修改、补报",
              style:
                  TextStyle(color: Colors.deepOrange, fontSize: _width / 15))),
      children: [
        Divider(),
        SizedBox(height: _width / 40),
        _buildDateInputBox(),
        SizedBox(height: _width / 20),
        _buildDoneInputBox("(旧)数量：", _oldDoneController, false, null),
        SizedBox(height: _width / 100),
        _buildNewDoneInputBox(),
        SizedBox(height: _width / 100),
        _buildStepButtonLine(),
        SizedBox(height: _width / 20),
        Divider(),
        _buildButtonLine(context),
      ],
    );
//    return Scrollbar(
//      child: SingleChildScrollView(
//        child: Column(
//          mainAxisAlignment: MainAxisAlignment.start,
//          children: children,
//        ),
//      ),
//    );

//    return Scaffold(
//      appBar: AppBar(title: Text("修改与补报")),
//      body: Builder(builder: (BuildContext context2) {}),
//    );
  }

  _onChanged(String value) {
    int newNum;
    try {
      newNum = int.parse(value);
    } catch (err) {}
    _lastNewNum = _thisNewNum = newNum;
  }

  int _lastNewNum;
  int _thisNewNum;
  Widget _buildNewDoneInputBox() {
    final inputBox =
        _buildDoneInputBox("(新)数量：", _newDoneController, true, _onChanged);
    if ((null == _lastNewNum) || (_lastNewNum == _thisNewNum)) {
      return inputBox;
    }
    Animation animation =
        IntTween(begin: _lastNewNum, end: _thisNewNum).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutExpo,
//      curve: Curves.easeOutCirc,
    ));
    _animationController.reset();
    _animationController.forward();

    _lastNewNum = _thisNewNum;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget child) {
        _newDoneController.text = animation.value.toString();
        return inputBox;
      },
    );
  }

  void onNewDoneTextFieldChanged(String value) {
    print("xxx onNewDoneTextFieldChanged");
    try {
//      连续点+或者-时，因为旧值是从controller.text中解析出来的，会可能在动画完成前就开始解析值了，最终结果会是错误值
      _lastNewNum = int.parse(value);
    } catch (err) {
      _lastNewNum = null;
    }
  }
}
