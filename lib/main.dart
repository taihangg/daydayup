import 'dart:ui';

import 'assignment/assignment_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'calendar/month_todo_page.dart';
import 'my_navigation_bar.dart';
import 'weather/weather_view.dart';
import 'assignment/assignment_detail_view.dart';
import 'plugins/common_localizations_delegate.dart';

void main() {
//  testFn();

  MediaQueryData mediaQuery = MediaQueryData.fromWindow(window);
  double _width = mediaQuery.size.width;
  double _height = mediaQuery.size.height;
  double _topbarH = mediaQuery.padding.top;
  double _botbarH = mediaQuery.padding.bottom;
  double _pixelRatio = mediaQuery.devicePixelRatio;
  print("xxx main $_width $_height $_topbarH $_botbarH $_pixelRatio");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        //自定义代理
        CommonLocalizationsDelegate(),
//        DefaultCupertinoLocalizations.delegate,
//        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Locale("zh", "CN"),
      supportedLocales: [Locale('zh', 'CN'), Locale('en', 'US')],
      title: '天天向上',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  _HomePage({Key key}) : super(key: key);

  @override
  createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<_HomePage> {
  _HomePageState() {
    _checkPermission();
  }

  final double _width = MediaQueryData.fromWindow(window).size.width;
  final double _height = MediaQueryData.fromWindow(window).size.height;

  int _bottomBarSelectIndex = 0; // 默认第一个

  final List<Widget> _tabList = [];
  final List<Widget> _tabBarViewChildren = [];

  @override
  void initState() {
    super.initState();

    _addAssignmentOverview();
    _addAssignmentDetail();
    _addMonthTodoPage();
    _addWeather();
  }

  @override
  Widget build(BuildContext context) {
    var bottomNavigateBar = Container(
        height: _height * 11 / 100,
        child: MyBottomNavigationBar((int index) {
          if (_bottomBarSelectIndex != index) {
            _bottomBarSelectIndex = index;
            setState(() {});
          }
        }));

    return DefaultTabController(
      length: _tabList.length,
      child: WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomPadding: false, //避免软键盘把widget顶上去
          appBar: AppBar(
            //leading: Text('Tabbed AppBar'),
            //title: const Text('Tabbed AppBar'),
            title: TabBar(isScrollable: false, tabs: _tabList),
//      bottom: myTabBar,
          ),
//      body: _tabBarViewChildren[_bottomBarSelectIndex],
          body: TabBarView(children: _tabBarViewChildren),
//      bottomNavigationBar: bottomNavigateBar,
        ),
        onWillPop: _onWillPop,
      ),
    );
  }

  _addMonthTodoPage() {
    _tabList.add(Tab(
//        text: "日历",
      icon: Icon(Icons.border_all),
    ));

    _tabBarViewChildren.add(MonthTodoPage());
  }

  _addAssignmentDetail() {
    _tabList.add(Tab(
//      text: "功课",
      icon: Icon(Icons.assignment),
    ));

    _tabBarViewChildren.add(AssignmentDetailView());
  }

  _addAssignmentOverview() {
    _tabList.add(Tab(
//      text: "功课",
//      icon: Icon(Icons.dehaze),
//      icon: Icon(Icons.sort),
      icon: Icon(Icons.format_list_bulleted),
    ));

    _tabBarViewChildren.add(AssignmentOverview());
  }

  _addWeather() {
    _tabList.add(Tab(
//        text: "天气",b
      icon: Icon(Icons.wb_sunny),
    ));

    _tabBarViewChildren.add(WeatherPage());
  }

  _checkPermission() async {
    PermissionStatus storagePermission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (PermissionStatus.granted != storagePermission) {
//    bool isOpened = await PermissionHandler().openAppSettings();

      Map<PermissionGroup, PermissionStatus> status = await PermissionHandler()
          .requestPermissions([PermissionGroup.storage]);

//      if (PermissionStatus.granted != status.values.first.value) {
//        Scaffold.of(context).showSnackBar(SnackBar(
//          content: Text(
//            "请允许app读写存储的权限\n否则无法工作",
//            style: TextStyle(color: Colors.red, fontSize: 50),
//          ),
//          duration: Duration(seconds: 5),
//          backgroundColor: Colors.tealAccent,
////    action: SnackBarAction(
////      label: "button",
////      onPressed: () {
////        print("in press");
////      },
////    ),
//        ));
//      }
    }

    return;
  }

  DateTime _lastPopTime;
  Future<bool> _onWillPop() async {
    // 点击返回键的操作
    if (_lastPopTime == null ||
        DateTime.now().difference(_lastPopTime) > Duration(seconds: 2)) {
      _lastPopTime = DateTime.now();
      Fluttertoast.showToast(
        msg: "再按一次退出",
//        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
//        timeInSecForIos: 1,
//        backgroundColor: Colors.red,
//        textColor: Colors.grey,
        fontSize: _width / 12,
      );
      return false;
    } else {
      _lastPopTime = DateTime.now();
      // 退出app
      return await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }
}
