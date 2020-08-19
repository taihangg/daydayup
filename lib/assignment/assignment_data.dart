import 'package:sqflite/sqflite.dart';

import '../common_util.dart';
import '../database_manager.dart';

class DailyData {
  int date;
  int done;
  DailyData(this.date, this.done);
  DailyData.fromMap(Map<String, dynamic> m) {
    date = m[AssignmentData._columnDate];
    done = m[AssignmentData._columnDailyDone];
  }
}

class AssignmentData {
  int ID; // 数据库中的唯一标识
  String name; // 功课名字

  int otherDone; // 起始数量（之前已经完成的数量）
  DateTime firstDate; // 第一次有完成数量的日期 // 最长见用来算时间差，还是用DateTime类型
  int allSum = 0; // 总已完成数量，不包括 otherDone 的数量
  int step = 1; // 步进，快捷增减用的

  DateInt lastUpdateDateInt; // 最新更新日期

  int continuousDaysCount = 0; // 连续未间断的天数

  DateTime beginDate; // 开始日期
  DateInt beginDateInt;
  DateTime endDate; // 截止日期 // 最长见用来算时间差，还是用DateTime类型
  DateInt endDateInt;
  int target; // 目标数量，可以不设置
  int periodSum = 0; // 本阶段时间范围内的总数

  int sortSequence; // 显示顺序

  // _dailyYears保存所有有数据的年份，需要一开始就从数据库中全部读取出来
  // 查找数据：_dailyDatas中对应的年份map为null，
  //   1：_dailyYears没有对应的年份，则该年尚无数据；
  //   2：_dailyYears有对应的年份，则该年数据尚未从数据库中读取；
  // 添加数据
  //   1：_dailyYears没有对应的年份，则添加数据的同时，需要添加年份；
  //   2：_dailyYears有对应的年份，则仅需添加日数据；
  final List<int> _dailyYears = [];
  final Map<int, Map<int, int>> _dailyDatas = {}; // year,date,done

  AssignmentData() {}

  static const tableAssignment = "assignment";
  static const tableYear = "year";
  static const tableDaily = "daily";

  static const _columnID = "id";
  static const _columnAssignmentName = "name";

  static const _columnOtherDone = "otherDone";
  static const _columnFirstDate = "firstDate";
  static const _columnAllSum = "allSum";
  static const _columnStep = "step";
  static const _columnLastUpdateDate = "lastUpdateDate";
  static const _columnContinuousDaysCount = "continuousDaysCount";

  static const _columnBeginDate = "beginDate";
  static const _columnEndDate = "endDate";
  static const _columnTarget = "target";
  static const _columnPeriodSum = "periodSum";

  static const _columnSortSequence = "sortSequence";

  static const _columnYear = "year";
  static const _columnDate = "date";
  static const _columnDailyDone = "done";

//  static final DateFormat _dateFmt = DateFormat("yyyy-MM-dd");

  static const String _sqlCreateTableAssignment =
      '''CREATE TABLE ${tableAssignment} (
${_columnID} INTEGER PRIMARY KEY AUTOINCREMENT,
${_columnAssignmentName} TEXT UNIQUE,
${_columnOtherDone} INTEGER,
${_columnFirstDate} INTEGER,
${_columnAllSum} INTEGER,
${_columnStep} INTEGER,
${_columnLastUpdateDate} INTEGER,
${_columnContinuousDaysCount} INTEGER,
${_columnBeginDate} INTEGER, 
${_columnEndDate} INTEGER,
${_columnTarget} INTEGER,
${_columnPeriodSum} INTEGER,
${_columnSortSequence} INTEGER
);''';

  static const String _sqlCreateTableYear = '''CREATE TABLE ${tableYear} (
${_columnID} INTEGER,
${_columnYear} INTEGER,
primary key (${_columnID}, ${_columnYear})
);''';

  static const String _sqlCreateTableDaily = '''CREATE TABLE ${tableDaily} (
${_columnDate} INTEGER,
${_columnID} INTEGER,
${_columnDailyDone} INTEGER,
primary key (${_columnDate}, ${_columnID})
);''';

  static List<String> _onDBCreateSqlList = [
    _sqlCreateTableAssignment,
    _sqlCreateTableYear,
    _sqlCreateTableDaily,
  ];
  static DatabaseManager _dbMgr = DatabaseManager(_onDBCreateSqlList);

  AssignmentData.fromMap(Map<String, dynamic> m) {
    dynamic tmp;

    ID = m[_columnID];
    name = m[_columnAssignmentName];
    otherDone = m[_columnOtherDone];

    tmp = m[_columnFirstDate];
    firstDate = (null != tmp) ? DateInt.fromInt(tmp).dt : null;

    allSum = m[_columnAllSum];
    step = m[_columnStep];

    tmp = m[_columnLastUpdateDate];
    lastUpdateDateInt = (null != tmp) ? DateInt.fromInt(tmp) : null;

    continuousDaysCount = m[_columnContinuousDaysCount];

    tmp = m[_columnBeginDate];
    beginDate = (null != tmp) ? DateInt.fromInt(tmp).dt : null;

    tmp = m[_columnEndDate];
    endDate = (null != tmp) ? DateInt.fromInt(tmp).dt : null;

    target = m[_columnTarget];
    periodSum = m[_columnPeriodSum];

    sortSequence = m[_columnSortSequence];

    assert((null != name) && ("" != name));
    assert((null != step) && (0 < step));
    assert((null != continuousDaysCount) && (0 <= continuousDaysCount));
  }

  static List<AssignmentData> _assignmentDataList;
  static Future<List<AssignmentData>> getAllAssignment() async {
    if (null == _assignmentDataList) {
      _assignmentDataList = await _queryAllAssignment();
    }
    return _assignmentDataList;
  }

  Future<Map<int, int>> _getYearData(int year) async {
    assert(null != year);

    assert(null != _dailyDatas);

    final yearData = _dailyDatas[year];
    if (null != yearData) {
      return yearData;
    }

    if (_hasYear(year)) {
      // 从数据库中查找
      final newYearData = await _queryDailyDataByYearFromDB(year);

      return newYearData;
    }

    return null;
  }

