import 'dart:collection';

import 'package:circle_sector/pie.dart';
import 'package:flutter/material.dart';

class DataModel extends ChangeNotifier {
  final List<PieEntry> _entries;

  DataModel(this._entries);

  UnmodifiableListView<PieEntry> get entries => UnmodifiableListView(_entries);

  void addBlank() {
    _entries.add(const PieEntry('', 0));

    notifyListeners();
  }

  void setEntry(int index, PieEntry entry) {
    _entries[index] = entry;

    notifyListeners();
  }

  void deleteEntry(int index) {
    _entries.removeAt(index);

    notifyListeners();
  }

  double getValueByIndex(int index) {
    return _entries[index].value ?? 0;
  }

  String getTitleByIndex(int index) {
    return _entries[index].title ?? '';
  }
}
