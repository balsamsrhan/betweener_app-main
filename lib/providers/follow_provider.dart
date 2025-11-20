import 'package:flutter/material.dart';
import 'package:betweeener_app/models/follow_model.dart';
import 'package:betweeener_app/controllers/follow_controller.dart';

class FollowProvider with ChangeNotifier {
  List<Follow> _followers = [];
  List<Follow> _following = [];
  bool _isLoading = false;
  String? _error;

  List<Follow> get followers => _followers;
  List<Follow> get following => _following;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFollowData() async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      final data = await FollowController.getFollowData();
      _followers = data.followers;
      _following = data.following;
    } catch (e) {
      _error = e.toString();
      print('Error loading follow data: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> followUser(int followeeId) async {
    try {
      final success = await FollowController.followUser(followeeId);
      if (success) {
        await loadFollowData();
      }
    } catch (e) {
      _error = e.toString();
      print('Error following user: $e');
      _safeNotifyListeners();
    }
  }

  Future<void> unfollowUser(int followeeId) async {
    try {
      final success = await FollowController.unfollowUser(followeeId);
      if (success) {
        await loadFollowData();
      }
    } catch (e) {
      _error = e.toString();
      print('Error unfollowing user: $e');
      _safeNotifyListeners();
    }
  }

  void clearError() {
    _error = null;
    _safeNotifyListeners();
  }

  // نفس الدالة الآمنة
  void _safeNotifyListeners() {
    if (!_isDisposed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          notifyListeners();
        }
      });
    }
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}