  Future<Map<int, int>> _addNewYear(int year) async {
    _dailyYears.add(year);
    _dailyYears.sort();
    await _insertYear2DB(year);

    assert(null == _dailyDatas[year]);
    final Map<int, int> newYearData = {};
    _dailyDatas[year] = newYearData;
    return newYearData;
  }

  static Future<List<AssignmentData>> _queryAllAssignment() async {
    List<Map<String, dynamic>> result = await _dbMgr.query(
      tableAssignment,
      columns: [
        _columnID,
        _columnAssignmentName,
        _columnOtherDone,
        _columnFirstDate,
        _columnAllSum,
        _columnStep,
        _columnLastUpdateDate,
        _columnContinuousDaysCount,
        _columnBeginDate,
        _columnEndDate,
        _columnTarget,
        _columnPeriodSum,
        _columnSortSequence,
      ],
    );

//    print("xxx a=${result.length}");

    List<AssignmentData> assignmentDataList = [];
    result.forEach((Map<String, dynamic> m) {
      final a = AssignmentData.fromMap(m);
      a._correctContinuousDaysCount();
      assignmentDataList.add(a);
    });

    await _getAllYearFromDB(assignmentDataList);

    // 如果今年有数据，默认把今年的数据读出来
    final year = DateTime.now().year;

    for (final a in assignmentDataList) {
      if (a._hasYear(year)) {
        await a._queryDailyDataByYearFromDB(year);
      }
    }

    if (false) {
      // 以前可能有没有设置sortSequence的数据，这里处理一下
      for (final a in assignmentDataList) {
        if (null == a.sortSequence) {
          updateAllAssignmentSortSequence();
          break;
        }
      }
    }

    assignmentDataList.sort(_sortAssignmentBySortSequenceAsc);

    return assignmentDataList;
  }

//  static _testSort(List<AssignmentData> assignmentDataList) {
//
//  }

  static int _sortAssignmentBySortSequenceAsc(
      AssignmentData a, AssignmentData b) {
    if (a.sortSequence < b.sortSequence) {
      return -1;
    }
    return 1;
  }

  static _getAllYearFromDB(List<AssignmentData> assignmentDataList) async {
    assert(null != assignmentDataList);

    Map<int, List<int>> allAssignmentYears = await _queryAllYear();

    for (final a in assignmentDataList) {
      final yearsData = allAssignmentYears[a.ID];
      if (null != yearsData) {
        a._dailyYears.addAll(yearsData);
        a._dailyYears.sort();
      }
    }
  }

  static Future<Map<int, List<int>>> _queryAllYear() async {
    final List<Map<String, dynamic>> records = await _dbMgr.query(
      tableYear,
      columns: [_columnID, _columnYear],
      orderBy: "${_columnID}",
    );

    Map<int, List<int>> allAssignmentYears = {}; // Map<id, List<year>>
    List<int> years;
    int id;
    records.forEach((Map<String, dynamic> m) {
      final newId = m[_columnID];
      if (id != newId) {
        id = newId;

        years = allAssignmentYears[newId];
        if (null == years) {
          years = [];
          allAssignmentYears[newId] = years;
        }
      }
      years.add(m[_columnYear]);
    });

    return allAssignmentYears;
  }

  Future<Map<int, int>> _queryDailyDataByYearFromDB(int year) async {
    // 不增加_dailyYears的内容，
    // 所以一定是先确定_dailyYears中有对应年份，在调用本函数

    final List<Map<String, dynamic>> records = await _dbMgr.query(
      tableDaily,
      columns: [_columnDate, _columnDailyDone],
      where: "${_columnID}=? AND ${_columnDate}>=? AND ${_columnDate}<?",
      whereArgs: [ID, year * 10000, (year + 1) * 10000],
    );
    assert(records.length <= 365);

    Map<int, int> yearData = {};
    for (final r in records) {
      int date = r[_columnDate];
      int done = r[_columnDailyDone];
      yearData[date] = done;
    }

    _dailyDatas[year] = yearData;
    return yearData;
  }

  static const int _lineTagDataCount = 7;
  List<List> _lastLineTagData = [
    List.generate(_lineTagDataCount, (i) {
      return 0.0;
    }),
    List.generate(_lineTagDataCount, (i) {
      return " ";
    }),
  ];
  List<List> getLastLatestLineTagData() {
    return _lastLineTagData;
  }

  Future<List<List>> getLatestLineTagData() async {
    // 最近一年的数据在加载时就会默认读取到内存中，
    // 所以这里只读取内存操作，
    // 不异步读数据库

//    await Future.delayed(Duration(seconds: 9999999));

    List<double> datas = [];
    List<String> tags = [];
    final today = DateTime.now();
    var dateInt = DateInt(today);

    for (var i = 0; i < _lineTagDataCount; i++) {
      final data = await _getDailyDoneAsync(dateInt);
      final d = (null != data) ? data.toDouble() : 0.0;
      datas.insert(0, d);

      if ((i + 1 == _lineTagDataCount) || (1 == dateInt.day)) {
        tags.insert(0, "${dateInt.month}.${dateInt.day}");
      } else {
        tags.insert(0, "${dateInt.day}");
      }

      dateInt = dateInt.prevousDay;
    }

    _lastLineTagData = [datas, tags];
    return _lastLineTagData;
  }

  List<int> _lastLineData = [0, 0, 0];
  List<int> get lastLineData => _lastLineData;

  Future<List<int>> getLatestLineData(int count) async {
    // 最近一年的数据在加载时就会默认读取到内存中，
    // 所以这里只读取内存操作，
    // 不异步读数据库

//    await Future.delayed(Duration(seconds: 5));

    // 外部获取lastLineData会保存一段时间，
    // 所以这里产生了数据后，需要给lastLineData重新赋新对象，而不只是修改数组元素值
    //
    // 不能一开始就使用_lastLineData，
    // 因为下面的循环会分多次执行，
    // 而界面刷新时会连续重复调用本函数
    // 如果直接对_lastLineData进行赋新值并操作，而一个类实例共用一个_lastLineData，
    // 这种情况下_lastLineData的内容就会错乱

    List<int> data = [];
    final today = DateTime.now();
    var dateInt = DateInt(today);

    for (var i = 0; i < count; i++) {
//      print("xxx ${ID} ${dateInt.data}");
      final done = await _getDailyDoneAsync(dateInt);

      data.insert(0, done ?? 0);

      dateInt = dateInt.prevousDay;
    }

    _lastLineData = data;

    return data;
  }

