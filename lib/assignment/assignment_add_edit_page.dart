import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'assignment_data.dart';
import '../common_util.dart';

class AssignmentAddEditPage extends StatefulWidget {
  final Future<String> Function(AssignmentData value) onCommitFn;

  String _title;
  AssignmentAddEditPage.addNew({this.onCommitFn}) {
    assert(null != onCommitFn);
    _title = "添加新功课";
  }

  AssignmentData oldAssignmentData;
  Future<String> Function() onDeleteFn;
  AssignmentAddEditPage.edit({
    this.oldAssignmentData,
    this.onDeleteFn,
    this.onCommitFn,
  }) {
    assert(null != oldAssignmentData);
    assert(null != onDeleteFn);
    assert(null != onCommitFn);
    _title = "修改功课数据";
  }

  @override
  State<StatefulWidget> createState() {
    return AssignmentAddEditPageState();
  }
}

enum _DateType { none, useDate }

class AssignmentAddEditPageState extends State<AssignmentAddEditPage> {
  final double _width = MediaQueryData.fromWindow(window).size.width;
  final double _height = MediaQueryData.fromWindow(window).size.height;

  AssignmentData _newAssignmentData = AssignmentData();

  TextEditingController _nameController = TextEditingController();
  String _lastName;
  String _nameErrText;
  TextEditingController _targetController = TextEditingController();
  TextEditingController _stepController = TextEditingController();
  TextEditingController _otherDoneController = TextEditingController();

  final _fmt = DateFormat('yyyy-MM-dd');

  DateTime _beginDate;
  _DateType _beginDateType = _DateType.none;
  String _beginDateStr;
  Text _beginText;

  DateTime _endDate;
  _DateType _endDateType = _DateType.none;
  String _endDateStr;
  Text _endText;

  @override
  initState() {
    super.initState();

    // for edit
    if (null != widget.oldAssignmentData) {
      _newAssignmentData.assignmentFrom(widget.oldAssignmentData);

      _nameController.text = widget.oldAssignmentData.name;

      if (null != widget.oldAssignmentData.target) {
        _targetController.text = "${widget.oldAssignmentData.target}";
      }

      _stepController.text = "${widget.oldAssignmentData.step}";

      if (null != widget.oldAssignmentData.otherDone) {
        _otherDoneController.text = "${widget.oldAssignmentData.otherDone}";
      }

      _beginDate = widget.oldAssignmentData.beginDate;
      if (null != _beginDate) {
        _beginDateType = _DateType.useDate;
        _beginDateStr = _fmt.format(_beginDate);
        _beginText = Text(
          _beginDateStr,
          style: TextStyle(fontSize: _width / 20, color: Colors.black),
        );
      }

      _endDate = widget.oldAssignmentData.endDate;
      if (null != _endDate) {
        _endDateType = _DateType.useDate;
        _endDateStr = _fmt.format(_endDate);
        _endText = Text(
          _endDateStr,
          style: TextStyle(fontSize: _width / 20, color: Colors.black),
        );
      }
    } else {
      _stepController.text = "${_newAssignmentData.step}";
    }
  }

