import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../common_util.dart';
import 'assignment_add_edit_page.dart';
import 'assignment_card.dart';
import 'assignment_data.dart';
import 'assignment_import_export.dart';

class AssignmentDetailView extends StatefulWidget {
  static int g_showingPageindex = 0;
  AssignmentDetailViewState _viewState;
  void setShowingPage(int showingPageindex) {
    g_showingPageindex = showingPageindex;
    if ((null != _viewState) && (_viewState.mounted)) {
      _viewState.setState(() {});
    }
    return;
  }

  @override
  State<StatefulWidget> createState() {
    _viewState = AssignmentDetailViewState();
    return _viewState;
  }
}

class AssignmentDetailViewState extends State<AssignmentDetailView> {
  final double _width = MediaQueryData.fromWindow(window).size.width;
  final double _height = MediaQueryData.fromWindow(window).size.height;
  double _bigBoxWidth;
  double _smallBoxWidth;
  double _smallBoxHeight;

  AssignmentDetailViewState() {
    _bigBoxWidth = _width * 9 / 10;
    _smallBoxWidth = _bigBoxWidth / 2;
    _smallBoxHeight = _width * 8 / 100;

    return;
  }

  final _fmt = DateFormat('yyyy-MM-dd');

  List<AssignmentData> _assignmentDataList;

  @override
  initState() {
    super.initState();

    _fetchData();

    return;
  }

  @override
  void dispose() {
    super.dispose();
    return;
  }

  _fetchData() async {
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
        // child = _buildAssignmentCards();
        // child = ListView.separated(
        //   itemBuilder: (BuildContext context, int index) {
        //     if (index < _assignmentDataList.length) {
        //       return AssignmentCard(_assignmentDataList[index], refresh: () {
        //         setState(() {});
        //       });
        //     }
        //     return null;
        //   },
        //   separatorBuilder: (BuildContext context, int index) {
        //     return Divider();
        //   },
        //   itemCount:_assignmentDataList.length ,
        // );

        if (_assignmentDataList.length <=
            AssignmentDetailView.g_showingPageindex) {
          AssignmentDetailView.g_showingPageindex =
              _assignmentDataList.length - 1;
        }

        final PageController pageController = PageController(
            viewportFraction: 0.8,
            initialPage: AssignmentDetailView.g_showingPageindex);

        final PageView pageView = PageView.builder(
          scrollDirection: Axis.vertical,
          // scrollDirection: Axis.horizontal,
          controller: pageController, // 从1开始
          onPageChanged: (int index) {
            AssignmentDetailView.g_showingPageindex = index;
            return;
          },
          itemBuilder: (BuildContext context, int index) {
            if (index < _assignmentDataList.length) {
              return AssignmentCard(_assignmentDataList[index], refresh: () {
                setState(() {});
              });
            }
            return null;
          },
          itemCount: _assignmentDataList.length,
        );

        var indicator = SmoothPageIndicator(
          controller: pageController,
          axisDirection: Axis.vertical,
          count: _assignmentDataList.length,
          onDotClicked: (int index) {
            pageController.animateToPage(index,
                duration: Duration(milliseconds: 500), curve: Curves.easeOut);
            return;
          },
          // effect: WormEffect(),
        );

        final popMenuButton = PopupMenuButton<String>(
          icon: Icon(Icons.list, color: Colors.cyan, size: _width * 12 / 100),
          itemBuilder: (context) {
            return <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: '导入导出',
                //child: Text('语文'),
                child: _buildImportExportButton(),
              ),
              PopupMenuItem<String>(
                value: '新建课程',
                child: _buildAddNewButton(),
              ),
            ];
          },
        );

        final toTopButton = GestureDetector(
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.cyan, width: 1.5),
                borderRadius: BorderRadius.circular((20.0))),
            child: Icon(Icons.vertical_align_top,
                color: Colors.cyan, size: _width * 10 / 100),
          ),
          onTap: () {
            pageController.animateToPage(0,
                duration: Duration(milliseconds: 500), curve: Curves.easeOut);
            return;
          },
        );

        child = Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(width: _width * 96 / 100, child: pageView),
                Container(width: _width * 2 / 100, child: indicator),
                // SizedBox(width: _width * 2 / 100),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  popMenuButton,
                  SizedBox(width: _width * 6 / 100),
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  SizedBox(width: _width * 10 / 100, child: Divider()),
                  SizedBox(width: _width * 6 / 100),
                ]),
                SizedBox(height: _width * 2 / 100),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  toTopButton,
                  SizedBox(width: _width * 5 / 100),
                ]),
              ],
            ),
          ],
        );
      }
    }

    return Scaffold(
      body: Container(
//      decoration: BoxDecoration(color: Colors.cyan[100]),
          child: child),
    );

    return Scaffold(
      body: Container(
//      decoration: BoxDecoration(color: Colors.cyan[100]),
          child: Scrollbar(child: child)),
    );

    return Scaffold(
      body: Container(
//      decoration: BoxDecoration(color: Colors.cyan[100]),
          child: Scrollbar(child: SingleChildScrollView(child: child))),
    );
  }

  Widget _buildEmptyPrompt() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: _width * 2 / 100),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_buildImportExportButton(), _buildAddNewButton()],
        ),
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

  Widget _buildAssignmentCards() {
    bool testShowOne = false;
//    testShowOne = true; // for test

    Widget child;
    if (testShowOne) {
      child = AssignmentCard(_assignmentDataList.first, refresh: () {
        setState(() {});
      });
    } else {
      child = Column(
          children: _assignmentDataList.map((a) {
        return AssignmentCard(a, refresh: () {
          setState(() {});
        });
      }).toList());
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: _width * 2 / 100),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_buildImportExportButton(), _buildAddNewButton()],
        ),
        SizedBox(height: _width * 1 / 100),
        child,
        SizedBox(height: _width / 100),
      ],
    );
  }

  _buildAddNewButton() {
    return _buildButton1(
      "新增功课",
      Icons.add_circle_outline,
      () async {
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return AssignmentAddEditPage.addNew(
              onCommitFn: (AssignmentData value) async {
            final msg = await value.apply();
            return msg;
          });
        }));
        setState(() {}); // 返回后需要刷新一下
      },
    );
  }

  _buildImportExportButton() {
    return _buildButton1(
      "导入导出",
      Icons.import_export,
      () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ImportExport(afterImport: () async {
            await _fetchData();
            setState(() {});
          });
        }));
      },
    );
  }

  Widget _buildButton1(
      String title, IconData icon, void Function() onPressedFn) {
    return Container(
        width: _smallBoxWidth,
        height: _width / 10,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // color: Colors.cyanAccent,
          border: Border.all(width: 1.0, color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: FittedBox(
            child: FlatButton.icon(
//          color: Colors.cyanAccent,
          icon: Icon(icon, size: _width / 10, color: Colors.cyan),
          label: Text(title,
              style: TextStyle(fontSize: _width / 15, color: Colors.cyan)),
          onPressed: onPressedFn,
        )));
  }
}