  Future<Map<int, List<DailyData>>> getPrevousYearNonZeroDailyData(
      int year) async {
    int y = year;
    if (null == y) {
      if (_dailyYears.isNotEmpty) {
        y = _dailyYears.last + 1; // 最后一年的下一年
      } else {
        return null;
      }
    }

    List<DailyData> nonZeroYearData = [];
    do {
      y = _getPrevousYear(y);
      if (null == y) {
        return null;
      }

      final yearData = await _getYearData(y);
      if (null == yearData) {
        return null;
      }

      yearData.forEach((int date, int done) {
        assert(null != done);
        if (0 != done) {
          nonZeroYearData.add(DailyData(date, done));
        }
      });
    } while (nonZeroYearData.isEmpty);

    // 最新日期在最前面
    nonZeroYearData.sort(_sortDailyDataDesc);

    return {y: nonZeroYearData};
  }

  int _sortDailyDataDesc(DailyData a, DailyData b) {
    if (a.date < b.date) {
      return 1;
    } else if (a.date > b.date) {
      return -1;
    } else {
      return 0;
    }
  }

  int _getPrevousYear(int year) {
    assert(null != year);

    int y;
    for (final e in _dailyYears.reversed) {
      if (e < year) {
        y = e;
        break;
      }
    }
    return y;
  }

  Future<String> updateAfterEdit(AssignmentData newData) async {
    Map<String, dynamic> values = {};
    if (name != newData.name) {
      values[_columnAssignmentName] = newData.name;
    }

    if (otherDone != newData.otherDone) {
      values[_columnOtherDone] = newData.otherDone;
    }

    if (step != newData.step) {
      values[_columnStep] = newData.step;
    }
    bool periodModified = false;
    if (!isSameDay(beginDate, newData.beginDate)) {
      periodModified = true;

      values[_columnBeginDate] =
          (null != newData.beginDate) ? DateInt(newData.beginDate).data : null;
    }
    if (!isSameDay(endDate, newData.endDate)) {
      periodModified = true;
      values[_columnEndDate] =
          (null != newData.endDate) ? DateInt(newData.endDate).data : null;
    }
    if (target != newData.target) {
      values[_columnTarget] = newData.target;
    }

    int newPeriodSum = periodSum;
    if (periodModified) {
      newPeriodSum = await countPeriodSum(newData.beginDate, newData.endDate);
      if (periodSum != newPeriodSum) {
        periodSum = newPeriodSum;
        values[_columnPeriodSum] = newPeriodSum;
      }
    }

    if (values.isNotEmpty) {
      try {
        int res = await _dbMgr.update(
          tableAssignment,
          values,
          where: "${_columnID}=?",
          whereArgs: [ID],
        );
        assert(1 == res);
//        print("update ID=$ID res=$res");
      } catch (err) {
        return err.toString();
      }

      name = newData.name;
      otherDone = newData.otherDone;
      step = newData.step;
      target = newData.target;

      if (periodModified) {
        beginDate = newData.beginDate;
        beginDateInt = (null == beginDate) ? null : DateInt(beginDate);
        endDate = newData.endDate;
        endDateInt = (null == endDate) ? null : DateInt(endDate);

        periodSum = newPeriodSum;
      }
    }
  }

  Future<int> countAllSum() async {
    int newAllSum = 0;
    for (final int year in _dailyYears) {
      final Map<int, int> yearData = await _getYearData(year);
      for (final MapEntry<int, int> e in yearData.entries) {
        newAllSum += e.value;
      }
    }
    return newAllSum;
  }

  Future<int> countPeriodSum(DateTime newBeginDate, DateTime newEndDate) async {
    int newPeriodSum = 0;
    if ((null == newBeginDate) && (null == newEndDate)) {
      newPeriodSum = allSum;
    } else if ((null == newBeginDate) && (null != newEndDate)) {
      DateInt newEndDateInt = DateInt(newEndDate);
      int endYear = newEndDateInt.year;
      for (final int year in _dailyYears) {
        if (year <= endYear) {
          final Map<int, int> yearData = await _getYearData(year);
          for (final MapEntry<int, int> e in yearData.entries) {
            if (e.key <= newEndDateInt.data) {
              newPeriodSum += e.value;
            }
          }
        } else {
          break;
        }
      }
    } else if ((null != newBeginDate) && (null == newEndDate)) {
      DateInt newBeginDateInt = DateInt(newBeginDate);
      int beginYear = newBeginDateInt.year;
      for (final int year in _dailyYears) {
        if (beginYear <= year) {
          final Map<int, int> yearData = await _getYearData(year);
          for (final MapEntry<int, int> e in yearData.entries) {
            if (newBeginDateInt.data <= e.key) {
              newPeriodSum += e.value;
            }
          }
        }
      }
    } else {
      DateInt newBeginDateInt = DateInt(newBeginDate);
      DateInt newEndDateInt = DateInt(newEndDate);
      int beginYear = newBeginDateInt.year;
      int endYear = newEndDateInt.year;
      for (final int year in _dailyYears) {
        if ((beginYear <= year) && (year <= endYear)) {
          final Map<int, int> yearData = await _getYearData(year);
          for (final MapEntry<int, int> e in yearData.entries) {
            if ((newBeginDateInt.data <= e.key) &&
                (e.key <= newEndDateInt.data)) {
              newPeriodSum += e.value;
            }
          }
        } else if (endYear < year) {
          break;
        }
      }
    }

    return newPeriodSum;
  }