  Widget _buildHorizontalInputBox(
    String title,
    TextEditingController controller,
    FormFieldValidator<String> validatorFn,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: _width / 80),
            Container(
                alignment: Alignment.topRight,
                width: _width / 4,
                height: _width / 8,
                child: FittedBox(
                    child: Text("$title：",
                        style: TextStyle(fontSize: _width / 20)))),
          ],
        ),
        Container(
          width: _width * 55 / 100,
          height: _width / 6,
          alignment: Alignment.topRight,
          child: TextFormField(
            autofocus: (null == widget.oldAssignmentData) ? true : false,
            style: TextStyle(fontSize: _width / 20),
//            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              errorStyle: TextStyle(fontSize: _width / 30),
//              labelText: "labelText",
//              helperText: errText,
//              helperStyle: TextStyle(fontSize: _width / 30),
//              prefixText: "prefixText",
//              suffixText: "suffixText",
            ),
            controller: controller,
            autovalidate: true,
            validator: validatorFn,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleInputBox() {
    return _buildHorizontalInputBox(
      "名称",
      _nameController,
      (String value) {
        if ((null != _nameErrText) && (value != _lastName)) {
          _nameErrText = null;
        }
        if (value.isEmpty) {
          return '名称不能为空';
        }
        if (null != _nameErrText) {
          return _nameErrText;
        }
      },
    );
  }

  Widget _buildVerticalInputBox(String title, TextEditingController controller,
      FormFieldValidator<String> validatorFn,
      [Color titleBackGroundColor]) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
//        SizedBox(/*width: _width / 20,*/ height: _width / 60),
        Container(
          color: titleBackGroundColor ?? Colors.lightBlueAccent,
          alignment: Alignment.topLeft,
          width: _width * 4 / 10,
          height: _width * 7 / 100,
          child: FittedBox(
              child: Text("$title", style: TextStyle(fontSize: _width / 20))),
        ),
        Container(
//          color: Colors.red,
          width: _width * 4 / 10,
          height: _width * 13 / 100,
          alignment: Alignment.topCenter,
          child: TextFormField(
            style: TextStyle(fontSize: _width / 20),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              errorStyle: TextStyle(fontSize: _width / 30),
//              labelText: "labelText",
//              helperText: "helperText",
//              prefixText: "prefixText",
//              suffixText: "suffixText",
            ),
            controller: controller,
            autovalidate: true,
            validator: validatorFn,
          ),
        ),
      ],
    );
  }

  Widget _buildTargetInputBox() {
    return _buildVerticalInputBox("目标数量", _targetController, ValidateNumFn);
  }

  Widget _buildOtherDoneInputBox() {
    return _buildVerticalInputBox(
        "起始数量", _otherDoneController, ValidateNumFn, Colors.grey[350]);
  }

  Widget _buildStepInputBox() {
    return _buildVerticalInputBox("步进", _stepController, (String value) {
      if ("0" == value) {
        return "步进不能为0";
      }
      return ValidateNumFn(value);
    });
  }

  Widget _buildDateInputBox(
    List<String> titles,
    _DateType dateType,
    Function(_DateType dateType, DateTime dt) onChanged,
    Text text,
    DateTime initDate,
    DateTime firstDate,
    DateTime lastDate,
  ) {
    assert(2 == titles.length);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
//        SizedBox(/*width: _width / 20,*/ height: _width / 60),
        Container(
          color: Colors.orange[100],
          alignment: Alignment.topLeft,
          width: _width * 4 / 10,
          height: _width * 7 / 100,
          child: FittedBox(
            child: DropdownButton(
              value: dateType,
              items: [
                DropdownMenuItem(
                    value: _DateType.none,
                    child: FittedBox(
                        child: Text(
                      titles[0],
                      style: TextStyle(fontSize: _width / 15),
                    ))),
                DropdownMenuItem(
                    value: _DateType.useDate,
                    child: FittedBox(
                        child: Text(
                      titles[1],
                      style: TextStyle(fontSize: _width / 15),
                    ))),
              ],
              onChanged: (value) async {
                DateTime dt;
                if (_DateType.useDate == value) {
                  final today = DateTime.now();
                  dt = await showDatePicker(
                    context: context,
                    initialDate: initDate ?? today,
                    firstDate: firstDate ??
                        DateTime(today.year - 100, today.month, today.day),
                    lastDate: lastDate ??
                        DateTime(today.year + 100, today.month, today.day),
                    locale: Locale("zh", "CN"),
                  );
                }
                onChanged(value, dt);
              },
            ),
          ),
        ),
        Container(
          width: _width * 4 / 10,
          height: _width * 11 / 100,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(bottom: BorderSide(width: 0.5, color: Colors.black)),
          ),
          child: text,
        ),
        SizedBox(/*width: _width / 20,*/ height: _width * 1 / 100),
      ],
    );
  }

  Widget _buildStartDateInputBox() {
    return _buildDateInputBox(
      ["无开始日期", "选择开始日期"],
      _beginDateType,
      (_DateType dateType, DateTime dt) {
        _beginDateType = dateType;
        if (null != dt) {
          _beginDate = dt;
          _beginDateStr = _fmt.format(dt);
        }
        if (null != _beginDateStr) {
          _beginText = Text(
            _beginDateStr,
            style: TextStyle(
              fontSize: _width / 20,
              color: (_DateType.none == dateType) ? Colors.grey : Colors.black,
              decoration: (_DateType.none == dateType)
                  ? TextDecoration.lineThrough
                  : null,
            ),
          );
        }
        setState(() {});
      },
      _beginText,
      _beginDate,
      null,
      _endDate,
    );
  }

  Widget _buildExpirationDateInputBox() {
    return _buildDateInputBox(
      ["无截止日期", "选择截止日期"],
      _endDateType,
      (_DateType dateType, DateTime dt) {
        _endDateType = dateType;
        if (null != dt) {
          _endDate = dt;
          _endDateStr = _fmt.format(dt);
          _endText = Text(
            _endDateStr,
            style: TextStyle(
              fontSize: _width / 20,
              color: (_DateType.none == dateType) ? Colors.grey : Colors.black,
              decoration: (_DateType.none == dateType)
                  ? TextDecoration.lineThrough
                  : null,
            ),
          );
        }
        setState(() {});
      },
      _endText,
      _endDate,
      _beginDate,
      null,
    );
  }

  Widget _buildDeteleButton(BuildContext context2) {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          child: FittedBox(
            child: FlatButton(
              color: Color(0xFF00BFFF),
              child: Text(
                "删除",
                style: TextStyle(fontSize: _width / 20),
              ),
              onPressed: () async {
                if (null != widget.onDeleteFn) {
                  final msg = await widget.onDeleteFn();
                  if ((null != msg) && ("" != msg)) {
                    Scaffold.of(context2).showSnackBar(
                      SnackBar(
                        content: Text(
                          msg,
                          style: TextStyle(
                              color: Colors.red, fontSize: _width / 20),
                        ),
                        duration: Duration(seconds: 5),
                        backgroundColor: Colors.tealAccent,
                      ),
                    );
                    return;
                  }
                }
                Navigator.of(context2).pop();
              },
            ),
          ),
        ),
        SizedBox(width: _width / 5),
      ],
    ));
  }

  Widget _buildButtonLine(BuildContext context2) {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          child: FittedBox(
            child: FlatButton(
              color: Colors.grey[350],
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
              color: Colors.grey[350],
              child: Text(
                "提交",
                style: TextStyle(fontSize: _width / 20),
              ),
              onPressed: () async {
                if ((null != _nameController.text) &&
                    ("" != _nameController.text)) {
                  _newAssignmentData.name = _nameController.text;
                } else {
                  return;
                }

                if ((null != _targetController.text) &&
                    ("" != _targetController.text)) {
                  try {
                    _newAssignmentData.target =
                        int.parse(_targetController.text);
                  } catch (e) {
                    return;
                  }
                } else {
                  _newAssignmentData.target = null;
                }

                if ((null != _otherDoneController.text) &&
                    ("" != _otherDoneController.text)) {
                  try {
                    _newAssignmentData.otherDone =
                        int.parse(_otherDoneController.text);
                  } catch (e) {
                    return;
                  }
                } else {
                  _newAssignmentData.otherDone = null;
                }

                if ((null != _stepController.text) &&
                    ("" != _stepController.text)) {
                  try {
                    if ("0" == _stepController.text) {
                      return;
                    }
                    _newAssignmentData.step = int.parse(_stepController.text);
                  } catch (e) {
                    return;
                  }
                }

                if (_DateType.useDate == _beginDateType) {
                  _newAssignmentData.beginDate = _beginDate;
                } else {
                  _newAssignmentData.beginDate = null;
                }

                if (_DateType.useDate == _endDateType) {
                  _newAssignmentData.endDate = _endDate;
                } else {
                  _newAssignmentData.endDate = null;
                }

                if (null != widget.onCommitFn) {
                  final String msg =
                      await widget.onCommitFn(_newAssignmentData);
                  if ((null != msg) && ("" != msg)) {
                    _lastName = _newAssignmentData.name;
                    _nameErrText = msg;
                    Scaffold.of(context2).showSnackBar(
                      SnackBar(
                        content: Text(
                          msg,
                          style: TextStyle(
                              color: Colors.red, fontSize: _width / 20),
                        ),
                        duration: Duration(seconds: 5),
                        backgroundColor: Colors.tealAccent,
                      ),
                    );
                    setState(() {});
                    return;
                  }
                }
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
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: Builder(builder: (BuildContext context2) {
        final verticalDividerHeight = _width * 20 / 100;
        final children = [
          SizedBox(/*width: _width / 20,*/ height: _width / 20),
          _buildTitleInputBox(),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOtherDoneInputBox(),
              Container(
                height: verticalDividerHeight,
                child: VerticalDivider(color: Colors.grey),
              ),
              SizedBox(width: _width * 4 / 10, height: _width * 19 / 100),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTargetInputBox(),

              Container(
                height: verticalDividerHeight,
                child: VerticalDivider(color: Colors.grey),
              ),
//              _buildExpirationDateInputBox(),
              _buildStepInputBox(),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStartDateInputBox(),
              Container(
                height: verticalDividerHeight,
                child: VerticalDivider(color: Colors.grey),
              ),
              _buildExpirationDateInputBox(),
            ],
          ),
          Divider(),
          SizedBox(height: _width / 20),
        ];

        if (null != widget.oldAssignmentData) {
          children.add(_buildDeteleButton(context2));
        }
        children.add(SizedBox(height: _width / 20));
        children.add(_buildButtonLine(context2));

        return Scrollbar(
            child: SingleChildScrollView(
                child: Container(
                    child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: children,
        ))));
      }),
    );
  }
}
