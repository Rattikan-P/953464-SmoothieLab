import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  List<int>? _pendingFruits;
  List<int>? _pendingExtras;
  List<int>? _pendingVeggies;
  List<int>? _pendingHerbs;
  String? _pendingMenuName; //   ชื่อเมนูที่เลือกมา (null = custom)
  String? _pendingMenuEmoji; //   emoji ของเมนู

  List<int>? get pendingFruits => _pendingFruits;
  List<int>? get pendingExtras => _pendingExtras;
  List<int>? get pendingVeggies => _pendingVeggies;
  List<int>? get pendingHerbs => _pendingHerbs;
  String? get pendingMenuName => _pendingMenuName;
  String? get pendingMenuEmoji => _pendingMenuEmoji;

  int? _editingCartIndex;
  int? get editingCartIndex => _editingCartIndex;

  void goToTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void goToLabWithPreset(
    List<int> fruitIndexes, {
    List<int> extrasIndexes = const [],
    List<int> veggieIndexes = const [],
    List<int> herbsIndexes = const [],
    String? menuName, //   ถ้ามาจากเมนู ส่งชื่อมาด้วย
    String? menuEmoji,
    int? editIndex,
  }) {
    _pendingFruits = fruitIndexes;
    _pendingExtras = extrasIndexes;
    _pendingVeggies = veggieIndexes;
    _pendingHerbs = herbsIndexes;
    _pendingMenuName = menuName;
    _pendingMenuEmoji = menuEmoji;
    _editingCartIndex = editIndex;
    _currentIndex = 1;
    notifyListeners();
  }

  void clearPendingPreset() {
    _pendingFruits = null;
    _pendingExtras = null;
    _pendingVeggies = null;
    _pendingHerbs = null;
    _pendingMenuName = null;
    _pendingMenuEmoji = null;
  }

  void clearEditingIndex() {
    _editingCartIndex = null;
    notifyListeners();
  }
}