  Future<String> apply() async {
    for (final a in _assignmentDataList) {
      if (name == a.name) {
        return "名字已存在";
      }
    }

    _initSortSequence();

    try {
      ID = await _dbMgr.insert(
        tableAssignment,
        _allValuePairs(),
      );
      print("xxx new id=$ID");
    } catch (err) {
      return err.toString();
    }

    //初始化
//    final year = DateTime.now().year;
//    await getAllAssignment();

    _assignmentDataList.add(this);
  }

  _initSortSequence() {
    sortSequence = _assignmentDataList.length;
  }

  Map<String, dynamic> _allValuePairs() {
    return {
      _columnAssignmentName: name,
      _columnOtherDone: otherDone,
      _columnFirstDate: (null != firstDate) ? DateInt(firstDate).data : null,
      _columnAllSum: allSum,
      _columnStep: step,
      _columnLastUpdateDate:
          (null != lastUpdateDateInt) ? lastUpdateDateInt.data : null,
      _columnContinuousDaysCount: continuousDaysCount,
      _columnBeginDate: (null != beginDate) ? DateInt(beginDate).data : null,
      _columnEndDate: (null != endDate) ? DateInt(endDate).data : null,
      _columnTarget: target,
      _columnPeriodSum: periodSum,
      _columnSortSequence: sortSequence,
    };
  }

  Future<String> remove() async {
    final msg = await _deleteFromDB();
    if ((null != msg) && ("" != msg)) {
      return msg;
    }

    _removeFromList();
  }

  void _removeFromList() {
    _assignmentDataList.remove(this);
  }

  Future<String> _deleteFromDB() async {
    try {
      await _dbMgr.delete(
        tableDaily,
        where: "${_columnID}=?",
        whereArgs: [ID],
      );
      await _dbMgr.delete(
        tableYear,
        where: "${_columnID}=?",
        whereArgs: [ID],
      );

      final res = await _dbMgr.delete(
        tableAssignment,
        where: "${_columnID}=?",
        whereArgs: [ID],
      );
      assert(1 == res);
    } catch (err) {
      return err.toString();
    }
  }

  void assignmentFrom(AssignmentData newData) {
    ID = newData.ID;
    name = newData.name;
    target = newData.target;
    otherDone = newData.otherDone;
    firstDate = newData.firstDate;
    allSum = newData.allSum;
    step = newData.step;
    lastUpdateDateInt = newData.lastUpdateDateInt;
    continuousDaysCount = newData.continuousDaysCount;
    endDate = newData.endDate;
    sortSequence = newData.sortSequence;
    return;
  }

  bool get hasTarget => (null != target);
  String targetString() {
    if (hasTarget) {
      return numString(target);
    } else {
      return " ";
    }
  }

  String periodSumString() {
    return numString(periodSum);
  }

  String allSumString() {
    return numString((otherDone ?? 0) + allSum);
  }

  int _lastTodayDone = 0;
  int get lastTodayDone => _lastTodayDone;

  Future<int> todayDone() async {
//    await Future.delayed(Duration(milliseconds: 200));
    _lastTodayDone = (await _getDailyDoneAsync(DateInt(DateTime.now()))) ?? 0;
    return _lastTodayDone;
//    _lastTodayDonet = numString(todayDone ?? 0);
//    return _lastTodayDone,_lastTodayDonetString;
  }

  _correctContinuousDaysCount() {
    final today = DateTime.now();
    final todayInt = DateInt(today);

    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final yesterdayInt = DateInt(yesterday);

    if ((0 != continuousDaysCount) &&
        !yesterdayInt.isSameDay(lastUpdateDateInt) &&
        !todayInt.isSameDay(lastUpdateDateInt)) {
      continuousDaysCount = 0;
      // 每次读取都会计算，所以这里不用更新到数据库中

    }
  }

  String continuousDaysCountString() {
    return numString(continuousDaysCount);
  }

  bool get hasStartDate => (null != beginDate);
  String startDateString() {
    if (hasStartDate) {
//      final fmt = DateFormat('yyyy年\nM月d日');
//      final fmt = DateFormat('yyyy.M.d');
//      return fmt.format(_int2Dt(expirationDate));
      return "${beginDate.year}.${beginDate.month}.${beginDate.day}";
    } else {
      return " ";
    }
  }

  bool get hasEndDate => (null != endDate);
  String endDateString() {
    if (hasEndDate) {
//      final fmt = DateFormat('yyyy年\nM月d日');
//      final fmt = DateFormat('yyyy.M.d');
//      return fmt.format(_int2Dt(expirationDate));
      return "${endDate.year}.${endDate.month}.${endDate.day}";
    } else {
      return " ";
    }
  }

  String leftDaysCountString() {
    if (hasEndDate) {
      return "${leftDaysCount}";
    } else {
      return " ";
    }
  }

  int get leftDaysCount {
    assert(null != endDate);
    return endDate.difference(DateTime.now()).inDays + 1;
  }

  bool get hasFirstDate => (null != firstDate);
  bool get hasBeginDate => (null != beginDate);

  int get pastDaysCount {
    if (null == firstDate) {
      return 0;
    }
    final today = DateTime.now();
    int daysCount = today.difference(beginDate ?? firstDate).inDays;

    final todayInt = DateInt(today);
    if ((null != lastUpdateDateInt) &&
        (lastUpdateDateInt.isSameDay(todayInt))) {
      daysCount++;
    }

    return daysCount;
  }

  double futureAverageDone() {
    if (hasEndDate && hasTarget) {
      assert(null != endDate);
      assert(null != target);
      if (target <= allSum) {
        return 0;
      } else {
        return ((target - allSum) / leftDaysCount);
      }
    } else {
      return null;
    }
  }

  String futureAverageDoneString() {
    if (hasEndDate && hasTarget) {
      assert(null != endDate);
      assert(null != target);
      final value = futureAverageDone();
      final fixed = (value < 10) ? 2 : 1;
      return "${value.toStringAsFixed(fixed)}";
    } else {
      return " ";
    }
  }

  double pastDoneAverage() {
    final daysCount = pastDaysCount;
    if (0 != daysCount) {
      return periodSum / pastDaysCount;
    } else {
      return 0;
    }
  }

