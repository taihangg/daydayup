import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserDefinedFestirvalEditor extends StatefulWidget {
//  final double screenHeight;
  String oldText;
  String Function(String) onSaveFn;
  UserDefinedFestirvalEditor(this.oldText, this.onSaveFn) {}

  @override
  State<StatefulWidget> createState() {
    return UserDefinedFestirvalEditorState();
  }
}

class UserDefinedFestirvalEditorState
    extends State<UserDefinedFestirvalEditor> {
  String _newText;
//  UserDefinedFestirvalEditorState();

  double _width = MediaQueryData.fromWindow(window).size.width;
  double _height = MediaQueryData.fromWindow(window).size.height;

  double _fontSize;

  final _controller = TextEditingController();

  @override
  initState() {
    super.initState();

    _newText = widget.oldText;
    _fontSize = _width / 20;
    _controller.text = widget.oldText;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Builder(builder: (BuildContext context) {
        return Scrollbar(
            child: SingleChildScrollView(
                child: Column(
//      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
//          SizedBox(width: _width / 40, height: _width / 40),
//          _buildExample(),
            SizedBox(width: _width / 40, height: _width / 40),
            _buildTextInput(),
            SizedBox(width: _width / 40, height: _width / 40),
            _buildButtonRow(context),
          ],
        )));
      }),
    );
  }

  Widget _buildExample() {
    final _exampleText = """G11.11/#FF8C00/光棍节
#注释：公历11月11日/颜色RGB/内容

L0.1/#FF8C00/十斋日
L0.8/#FF8C00/十斋日
L0.14/#FF8C00/十斋日
L0.15/#FF8C00/十斋日
L0.18/#FF8C00/十斋日
L0.23/#FF8C00/十斋日
L0.24/#FF8C00/十斋日
L0.-3/#FF8C00/十斋日
L0.-2/#FF8C00/十斋日
L0.-1/#FF8C00/十斋日
#最后一条的意义：农历每月最后一天/颜色RGB/内容
""";
    return Scrollbar(
        child: SingleChildScrollView(
            child: Container(
//      width: _width * 100 / 100,
      height: _height * 7 / 10,
//      decoration: BoxDecoration(
//        color: Colors.blue[300],
//        border: Border.all(width: 0.5, color: Colors.black38),
//        borderRadius: BorderRadius.all(Radius.circular(6.0)),
//      ),
      child: TextFormField(
        initialValue: _exampleText,
        readOnly: true,
//        controller: TextEditingController()..text = _exampleText,
//      autofocus: true,
        maxLines: 20,
        minLines: 20,
        decoration: InputDecoration(
//        icon: Icon(Icons.event_note, color: Colors.black),
//          hintText: "xxx",
//          hintStyle: TextStyle(fontSize: _width / 25, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        style: TextStyle(fontSize: _fontSize),
        onChanged: (String str) {
          _newText = str;
        },
      ),
    )));
  }

  Widget _buildTextInput() {
    return Scrollbar(
        child: SingleChildScrollView(
            child: Container(
      width: _width * 9 / 10,
      height: _height * 75 / 100,
//      decoration: BoxDecoration(
//        color: Colors.blue[300],
//        border: Border.all(width: 0.5, color: Colors.black38),
//        borderRadius: BorderRadius.all(Radius.circular(6.0)),
//      ),
      child: TextField(
        controller: _controller,
//      autofocus: true,
        maxLines: 1000,
        minLines: 22,
        decoration: InputDecoration(
//        icon: Icon(Icons.event_note, color: Colors.black),
          hintText: "点击此处，\n输入节日名称!",
          hintStyle: TextStyle(fontSize: _fontSize, color: Colors.grey[500]),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        style: TextStyle(fontSize: _fontSize),
        onChanged: (String str) {
          _newText = str;
        },
      ),
    )));
  }

  Widget _buildButtonRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          child: Text("退出", style: TextStyle(fontSize: _fontSize)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        RaisedButton(
          child: Text("保存", style: TextStyle(fontSize: _fontSize)),
          onPressed: () {
            final log = widget.onSaveFn(_newText);
            if ((null == log) || ("" == log)) {
              Navigator.pop(context);
            } else {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(
                  log,
                  style: TextStyle(color: Colors.red, fontSize: _fontSize),
                ),
                duration: Duration(seconds: 5),
                backgroundColor: Colors.tealAccent,
//    action: SnackBarAction(
//      label: "button",
//      onPressed: () {
//        print("in press");
//      },
//    ),
              ));
            }
          },
        )
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('自定义节日'),
      actions: [
        MaterialButton(
//          color: Colors.orange,
          child: Text("帮助示例",
              style: TextStyle(color: Colors.black, fontSize: _width / 15)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return SimpleDialog(
                  title: Text("帮助示例",
                      style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: _width / 15)),
                  children: [
                    _buildExample(),
//                    Divider(),
                    FlatButton(
                      child: Text('返回',
                          style: TextStyle(
                              color: Colors.lightBlueAccent,
                              fontSize: _width / 15)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
