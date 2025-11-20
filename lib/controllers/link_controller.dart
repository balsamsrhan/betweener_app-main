import 'dart:convert';
import 'package:betweeener_app/core/util/constants.dart';
import 'package:betweeener_app/models/link_response_model.dart';
import 'package:betweeener_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<User?> _getCurrentUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('user')) {
    return userFromJson(prefs.getString('user')!);
  }
  return null;
}

Future<List<LinkElement>> getUserLinks() async {
  final user = await _getCurrentUser();
  if (user == null) throw Exception('User not found');

  final response = await http.get(
    Uri.parse(allLinksurl),
    headers: {'Authorization': 'Bearer ${user.token}'},
  );

  Map<String, dynamic> linksMap = jsonDecode(response.body);
  if (response.statusCode == 200) {
    return linksMap["links"]
        .map((link) => LinkElement.fromJson(link))
        .toList()
        .cast<LinkElement>();
  }
  throw Exception("Failed to Get Links");
}

Future<bool> addUserLink(Map<String, dynamic> linkdata) async {
  final user = await _getCurrentUser();
  if (user == null) return false;

  try {
    final Map<String, dynamic> body = {
      'title': linkdata['title'],
      'link': linkdata['link'],
      'username': linkdata['username'] ?? '',
      'isActive': linkdata['isActive'] ?? '1',
    };

    http.Response response = await http.post(
      Uri.parse(allLinksurl),
      headers: {'Authorization': 'Bearer ${user.token}'},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['message'] ?? 'Failed to add link';
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future<bool> updateUserLink(int linkId, Map<String, dynamic> linkdata) async {
  final user = await _getCurrentUser();
  if (user == null) return false;

  try {
    final Map<String, dynamic> body = {
      'title': linkdata['title'],
      'link': linkdata['link'],
      'username': linkdata['username'] ?? '',
      'isActive': linkdata['isActive'] ?? '1',
    };

    http.Response response = await http.put(
      Uri.parse('$allLinksurl/$linkId'),
      headers: {'Authorization': 'Bearer ${user.token}'},
      body: body,
    );

    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<bool> deleteUserLink(int linkId) async {
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('user');
  if (userJson == null) return false;

  final user = userFromJson(userJson);
  final token = user.token;
  if (token == null || token.isEmpty) return false;

  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/links/$linkId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['message'] != null && responseData['message'].contains('deleted')) {
        return true;
      }
    } else if (response.statusCode == 204) {
      return true;
    }
    return false;
  } catch (e) {
    return false;
  }
}