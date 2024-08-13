import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  String _role = '';

  String getRole() => _role;

  void setRole(String role) {
    _role = role;
    notifyListeners();
  }

  void clearRole() {
    _role = '';
    notifyListeners();
  }
}
