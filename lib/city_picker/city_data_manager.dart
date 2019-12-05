import 'city_data.dart';

class CityItem {
  final String fullName;
  final Map<String, dynamic> city;
  CityItem(this.fullName, this.city);
}

class CityDataMgr {
  static List<CityItem> findCities(String pattern) {
    assert(null != pattern);
    pattern = pattern.trim();
    if ("" == pattern) {
      return findL1Cities(pattern);
    } else {
      return findMatchedCities(pattern);
    }
  }

  static List<CityItem> findL1Cities(String pattern) {
    List<CityItem> items = [];
    for (final L1 in cityData["zone"]) {
      final String L1Name = L1["name"];
      if (L1Name.contains(pattern)) {
        items.add(CityItem(L1Name, L1));
      }
    }
//    items.sort((CityItem a, CityItem b) {
//      return a.fullName.compareTo(b.fullName);
//    });
    return items;
  }

  static List<CityItem> findMatchedCities(String pattern) {
    final List<CityItem> fullMatchedItems = findAllPatternMatched(pattern);
    final List<CityItem> partMatchedItems = findSomePatternMatched(pattern);

    _merge(fullMatchedItems, partMatchedItems);

    return fullMatchedItems;
  }

  static List<CityItem> findAllPatternMatched(String pattern) {
    pattern = pattern.trim();

    final List<CityItem> items = [];
    if (pattern.isEmpty) {
      return items;
    }

    // 每一部分都被包含，并且最后一级至少包含一个

    for (final Map<String, dynamic> L1 in cityData["zone"]) {
      final String L1Name = L1["name"];
      if (L1Name == pattern) {
        final item = CityItem("$L1Name", L1);
//        items.add(item);
        items.addAll(getChildren(item));
      }

      for (final L2 in L1["zone"]) {
        final String L2Name = L2["name"];
        final String L2FullName = "$L1Name $L2Name";
        if ((L2Name == pattern) || (L2FullName == pattern)) {
          final item = CityItem(L2FullName, L2);
//          items.add(item);
          items.addAll(getChildren(item));
        }

        for (final L3 in L2["zone"]) {
          final String L3Name = L3["name"];
          final String L3FullName = "$L2FullName $L3Name";
          if ((L3Name == pattern) || (L3FullName == pattern)) {
            items.add(CityItem(L3FullName, L3));
          }
        }
      }
    }

    return items;
  }

  static List<CityItem> findSomePatternMatched(String pattern) {
    List<String> parts = [];
    pattern.split(" ").forEach((e) {
      if ("" != e) {
        parts.add(e);
      }
    });

    final List<CityItem> items = [];
    if (parts.isEmpty) {
      return items;
    }

    // 每一部分都被包含，并且最后一级至少包含一个

    for (final L1 in cityData["zone"]) {
      int L1PartFlagsCount = 0;
      final List<bool> L1PartFlags = List.generate(parts.length, (int index) {
        return false;
      });

      final String L1Name = L1["name"];
      for (int i = 0; i < parts.length; i++) {
        final p = parts[i];
        if (L1Name.contains(p)) {
          if (true != L1PartFlags[i]) {
            L1PartFlags[i] = true;
            L1PartFlagsCount++;
          }
        }
      }
      if (L1PartFlags.length == L1PartFlagsCount) {
        items.add(CityItem("$L1Name", L1));
      }

      for (final L2 in L1["zone"]) {
        final List<bool> L2PartFlags = L1PartFlags.sublist(0);
        int L2PartFlagsCount = L1PartFlagsCount;
        final String L2Name = L2["name"];
        final String L2FullName = "$L1Name $L2Name";
        for (int i = 0; i < parts.length; i++) {
          final p = parts[i];
          if (L2Name.contains(p)) {
            if (true != L2PartFlags[i]) {
              L2PartFlags[i] = true;
              L2PartFlagsCount++;
            }
            if (L2PartFlags.length == L2PartFlagsCount) {
              items.add(CityItem("$L2FullName", L2));
            }
          }
        }

        for (final L3 in L2["zone"]) {
          final List<bool> L3PartFlags = L2PartFlags.sublist(0);
          int L3PartFlagsCount = L2PartFlagsCount;
          final String L3Name = L3["name"];
          final String L3FullName = "$L2FullName $L3Name";

          for (int i = 0; i < parts.length; i++) {
            final p = parts[i];
            if (L3Name.contains(p)) {
              if (true != L3PartFlags[i]) {
                L3PartFlags[i] = true;
                L3PartFlagsCount++;
              }
              if (L3PartFlags.length == L3PartFlagsCount) {
                items.add(CityItem("$L3FullName", L3));
              }
            }
          }
        }
      }
    }
    return items;
  }

  static List<CityItem> findAllMatchedCitiesOK(String pattern) {
    final List<String> parts = pattern.split(" ");
    int partIndex = 0;
//    pattern = pattern.trim();
    final List<CityItem> items = [];
    for (final L1 in cityData["zone"]) {
      final String L1Name = L1["name"];

      if (L1Name.contains(pattern)) {
        items.add(CityItem("$L1Name", L1));
      }
      for (final L2 in L1["zone"]) {
        final String L2Name = L2["name"];
        final String L2FullName = "$L1Name $L2Name";
        if (L2FullName.contains(pattern)) {
          items.add(CityItem(L2FullName, L2));
        }
        for (final L3 in L2["zone"]) {
          final String L3Name = L3["name"];
          final String L3FullName = "$L2FullName $L3Name";
          if (L3FullName.contains(pattern)) {
            items.add(CityItem(L3FullName, L3));
          }
        }
      }
    }
    return items;
  }

  static List<CityItem> getChildren(CityItem item) {
    List<CityItem> children = [];
    if (item.city["id"].length < 6) {
      for (final Map<String, dynamic> child in item.city["zone"]) {
        final String childName = child["name"];
        children.add(CityItem("${item.fullName} $childName", child));
      }
    } else {
      assert(false);
      children.add(item);
    }
    return children;
  }

  static void _merge(List<CityItem> listA, List<CityItem> listB) {
//    final List<CityItem> listC = [];
    for (final b in listB) {
      bool find;
      for (final a in listA) {
        if (b.city["id"] == a.city["id"]) {
          find = true;
          break;
        }
      }
      if (true != find) {
        listA.add(b);
      }
    }

//    listA.addAll(listC);
  }
}
