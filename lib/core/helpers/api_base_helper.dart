import 'dart:convert';
import 'dart:io';

import 'package:betweeener_app/core/util/constants.dart';
import 'package:http/http.dart' as http;

import 'app_exception.dart';

class ApiBaseHelper {
  Future<dynamic> get(String url, Map<String, String> header) async {
    var responseJson;
    try {
      final response = await http.get(
        Uri.parse(baseUrl + url),
        headers: header,
      );

      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> post(
    String url,
    Map<String, dynamic> body,
    Map<String, String> header,
  ) async {
    var responseJson;
    try {
      final response = await http.post(
        Uri.parse(baseUrl + url),
        body: body,
        headers: header,
      );

      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        var responseJson = json.decode(response.body);
        return responseJson;
      case 400:
        throw BadRequestException(response.body);
      case 401:
      case 403:
        throw UnauthorisedException(response.body);
      case 500:
      default:
        throw FetchDataException(
          'Error occurred while Communication with Server with StatusCode : ${response.statusCode}',
        );
    }
  }
}
