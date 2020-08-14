import 'city_data.dart';

class CityLevel {
//  final int id;
  final int level;
  final int cityCode;
  final String name;
  final String fullName;
  final Map<String, CityLevel> subCityMap;
  const CityLevel(this.level, this.cityCode,
      [this.name, this.fullName, this.subCityMap]);
}

//class CityItem {
//  final String fullName;
//  final Map<String, dynamic> city;
//  CityItem(this.fullName, this.city);
//}

class CityDataMgr {
  static Map<String, CityLevel> _cityMap;

  static _init() {
    if (null != _cityMap) {
      return;
    }

    _cityMap = {};

    CityLevel L1City = CityLevel(1, 1, "");
    CityLevel L2City = CityLevel(2, 2, "");

    cityInfoData.forEach((element) {
      if (L1City.fullName != element.province) {
//        L1City = _cityMap[element.province];
//        if (null == L1City) {
//          L1City = CityLevel(1, element.province, {});
//          _cityMap[element.province] = L1City;
//        }
        L1City = _cityMap.putIfAbsent(element.province, () {
          return CityLevel(1, element.cityCode ~/ 10000, element.province,
              element.province, {});
        });
      }

      if (L2City.fullName != element.leader) {
        L2City = L1City.subCityMap.putIfAbsent(element.leader, () {
          return CityLevel(2, element.cityCode ~/ 100, element.leader,
              "${element.province} ${element.leader}", {});
        });

//        L2City = L1City.subCityMap[element.leader];
//        if (null == L2City) {
//          L2City = CityLevel(2, element.leader, {});
//          L1City.subCityMap[element.leader] = L2City;
//        }
      }

      L2City.subCityMap[element.city] = CityLevel(
          3,
          element.cityCode,
          element.city,
          "${element.province} ${element.leader} ${element.city}");
    });

    return;
  }

  static List<CityLevel> findCities(String pattern) {
    assert(null != pattern);

    _init();

    pattern = pattern.trim();
    if ("" == pattern) {
      return findL1Cities(pattern);
    }
    return findMatchedCities(pattern);
  }

  static List<CityLevel> findL1Cities(String pattern) {
    List<CityLevel> items = [];
    for (final CityLevel L1 in _cityMap.values) {
//      final String L1Name = L1["name"];
      if (L1.name.contains(pattern)) {
        items.add(L1);
      }
    }
//    items.sort((CityItem a, CityItem b) {
//      return a.fullName.compareTo(b.fullName);
//    });
    return items;
  }

  static List<CityLevel> findMatchedCities(String pattern) {
    final List<CityLevel> fullMatchedItems = findAllPatternMatched(pattern);
    final List<CityLevel> partMatchedItems = findSomePatternMatched(pattern);

    List<CityLevel> all = _merge(fullMatchedItems, partMatchedItems);

    return all;
  }

  static List<CityLevel> findAllPatternMatched(String pattern) {
    pattern = pattern.trim();

    final List<CityLevel> items = [];
    if (pattern.isEmpty) {
      return items;
    }

    // 每一部分都被包含，并且最后一级至少包含一个

    for (final CityLevel L1 in _cityMap.values) {
      if (L1.fullName == pattern) {
        items.addAll(getChildren(L1));
      }

      for (final CityLevel L2 in L1.subCityMap.values) {
        if ((L2.name == pattern) || (L2.fullName == pattern)) {
          items.addAll(getChildren(L2));
        }

        for (final CityLevel L3 in L2.subCityMap.values) {
          if ((L3.name == pattern) || (L3.fullName == pattern)) {
            items.add(L3);
          }
        }
      }
    }

    return items;
  }

