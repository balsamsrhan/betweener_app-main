import 'dart:convert';
import 'package:betweeener_app/core/util/constants.dart';
import 'package:betweeener_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SearchController2 {
  static Future<List<UserClass>> searchUsers(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) throw Exception('User not found');

    final user = userFromJson(userJson);
    final response = await http.post(
      Uri.parse('$baseUrl/search'),
      headers: {'Authorization': 'Bearer ${user.token}'},
      body: {'name': name},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['users'] as List)
          .map((u) => UserClass.fromJson(u))
          .toList();
    } else {
      throw Exception('Failed to search users');
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) throw Exception('User not found');

    final user = userFromJson(userJson);
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId'),
      headers: {'Authorization': 'Bearer ${user.token}'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user profile');
    }
  }
}