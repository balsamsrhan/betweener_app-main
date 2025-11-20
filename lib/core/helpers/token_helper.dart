import 'package:betweeener_app/core/helpers/shared_prefs.dart';

Future<String> getToken() async {
  return await SharedPrefsController().getData('token');
}