  String pastDoneAverageString() {
    final daysCount = pastDaysCount;
    if (0 != daysCount) {
      final double value = periodSum / daysCount;
      final int fixed = (value < 10) ? 2 : 1;
      return "${value.toStringAsFixed(fixed)}";
    } else {
      return "0";
    }
  }

  double planOnAverage() {
    if (hasTarget && (hasBeginDate || hasFirstDate) && hasEndDate) {
      int days = endDate.difference(beginDate ?? firstDate).inDays;
      if ((0 < days) && (0 < target)) {
        return target / days;
      }
    }
    return null;
  }

  String progressString() {
    if (hasTarget) {
      return "${((periodSum) * 100 / target).toStringAsFixed(0)}%";
    } else {
      return " ";
    }
  }

  _updateStatisticsDataInDB({
    bool continuousDaysCountUpdated,
    bool lastUpdateDateUpdated,
    bool firstDateUpdated,
    bool periodSumUpdated,
  }) async {
    final Map<String, dynamic> valuePairs = {_columnAllSum: allSum};
    if (true == lastUpdateDateUpdated) {
      valuePairs[_columnLastUpdateDate] = lastUpdateDateInt?.data;
    }
    if (true == continuousDaysCountUpdated) {
      valuePairs[_columnContinuousDaysCount] = continuousDaysCount;
    }
    if (true == firstDateUpdated) {
      valuePairs[_columnFirstDate] =
          (null != firstDate) ? DateInt(firstDate).data : null;
    }
    if (true == periodSumUpdated) {
      valuePairs[_columnPeriodSum] = periodSum;
    }
    final res = await _dbMgr.update(tableAssignment, valuePairs,
        where: "${_columnID}=?", whereArgs: [ID]);
    assert(1 == res);
  }

  Future<int> getDailyDoneAsync(DateTime date) async {
    final dateInt = DateInt(date);
    return _getDailyDoneAsync(dateInt);
  }

  Future<int> getDailyDoneByIntAsync(int date) async {
    final dateInt = DateInt.fromInt(date);
    return _getDailyDoneAsync(dateInt);
  }

  Future<int> _getDailyDoneAsync(DateInt dateInt) async {
    assert(null != dateInt);

    final yearData = await _getYearData(dateInt.year);
    if (null != yearData) {
      return yearData[dateInt.data];
    }

    return null;
  }

  bool _hasYear(int year) {
    bool has = false;
    for (final y in _dailyYears) {
      if (y == year) {
        has = true;
        break;
      }
    }
    return has;
  }

  void _setDailyDone(DateInt dateInt, int oldDone, int newDone) async {
    assert(null != dateInt);

    assert(oldDone != newDone);

    Map<int, int> yearsData = await _getYearData(dateInt.year);
    if (null == yearsData) {
      yearsData = await _addNewYear(dateInt.year);
    }
    yearsData[dateInt.data] = newDone;

    if (null != oldDone) {
      _tryUpdateThenInsertDailyData(dateInt, newDone);
    } else {
      _tryInsertThenUpdateDailyData(dateInt, newDone);
    }
  }

  _insertYear2DB(int year) {
    _dbMgr.insert(tableYear, {_columnID: ID, _columnYear: year});
  }

  Future<bool> todayDoneReduceStep() async {
    final today = DateTime.now();
    return reduceDailyDone(today, step, today);
  }

  Future<bool> reduceDailyDone(DateTime date, int num, [DateTime today]) async {
    assert(null != date);
    assert((null != num) && (0 <= num));

    if (0 == num) {
      return false;
    }

    final int oldDone = await getDailyDoneAsync(date);

    if ((null == oldDone) || (0 == oldDone)) {
      return false; // 最小就是0
    }

    bool continuousDaysCountUpdated;
    bool lastUpdateDateUpdated;
    bool firstDateUpdated;
    bool periodSumUpdated;

    final dateInt = DateInt(date);
    int newDone;

    assert(null != oldDone);
    if (num < oldDone) {
      newDone = oldDone - num; // 当天还有剩的，其他状态就不会改变
      allSum -= num;
      if (((null == beginDateInt) || (beginDateInt.data <= dateInt.data)) &&
          ((null == endDateInt) || (dateInt.data <= endDateInt.data))) {
        periodSum -= num;
        periodSumUpdated = true;
      }
    } else {
      allSum -= oldDone;
      if (((null == beginDateInt) || (beginDateInt.data <= dateInt.data)) &&
          ((null == endDateInt) || (dateInt.data <= endDateInt.data))) {
        periodSum -= oldDone;
        periodSumUpdated = true;
      }
      newDone = 0;

      // 重新计算continuousDaysCount
      // 主要看date与当前连续期的关系：1.末尾; 2.中间; 3.起始; 4.之前；
      // 以及当前连续期的位置，继是否影响continuousDaysCount的值；

      today = today ?? DateTime.now();
      DateInt todayInt = DateInt(today);

      // 可能跨日期了 // TODO
      if (!lastUpdateDateInt.isSameDay(todayInt.prevousDay) &&
          !lastUpdateDateInt.isSameDay(todayInt)) {
        continuousDaysCount = 0;
        continuousDaysCountUpdated = true;
      }

      // 当前没有天数计数，就不需要更新状态了
      // 所以，只处理当前正在计数的情况
      if (0 < continuousDaysCount) {
        assert(null != lastUpdateDateInt);
        if (dateInt.isSameDay(todayInt)) {
          // 今天
          continuousDaysCount--;
          continuousDaysCountUpdated = true;
        } else if (dateInt.isSameDay(todayInt.prevousDay)) {
          // 昨天
          final todayDone = await _getDailyDoneAsync(todayInt);
          if ((null == todayDone) || (0 == todayDone)) {
            continuousDaysCount = 0;
          } else {
            continuousDaysCount = 1;
          }
          continuousDaysCountUpdated = true;
        } else {
          // 昨天之前的日期

          final lastUpdateDateDt = lastUpdateDateInt.dt;
          // 当前连续周期的第一天
          final thisPeriodFirstDate = lastUpdateDateDt
              .subtract(Duration(days: continuousDaysCount - 1));
          final thisFirstDateInt = DateInt(thisPeriodFirstDate);

          if (thisFirstDateInt.data <= dateInt.data) {
            continuousDaysCount -=
                date.difference(thisPeriodFirstDate).inDays + 1;
            continuousDaysCountUpdated = true;
            assert(0 <= continuousDaysCount);
          }
        }
      }

      // 更新lastUpdateDateInt
      // 与continuousDaysCount状态无关
      if (dateInt.isSameDay(lastUpdateDateInt)) {
        final DailyData dailyData =
            await _getPrevNonZeroDailyData(lastUpdateDateInt.prevousDay);
        lastUpdateDateInt =
            (null != dailyData) ? DateInt.fromInt(dailyData.date) : null;
        lastUpdateDateUpdated = true;
      }

      // 更新firstDate
      if (isSameDay(firstDate, date)) {
        final dailyData =
            await _getNextNonZeroDailyData(dateInt.nextDay, DateInt(today));
        firstDate =
            (null != dailyData) ? DateInt.fromInt(dailyData.date).dt : null;
        firstDateUpdated = true;
      }
    }

    await _setDailyDone(dateInt, oldDone, newDone);

    _updateStatisticsDataInDB(
      continuousDaysCountUpdated: continuousDaysCountUpdated,
      lastUpdateDateUpdated: lastUpdateDateUpdated,
      firstDateUpdated: firstDateUpdated,
      periodSumUpdated: periodSumUpdated,
    );

    return true;
  }

