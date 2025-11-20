import 'dart:convert';
import 'package:betweeener_app/core/util/constants.dart';
import 'package:betweeener_app/models/user.dart';
import 'package:http/http.dart' as http;

Future<User> login(Map<String, dynamic> body) async {
  http.Response response = await http.post(Uri.parse(loginURL), body: body);

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    final errorData = jsonDecode(response.body);
    final errorMessage = errorData['message'] ?? 'Failed to login';
    return Future.error(errorMessage);
  }
}

Future<User> register(Map<String, dynamic> body) async {
  http.Response response = await http.post(Uri.parse('$baseUrl/register'), body: body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    final errorData = jsonDecode(response.body);
    final errorMessage = errorData['message'] ?? 'Failed to register';
    return Future.error(errorMessage);
  }
}