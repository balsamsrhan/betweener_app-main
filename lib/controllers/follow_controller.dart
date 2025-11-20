import 'dart:convert';
import 'package:betweeener_app/core/util/constants.dart';
import 'package:betweeener_app/models/follow_model.dart';
import 'package:betweeener_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FollowController {
  static Future<FollowResponse> getFollowData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) throw Exception('User not found');

    final user = userFromJson(userJson);
    final response = await http.get(
      Uri.parse('$baseUrl/follow'),
      headers: {'Authorization': 'Bearer ${user.token}'},
    );

    if (response.statusCode == 200) {
      return FollowResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load follow data');
    }
  }

  static Future<bool> followUser(int followeeId) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return false;

    final user = userFromJson(userJson);
    final response = await http.post(
      Uri.parse('$baseUrl/follow'),
      headers: {'Authorization': 'Bearer ${user.token}'},
      body: {'followee_id': followeeId.toString()},
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> unfollowUser(int followeeId) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return false;

    final user = userFromJson(userJson);
    final response = await http.delete(
      Uri.parse('$baseUrl/follow/$followeeId'),
      headers: {'Authorization': 'Bearer ${user.token}'},
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }
}