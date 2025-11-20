import 'package:betweeener_app/models/user.dart';
import 'package:betweeener_app/views_features/auth/login_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<User> getCurrentUser(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (prefs.containsKey('user')) {
    return userFromJson(prefs.getString('user')!);
  } else {
    Navigator.pushReplacementNamed(context, LoginView.id);
    return Future.error("User not found");
  }
}