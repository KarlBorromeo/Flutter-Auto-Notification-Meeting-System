import 'package:flutter/material.dart';

class CalendarState with ChangeNotifier {
  DateTime _passedDate = DateTime.now();

   DateTime get passedDate => _passedDate;

  void changeDate(DateTime newDate) {
    _passedDate = newDate;
    notifyListeners();
  }
}
