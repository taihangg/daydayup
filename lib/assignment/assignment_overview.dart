import 'dart:ui';

import 'package:flutter/material.dart';

import '../common_util.dart';
import 'assignment_bar.dart';
import 'assignment_data.dart';

class AssignmentOverview extends StatefulWidget {
  final void Function(int index) onTapTitle;
  AssignmentOverview(this.onTapTitle);

  @override
  State<StatefulWidget> createState() {
    return _AssignmentOverviewState();
  }
}

class _AssignmentOverviewState extends State<AssignmentOverview>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final double _width = MediaQueryData.fromWindow(window).size.width;
  final double _height = MediaQueryData.fromWindow(window).size.height;

  _AssignmentOverviewState() {
    _init();
  }

  @override
  bool get wantKeepAlive => true;

  List<AssignmentData> _assignmentDataList;

  _init() async {
    _assignmentDataList = await AssignmentData.getAllAssignment();
//    await Future.delayed(Duration(seconds: 100));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (null == _assignmentDataList) {
      child = buildLoadingView();
    } else {
      if (_assignmentDataList.isEmpty) {
        child = _buildEmptyPrompt();
      } else {
        child = _buildAssignmentList();
      }
    }

    return child;

    return Scaffold(
      body:
//      Scrollbar(
//        child: SingleChildScrollView(
//      child:
          child,
//        ),
//      ),
    );
  }

  Widget _buildEmptyPrompt() {
    assert(_assignmentDataList.isEmpty);
    return Column(
//      key: ValueKey(0),
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: _width * 2 / 5),
        Center(
          child: Text(
            "没有功课，\n请先添加！",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: _width / 10),
          ),
        ),
        SizedBox(height: _width / 20),
      ],
    );
  }

  Widget _buildAssignmentList() {
    assert(null != _assignmentDataList);
    assert(_assignmentDataList.isNotEmpty);

    List<Color> colors = [Colors.lightBlueAccent, Colors.orange];
    int colorInt = 0;

    return Column(
//      mainAxisSize: MainAxisSize.min,
      children: [
//        SizedBox(height: _height * 1 / 100),
        AssignmentBar.title(),
        Expanded(
//            height: _height * 80 / 100,
            child: ReorderableListView(
//          header: AssignmentItem.title(),
          children: _assignmentDataList.map((a) {
            colorInt = (colorInt + 1) % colors.length;
            return AssignmentBar(a, colors[colorInt], widget.onTapTitle);
          }).toList(),
          onReorder: (int oldIndex, int newIndex) {
            final a = _assignmentDataList.removeAt(oldIndex);
            if (oldIndex < newIndex) {
              newIndex = newIndex - 1;
            }
            _assignmentDataList.insert(newIndex, a);
            AssignmentData.updateAllAssignmentSortSequence();
            setState(() {});
          },
        )),
      ],
    );
  }
}