  static List<CityLevel> findSomePatternMatched(String pattern) {
    List<String> parts = [];
    pattern.split(" ").forEach((e) {
      if ("" != e) {
        parts.add(e);
      }
    });

    final List<CityLevel> items = [];
    if (parts.isEmpty) {
      return items;
    }

    // 每一部分都被包含，并且最后一级至少包含一个

    for (final CityLevel L1 in _cityMap.values) {
      int L1PartFlagsCount = 0;
      final List<bool> L1PartFlags = List.generate(parts.length, (int index) {
        return false;
      });

//      final String L1Name = L1["name"];
      for (int i = 0; i < parts.length; i++) {
        final p = parts[i];
        if (L1.name.contains(p)) {
          if (true != L1PartFlags[i]) {
            L1PartFlags[i] = true;
            L1PartFlagsCount++;
          }
        }
      }
      if (L1PartFlags.length == L1PartFlagsCount) {
        items.add(L1);
      }

      for (final CityLevel L2 in L1.subCityMap.values) {
        final List<bool> L2PartFlags = L1PartFlags.sublist(0);
        int L2PartFlagsCount = L1PartFlagsCount;
        for (int i = 0; i < parts.length; i++) {
          final p = parts[i];
          if (L2.name.contains(p)) {
            if (true != L2PartFlags[i]) {
              L2PartFlags[i] = true;
              L2PartFlagsCount++;
            }
            if (L2PartFlags.length == L2PartFlagsCount) {
              items.add(L2);
            }
          }
        }

        for (final CityLevel L3 in L2.subCityMap.values) {
          final List<bool> L3PartFlags = L2PartFlags.sublist(0);
          int L3PartFlagsCount = L2PartFlagsCount;
//          final String L3Name = L3["name"];
//          final String L3FullName = "$L2FullName $L3Name";

          for (int i = 0; i < parts.length; i++) {
            final p = parts[i];
            if (L3.name.contains(p)) {
              if (true != L3PartFlags[i]) {
                L3PartFlags[i] = true;
                L3PartFlagsCount++;
              }
              if (L3PartFlags.length == L3PartFlagsCount) {
                items.add(L3);
              }
            }
          }
        }
      }
    }

    return items;
  }

//  static List<CityItem> findAllMatchedCitiesOK2(String pattern) {
//    final List<CityItem> items = [];
//    for (final L1City in _cityInfoMap.values.toList()) {
//      if (L1City.name.contains(pattern)) {
//        items.add(CityItem("${L1City.name}", L1City));
//      }
//
//      for (final L2 in L1["zone"]) {
//        final String L2Name = L2["name"];
//        final String L2FullName = "$L1Name $L2Name";
//        if (L2FullName.contains(pattern)) {
//          items.add(CityItem(L2FullName, L2));
//        }
//        for (final L3 in L2["zone"]) {
//          final String L3Name = L3["name"];
//          final String L3FullName = "$L2FullName $L3Name";
//          if (L3FullName.contains(pattern)) {
//            items.add(CityItem(L3FullName, L3));
//          }
//        }
//      }
//    }
//    return items;
//  }

  static List<CityLevel> findAllMatchedCitiesOK(String pattern) {
    final List<String> parts = pattern.split(" ");
    int partIndex = 0;
//    pattern = pattern.trim();
    final List<CityLevel> items = [];
    for (final CityLevel L1 in _cityMap.values) {
//      final String L1Name = L1["name"];

      if (L1.name.contains(pattern)) {
        items.add(L1);
      }
      for (final CityLevel L2 in L1.subCityMap.values) {
//        final String L2Name = L2["name"];
//        final String L2FullName = "$L1Name $L2Name";
        if (L2.fullName.contains(pattern)) {
          items.add(L2);
        }
        for (final CityLevel L3 in L2.subCityMap.values) {
//          final String L3Name = L3["name"];
//          final String L3FullName = "$L2FullName $L3Name";
          if (L3.fullName.contains(pattern)) {
            items.add(L3);
          }
        }
      }
    }
    return items;
  }

  static List<CityLevel> getChildren(CityLevel item) {
    _init();

    List<CityLevel> children = [];
    if (item.cityCode < 100000000) {
      assert(null != item.subCityMap);
      children = item.subCityMap.values.toList();
    } else {
      assert(false);
      children.add(item);
    }
    return children;
  }

  static List<CityLevel> _merge(List<CityLevel> listA, List<CityLevel> listB) {
    Map<int, CityLevel> all = Map<int, CityLevel>.fromIterables(
        listA.map((e) => e.cityCode).toList(), listA);
    Map<int, CityLevel> b = Map<int, CityLevel>.fromIterables(
        listB.map((e) => e.cityCode).toList(), listB);
    all.addAll(b);

    return all.values.toList();
  }
}