  Future<DailyData> _getPrevNonZeroDailyData(DateInt startDateInt) async {
    // 日期范围(...,startDateInt]
    assert(null != startDateInt);

    int date;
    int done;
    DailyData dailyData;

    for (final year in _dailyYears.reversed) {
      if (startDateInt.year < year) {
        continue;
      }

      Map<int, int> yearData = await _getYearData(year);
      assert(null != yearData);
      yearData.forEach((int k, int v) {
        if ((k <= startDateInt.data) && (0 != v)) {
          if (null == date) {
            date = k;
            done = v;
          } else if (date < k) {
            date = k;
            done = v;
          }
        }
      });

      if (null != date) {
        dailyData = DailyData(date, done);
        break;
      }
    }

    return dailyData;
  }

  Future<DailyData> _getNextNonZeroDailyData(
      DateInt startDateInt, DateInt endDateInt) async {
    // 日期范围[startDateInt,endDateInt]
    assert(null != startDateInt);
    assert(null != endDateInt);

    if (null == lastUpdateDateInt) {
      // CAUTION: 正在修改状态的时候，lastUpdateDateInt和firstDate可能会互有干扰
      return null;
    }

    int date;
    int done;
//    DateInt dateInt = startDateInt;
    DailyData dailyData;

    for (final year in _dailyYears) {
      Map<int, int> yearData = await _getYearData(year);

      yearData.forEach((int k, int v) {
        assert(null != v);
        if ((startDateInt.data <= k) && (k <= endDateInt.data) && (0 != v)) {
          if (null == date) {
            date = k;
            done = v;
          } else if (k < date) {
            date = k;
            done = v;
          }
        }
      });
      if (null != date) {
        // 年份是有序的，从最小开始，所以一年遍历完，有数据，那就是最小的日期
        dailyData = DailyData(date, done);
        break;
      }
    }
    return dailyData;
  }

  void todayDoneAddStep() async {
    DateTime today = DateTime.now();
    await addDailyDone(today, step, today);
    return;
  }

  void addDailyDone(DateTime date, int num, [DateTime today]) async {
    assert(null != date);
    assert((null != num) && (0 <= num));

    if (0 == num) {
      return;
    }

    assert(0 < num);

    bool lastUpdateDateUpdated;
    bool continuousDaysCountUpdated;
    bool firstDateUpdated;
    bool periodSumUpdated;

    final dateInt = DateInt(date);
    final oldDone = await _getDailyDoneAsync(dateInt);

    if ((null == oldDone) || (0 == oldDone)) {
      // 更新continuousDaysCount
      final todayInt = DateInt(today ?? DateTime.now());

      // 可能跨日期了 // TODO
      if (!lastUpdateDateInt.isSameDay(todayInt.prevousDay) &&
          !lastUpdateDateInt.isSameDay(todayInt)) {
        continuousDaysCount = 0;
        continuousDaysCountUpdated = true;
      }

      if (dateInt.isSameDay(todayInt)) {
        // 今天
        continuousDaysCount++;
        continuousDaysCountUpdated = true;
      } else if (dateInt.isSameDay(todayInt.prevousDay)) {
        // 昨天
        assert(continuousDaysCount <= 1);
        // 昨天，从无数据到有数据，则需要往前数连续天数
        final prevousCount = await _getPrevousContinuousDaysCount(
            dateInt.prevousDay); // 当天的数据还没有设置，从前一天开始数
        continuousDaysCount += (1 + prevousCount);
        continuousDaysCountUpdated = true;
      } else {
        // 昨天之前
        // 如果昨天没有报数，再之前的日期增加了报数，也不影响continuousDaysCount
        // 所以只处理昨天有数据的，即：lastUpdateDateInt是有效值
        final yesterdayDone = await _getDailyDoneAsync(todayInt.prevousDay);
        if ((null != yesterdayDone) && (0 != yesterdayDone)) {
          assert(null != lastUpdateDateInt);
          final prevThisFirstDateInt = DateInt(lastUpdateDateInt.dt
              .subtract(Duration(days: continuousDaysCount))); // 连续期第一天的前一天
          if (dateInt.isSameDay(prevThisFirstDateInt)) {
            // 如果刚好能接上continuousDaysCount的第一天，则需要往前数连续天数
            final prevousCount = await _getPrevousContinuousDaysCount(
                dateInt.prevousDay); // 当天的数据还没有设置，从前一天开始数
            continuousDaysCount += (1 + prevousCount);
            continuousDaysCountUpdated = true;
          }
        }
      }

      // 更新lastUpdateDate
      if ((null == lastUpdateDateInt) ||
          (lastUpdateDateInt.data < dateInt.data)) {
        lastUpdateDateInt = dateInt;
        lastUpdateDateUpdated = true;
      }

      // 更新firstDate
      if ((null == firstDate) || (dateInt.data < DateInt(firstDate).data)) {
        firstDate = date;
        firstDateUpdated = true;
      }
    }

    int newDone = (oldDone ?? 0) + num;
    await _setDailyDone(dateInt, oldDone, newDone);

    allSum += num;
    if (((null == beginDateInt) || (beginDateInt.data <= dateInt.data)) &&
        ((null == endDateInt) || (dateInt.data <= endDateInt.data))) {
      periodSum += num;
      periodSumUpdated = true;
    }

    _updateStatisticsDataInDB(
      continuousDaysCountUpdated: continuousDaysCountUpdated,
      lastUpdateDateUpdated: lastUpdateDateUpdated,
      firstDateUpdated: firstDateUpdated,
      periodSumUpdated: periodSumUpdated,
    );

    return;
  }

