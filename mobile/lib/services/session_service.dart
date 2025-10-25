import 'package:flutter/foundation.dart';

class SessionService extends ChangeNotifier {
  String? _customerName;
  int? _tableNumber;

  String? get customerName => _customerName;
  int? get tableNumber => _tableNumber;

  void setCustomerName(String name) {
    _customerName = name;
    notifyListeners();
  }

  void setTableNumber(int? number) {
    _tableNumber = number;
    notifyListeners();
  }

  void clear() {
    _customerName = null;
    _tableNumber = null;
    notifyListeners();
  }
}

final SessionService sessionService = SessionService();
