import 'package:flutter/material.dart';

class DataModel extends ChangeNotifier {
  String _username = "User"; // Default username
  String _imageUrl = ""; // Default image URL

  String get username => _username;
  String get imageUrl => _imageUrl;

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setImageUrl(String imageUrl) {
    _imageUrl = imageUrl;
    notifyListeners();
  }
}
