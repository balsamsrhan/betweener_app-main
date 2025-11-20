import 'package:flutter/material.dart';
import 'package:betweeener_app/models/link_response_model.dart';
import 'package:betweeener_app/controllers/link_controller.dart';

class LinksProvider with ChangeNotifier {
  List<LinkElement> _userLinks = [];
  bool _isLoading = false;
  String? _error;

  List<LinkElement> get userLinks => _userLinks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserLinks() async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      _userLinks = await getUserLinks();
    } catch (e) {
      _error = e.toString();
      print('Error loading links: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> addLink(Map<String, dynamic> linkData) async {
    _isLoading = true;
    _safeNotifyListeners();

    try {
      final success = await addUserLink(linkData);
      if (success) {
        await loadUserLinks();
      }
    } catch (e) {
      _error = e.toString();
      print('Error adding link: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> updateLink(int linkId, Map<String, dynamic> linkData) async {
    _isLoading = true;
    _safeNotifyListeners();

    try {
      final success = await updateUserLink(linkId, linkData);
      if (success) {
        await loadUserLinks();
      }
    } catch (e) {
      _error = e.toString();
      print('Error updating link: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> deleteLink(int linkId) async {
    _isLoading = true;
    _safeNotifyListeners();

    try {
      final success = await deleteUserLink(linkId);
      if (success) {
        _userLinks.removeWhere((link) => link.id == linkId);
      }
    } catch (e) {
      _error = e.toString();
      print('Error deleting link: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  void clearError() {
    _error = null;
    _safeNotifyListeners();
  }

  // دالة آمنة لاستدعاء notifyListeners
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