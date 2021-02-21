import 'package:flutter/material.dart';

class Preferences extends ChangeNotifier{
  bool _sound;

  Preferences() : _sound = true;

  bool get sound => _sound;

  set sound(bool value) {
    _sound = value;
    notifyListeners();
  }
}
