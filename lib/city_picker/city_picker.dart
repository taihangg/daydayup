import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'city_data_manager.dart';

class CityPicker extends StatefulWidget {
  final Function(String fullCityName, String cityCode) onSelectedFn;
  final String initCity;
  final bool autoFoucus;
  final String hintText;
  CityPicker(
      {this.onSelectedFn,
      this.initCity,
      this.autoFoucus = false,
      this.hintText = '请输入城市'}) {
    assert(null != onSelectedFn);
    assert(null != hintText);
  }

  @override
  State<StatefulWidget> createState() {
    return _CityPickerState();
  }
}

class _CityPickerState extends State<CityPicker> {
  final double _width = MediaQueryData.fromWindow(window).size.width;
  final double _height = MediaQueryData.fromWindow(window).size.height;
  double _fontSize;

  _CityPickerState() {
    _fontSize = _width / 17;
  }

  final TextEditingController _typeAheadController = TextEditingController();
  CityLevel _selectedItem;

  @override
  void initState() {
    super.initState();
    if (null != widget.initCity) {
      _typeAheadController.text = widget.initCity;
    }
  }

  @override
  void dispose() {
//    _typeAheadController.dispose();
    super.dispose();
  }

  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
//    return _buildTypeAheadField(context);
    return _buildTypeAheadFormField(context);
  }

//  Widget _buildTypeAheadField(BuildContext context) {
//    return Stack(
//      alignment: AlignmentDirectional.topEnd,
//      children: [
//        TypeAheadField<CityItem>(
//          keepSuggestionsOnSuggestionSelected: true,
//          getImmediateSuggestions: true,
//          textFieldConfiguration: TextFieldConfiguration(
//            focusNode: _focusNode,
//            decoration: InputDecoration(
//              border: OutlineInputBorder(),
//              hintText: widget.hintText,
//              hintStyle: TextStyle(color: Colors.black87),
//            ),
//            controller: _typeAheadController,
//            style: TextStyle(fontSize: _fontSize, color: Colors.black87),
//            autofocus: (true == widget.autoFoucus),
//            onChanged: (e) {
////              _show = true;
//              _selectedItemData = null;
////              setState(() {});
//            },
//          ),
//          suggestionsCallback: (String pattern) {
//            if (true == _show) {
////              _typeAheadController.text = "";
//              _show = false;
////              FocusScope.of(context).requestFocus(_focusNode);
////              return null;
//            }
//            List<CityItem> items;
//            if (("" == pattern) || (null == _selectedItemData)) {
//              items = CityDataMgr.findCities(pattern);
//            } else {
//              if (_selectedItemData.city["id"].length < 6) {
//                items = CityDataMgr.getChildren(_selectedItemData);
//              } else {
//                widget.onSelectedFn(_selectedItemData.fullName,
//                    int.parse(_selectedItemData.city["code"]));
////                FocusScope.of(context).requestFocus(FocusNode()); // 隐藏键盘
//              }
//            }
//
//            return items;
//          },
//          itemBuilder: (context, CityItem itemData) {
//            return Card(
//              child: Text(itemData.fullName,
//                  style: TextStyle(fontSize: _fontSize, color: Colors.orange)),
//            );
//          },
//          onSuggestionSelected: (CityItem itemData) {
//            _selectedItemData = itemData;
//            _typeAheadController.text = itemData.fullName;
//
////        setState(() {});
//          },
//          noItemsFoundBuilder: (BuildContext context) {
//            return Padding(
//              child: Text("没有对应城市",
//                  style: TextStyle(fontSize: _fontSize, color: Colors.grey)),
//              padding: EdgeInsets.all(5.0),
//            );
//          },
//        ),
//        Container(
//          padding: EdgeInsets.only(top: _fontSize / 2),
//          child: FlatButton(
//            child: Icon(_show ? Icons.search : Icons.close,
//                size: _fontSize, color: Colors.black87),
//            onPressed: () {
//              _show = !_show;
//              if (_show) {
//                _typeAheadController.text = "";
//                FocusScope.of(context).requestFocus(FocusNode()); // 隐藏键盘
//
//              } else {
////                _typeAheadController.text = widget.hintText; // 设置空白，触发回调
//                FocusScope.of(context).requestFocus(_focusNode);
//              }
//              setState(() {});
//            },
//          ),
//        ),
//      ],
//    );
//  }

  bool _foucused = false;
  Widget _buildTypeAheadFormField(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        TypeAheadFormField<CityLevel>(
          keepSuggestionsOnSuggestionSelected: true,
          getImmediateSuggestions: true,
          textFieldConfiguration: TextFieldConfiguration(
            focusNode: _focusNode,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: widget.hintText,
              hintStyle: TextStyle(color: Colors.grey),
            ),
            controller: _typeAheadController,
            style: TextStyle(fontSize: _fontSize, color: Colors.orangeAccent),
            autofocus: (true == widget.autoFoucus),
            onChanged: (e) {
              _selectedItem = null;
              _foucused = true;
            },
          ),
          suggestionsCallback: (String pattern) {
            _foucused = true;
            List<CityLevel> items;
            if (null == _selectedItem) {
              items = CityDataMgr.findCities(pattern);
            } else {
              if (_selectedItem.level < 3) {
                items = CityDataMgr.getChildren(_selectedItem);
              } else {
//                _typeAheadController.text = "";
//                FocusScope.of(context)
//                    .requestFocus(FocusNode()); // 隐藏键盘，否则选中后还会显示
//                FocusScope.of(context).requestFocus(_focusNode);
//                return null;
                widget.onSelectedFn(
                    _selectedItem.fullName, _selectedItem.cityCode.toString());
                _selectedItem = null;
              }
            }

            return items;
          },
          itemBuilder: (context, CityLevel itemData) {
            return Card(
              child: Text(itemData.fullName,
                  style: TextStyle(fontSize: _fontSize, color: Colors.orange)),
            );
          },
          onSuggestionSelected: (CityLevel itemData) {
            _selectedItem = itemData;
            _typeAheadController.text = itemData.fullName;
          },
          noItemsFoundBuilder: (BuildContext context) {
            return Padding(
              child: Text("没有对应城市",
                  style: TextStyle(fontSize: _fontSize, color: Colors.grey)),
              padding: EdgeInsets.all(5.0),
            );
          },
        ),
        Container(
          padding: EdgeInsets.only(top: _fontSize / 2),
          child: FlatButton(
            child: Icon(Icons.backspace,
                size: _fontSize,
                color: ("" == _typeAheadController.text)
                    ? Colors.grey
                    : Colors.black87),
            onPressed: () {
              if ("" != _typeAheadController.text) {
                _typeAheadController.text =
                    _trimLast(_typeAheadController.text);
                _selectedItem = null;
                FocusScope.of(context)
                    .requestFocus(_focusNode); // 之前有可能隐藏了键盘，呼出键盘
              } else if (_foucused) {
                assert(null == _selectedItem);
//                _typeAheadController.text = " ";
                _foucused = false;
                FocusScope.of(context).requestFocus(FocusNode()); // 失焦，隐藏键盘
              } else {
                assert(null == _selectedItem);
                _foucused = true;
                FocusScope.of(context).requestFocus(_focusNode); // 重新打开键盘
              }
//              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  String _trimLast(String fullName) {
    String upLevel = "";
    if (null != fullName) {
      final end = fullName.lastIndexOf(" ");
      if (0 < end) {
        upLevel = fullName.substring(0, end);
      }
    }
    return upLevel;
  }
}
