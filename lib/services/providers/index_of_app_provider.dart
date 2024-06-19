import 'package:flutter/material.dart';

class IndexOfAppProvider extends ChangeNotifier {
  int _indexSelected = 0;

  int get indexSelected => _indexSelected;

  void changeIndex (int index) {
    _indexSelected = index;
    notifyListeners();
  }
}