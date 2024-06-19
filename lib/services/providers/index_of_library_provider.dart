import 'package:flutter/material.dart';

class IndexOfLibraryProvider extends ChangeNotifier {
  int _indexSelected = 0;

  int get indexSelected => _indexSelected;

  void changeIndex(int index) {
    if (1 >= index && index >= 0) {
      _indexSelected = index;
      notifyListeners();
    }
  }
}