  Future<int> _getPrevousContinuousDaysCount(DateInt startDateInt) async {
    assert(null != startDateInt);
    int daysCount = 0;
    DateInt dateInt = startDateInt;

    do {
      final done = await _getDailyDoneAsync(dateInt);
      if ((null == done) || (0 == done)) {
        break;
      }
      daysCount++;
      dateInt = dateInt.prevousDay;
    } while (true);

    return daysCount;
  }

  void _tryInsertThenUpdateDailyData(DateInt dateInt, int done) async {
    try {
      await _dbMgr.insert(tableDaily, {
        "${_columnDate}": dateInt.data,
        "${_columnID}": ID,
        "${_columnDailyDone}": done,
      });
    } catch (err) {
      try {
        await _dbMgr.update(
          tableDaily,
          {"${_columnDailyDone}": done},
          where: "${_columnDate}=? AND ${_columnID}=?",
          whereArgs: [dateInt.data, ID],
        );
      } catch (err) {
        assert(false);
      }
    }
  }

  void _tryUpdateThenInsertDailyData(DateInt dateInt, int done) {
    try {
      _dbMgr.update(
        tableDaily,
        {"${_columnDailyDone}": done},
        where: "${_columnDate}=? AND ${_columnID}=?",
        whereArgs: [dateInt.data, ID],
      );
    } catch (err) {
      assert(false);
      try {
        _dbMgr.insert(tableDaily, {
          "${_columnDate}": dateInt.data,
          "${_columnID}": ID,
          "${_columnDailyDone}": done,
        });
      } catch (err) {
        assert(false);
      }
    }
  }

  static Future<List<int>> getAllAssignmentYears() async {
    List<AssignmentData> assignmentDataList = await getAllAssignment();

    List<int> years = [];
    for (final a in assignmentDataList) {
      years.addAll(a._dailyYears);
    }

    // 去重
    years = years.toSet().toList();
    years.sort();
    return years;
  }

  static Future<List<int>> getAllAssignmentSortedDatesByYear(int year) async {
    List<AssignmentData> assignmentDataList = await getAllAssignment();

    List<int> allDates = [];
    for (final a in assignmentDataList) {
      var yearData = a._dailyDatas[year];
      if (null == yearData) {
        yearData = await a._queryDailyDataByYearFromDB(year);
      }

      yearData.forEach((int k, int v) {
        if (0 != v) {
          allDates.add(k);
        }
      });
    }

    // 去重、排序
    allDates = allDates.toSet().toList();
    allDates.sort();
    return allDates;
  }

  static AssignmentData _getAssignmentByName(final String name) {
    for (final a in _assignmentDataList) {
      if (name == a.name) {
        return a;
      }
    }
    return null;
  }

  static void import(Map<String, Map<int, int>> datas) async {
    Batch batch = _dbMgr.batch();
    List<AssignmentData> newAssignmentList = [];
    List<AssignmentData> oldAssignmentList = [];
    // 区分已存在的功课和新增功课，
    // 新增功课入库以确定ID
    datas.forEach((String name, Map<int, int> dailyDatas) {
      AssignmentData a = _getAssignmentByName(name);
      if (null == a) {
        a = AssignmentData();
        a.name = name;
        newAssignmentList.add(a);
      } else {
        oldAssignmentList.add(a); // 已经存在的，等下处理
      }
    });

    importNew(newAssignmentList, datas, batch);

    importOld(oldAssignmentList, datas, batch);

//    await batch.commit();

//    _assignmentDataList.addAll(newAssignmentList);

    return;
  }

  static Future importNew(List<AssignmentData> newAssignmentList,
      Map<String, Map<int, int>> datas, Batch batch) async {
    // 处理新增功课
    for (final a in newAssignmentList) {
      Map<int, int> dailyDatas = datas[a.name];
      int allDone = 0;
      dailyDatas.values.forEach((int d) {
        allDone += d;
      });
      a.allSum = allDone;
      a.periodSum = allDone;

      final dates = dailyDatas.keys.toList();

      if (dates.isNotEmpty) {
        dates.sort();
        a.firstDate = DateInt.fromInt(dates.first).dt;
        a.lastUpdateDateInt = DateInt.fromInt(dates.last);
      }
      final msg = await a.applyWithBatch(batch);
//        final msg = await a.apply();
      if ((null != msg) && ("" != msg)) {}
    }
    // 提交，以获取ID
    List<dynamic> IDs = await batch.commit();
    for (int i = 0; i < newAssignmentList.length; i++) {
      final a = newAssignmentList[i];
      a.ID = IDs[i];
    }

    // 导入新增功课的每日数据
    for (final a in newAssignmentList) {
      final allYearDatas = datas[a.name];
      await a._newAssignmentImportAllYearDailyDatas(allYearDatas, batch);
    }

    // 更新continuousDaysCount与lastUpdateDate
    final DateTime today = DateTime.now();
    final DateInt todayInt = DateInt(today);
    for (final a in newAssignmentList) {
      Map<String, dynamic> valuePairs = {};

      DailyData lastNonZeroData = await a._getPrevNonZeroDailyData(todayInt);
      bool lastUpdateDateChanged = false;
      if ((null != a.lastUpdateDateInt) && (null == lastNonZeroData)) {
        a.lastUpdateDateInt = null;
        lastUpdateDateChanged = true;
      } else if ((null == a.lastUpdateDateInt) && (null != lastNonZeroData)) {
        a.lastUpdateDateInt = DateInt.fromInt(lastNonZeroData.date);
        lastUpdateDateChanged = true;
      }
      if ((null != a.lastUpdateDateInt) &&
          (null != lastNonZeroData) &&
          (a.lastUpdateDateInt.data != lastNonZeroData.date)) {
        a.lastUpdateDateInt = DateInt.fromInt(lastNonZeroData.date);
        lastUpdateDateChanged = true;
      }
      if (lastUpdateDateChanged) {
        valuePairs[_columnLastUpdateDate] =
            (null == a.lastUpdateDateInt) ? null : a.lastUpdateDateInt.data;
      }

      int newContinuousDaysCount =
          await a._getPrevousContinuousDaysCount(todayInt.prevousDay);
      int todayDone = await a._getDailyDoneAsync(todayInt);
      if ((null != todayDone) && (0 != todayDone)) {
        newContinuousDaysCount++;
      }

      if (a.continuousDaysCount != newContinuousDaysCount) {
        a.continuousDaysCount = newContinuousDaysCount;
        valuePairs[_columnContinuousDaysCount] = a.continuousDaysCount;
      }

      if (valuePairs.isNotEmpty) {
        // TODO batch
        _dbMgr.update(
          tableAssignment,
          valuePairs,
          where: "${_columnID}=? ",
          whereArgs: [a.ID],
        );
      }
    }
  }

