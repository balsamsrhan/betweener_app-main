import 'package:betweeener_app/views_features/auth/login_view.dart';
import 'package:betweeener_app/views_features/main_app_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  static const String id = '/loading';
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  checkUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('user')) {
      Navigator.pushReplacementNamed(context, MainAppView.id);
    } else {
      Navigator.pushReplacementNamed(context, LoginView.id);
    }
  }

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
