import 'dart:convert';

import 'common_data_type.dart';
import 'file_storage.dart';

_GlobalData _inst = _GlobalData();
_GlobalData get globalData => _inst;

class _GlobalData {
  _GlobalData() {
    loadTaskData();
  }

  Function() onLoadDataFinishedFn;

  ////////////// 任务视图 //////////////
  Map<String, TaskEntry> dateTaskDataMap = {};

  ////////////// 文件存储 //////////////
  RawFile cfgFile;

  loadTaskData() async {
    if (null == cfgFile) {
      try {
        cfgFile = RawFile(fileName: "todo.json");
      } catch (e) {
        assert(false);
      }
    }
    String jsonStr = await cfgFile.getString();

    if (null == jsonStr) {
      return null;
    }

    Map m = json.decode(jsonStr);

    m.forEach((k, v) {
      var te = TaskEntry.fromJson(v);
      dateTaskDataMap[k] = te;
    });

    dateTaskDataMap.forEach((k, dateRoot) {
      dateRoot.initStatus();
    });

    if (null != onLoadDataFinishedFn) {
      onLoadDataFinishedFn();
    }
  }

  saveTaskData() async {
    var jsonStr = await json.encode(dateTaskDataMap);
    cfgFile.setString(jsonStr); // 文件会先被清空，再写入数据
  }

  saveTaskDataAndRefreshView() {
    saveTaskData();
  }
}