  static Future importOld(List<AssignmentData> oldAssignmentList,
      Map<String, Map<int, int>> datas, Batch batch) async {
    // 导入已存在功课的每日数据
    for (final a in oldAssignmentList) {
      await a._oldAssignmentMergeAllYearDailyDatas(datas[a.name], batch);
    }

    // 已存在功课更新信息
    final DateTime today = DateTime.now();
    final DateInt todayInt = DateInt(today);
    for (final a in oldAssignmentList) {
      Map<String, dynamic> valuePairs = {};

      // 更新allSum
      final int newAllSum = await a.countAllSum();
      if (a.allSum != newAllSum) {
        a.allSum = newAllSum;
        valuePairs[_columnAllSum] = newAllSum;
      }

      // 更新periodSum
      final int newPeriodSum = await a.countPeriodSum(a.beginDate, a.endDate);
      if (a.periodSum != newPeriodSum) {
        a.periodSum = newPeriodSum;
        valuePairs[_columnPeriodSum] = newPeriodSum;
      }

      // 更新lastUpdateDate
      DailyData lastNonZeroData = await a._getPrevNonZeroDailyData(todayInt);
      bool lastUpdateDateChanged = false;
      if ((null != a.lastUpdateDateInt) && (null == lastNonZeroData)) {
        a.lastUpdateDateInt = null;
        lastUpdateDateChanged = true;
      } else if ((null == a.lastUpdateDateInt) && (null != lastNonZeroData)) {
        a.lastUpdateDateInt = DateInt.fromInt(lastNonZeroData.date);
        lastUpdateDateChanged = true;
      }
      if ((null != a.lastUpdateDateInt) &&
          (null != lastNonZeroData) &&
          (a.lastUpdateDateInt.data != lastNonZeroData.date)) {
        a.lastUpdateDateInt = DateInt.fromInt(lastNonZeroData.date);
        lastUpdateDateChanged = true;
      }
      if (lastUpdateDateChanged) {
        valuePairs[_columnLastUpdateDate] =
            (null == a.lastUpdateDateInt) ? null : a.lastUpdateDateInt.data;
      }

      // 更新continuousDaysCount
      int newContinuousDaysCount =
          await a._getPrevousContinuousDaysCount(todayInt.prevousDay);
      int todayDone = await a._getDailyDoneAsync(todayInt);
      if ((null != todayDone) && (0 != todayDone)) {
        newContinuousDaysCount++;
      }
      if (a.continuousDaysCount != newContinuousDaysCount) {
        a.continuousDaysCount = newContinuousDaysCount;
        valuePairs[_columnContinuousDaysCount] = a.continuousDaysCount;
      }

      if (valuePairs.isNotEmpty) {
        _dbMgr.update(
          tableAssignment,
          valuePairs,
          where: "${_columnID}=? ",
          whereArgs: [a.ID],
        );
      }
    }
  }

  Future<String> applyWithBatch(Batch batch) async {
    assert(null != batch);

    _initSortSequence();

    try {
      await batch.insert(
        tableAssignment,
        _allValuePairs(),
      );
//      print("xxx new id=$ID");
    } catch (err) {
      return err.toString();
    }

    _assignmentDataList.add(this);
    return null;
  }

  void _newAssignmentImportAllYearDailyDatas(
      Map<int, int> allYearDatas, Batch batch) async {
    for (final e in allYearDatas.entries) {
      final date = e.key;
      final done = e.value;
      assert((null != done) && (0 != done));
      final dateInt = DateInt.fromInt(date);
      final oldDone = await getDailyDoneByIntAsync(e.key);
      assert(null == oldDone);
      await _setDailyDone(dateInt, null, done);
    }
  }

  void _oldAssignmentMergeAllYearDailyDatas(
      Map<int, int> allYearDatas, Batch batch) async {
    for (final e in allYearDatas.entries) {
      final date = e.key;
      final done = e.value;
      final dateInt = DateInt.fromInt(date);
      final oldDone = await getDailyDoneByIntAsync(e.key);
      if (oldDone != done) {
        await _setDailyDone(dateInt, oldDone, done);
      }
    }

//    await batch.commit();
  }

  static updateAllAssignmentSortSequence() {
    for (int i = 0; i < _assignmentDataList.length; i++) {
      final a = _assignmentDataList[i];
      if (a.sortSequence != i) {
        a.sortSequence = i;
        try {
          _dbMgr.update(
            tableAssignment,
            {_columnSortSequence: a.sortSequence},
            where: "${_columnID}=?",
            whereArgs: [a.ID],
          );
        } catch (err) {
          return err.toString();
        }
      }
    }
  }
}
