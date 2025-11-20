import 'package:flutter/material.dart';
import 'package:betweeener_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  Future<void> loadUserFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('user')) {
        _currentUser = userFromJson(prefs.getString('user')!);
      }
    } catch (e) {
      print('Error loading user from storage: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setUser(User user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', userToJson(user));
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notifyListeners();
  }

  void updateUser(UserClass updatedUser) {
    if (_currentUser != null) {
      _currentUser = User(user: updatedUser, token: _currentUser!.token);
      notifyListeners();
      _saveUserToStorage();
    }
  }

  Future<void> _saveUserToStorage() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', userToJson(_currentUser!));
    }
  }
}