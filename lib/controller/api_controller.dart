import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiController {
  //static const String baseUrl = "http://10.0.2.2:8000";
  static const String baseUrl = "https://pc-recommender-api-7a23d.ondigitalocean.app/";

  // Constructor
  ApiController();

  // // Hàm GET request với input
  // Future<dynamic> _getRequest(String endpoint, Map<String, String> params) async {
  //   final Uri url = Uri.parse(baseUrl + endpoint).replace(queryParameters: params);
  //
  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body); // Parse JSON
  //     } else {
  //       throw Exception('Failed GET request: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error during GET request: $e');
  //   }
  // }
  //
  // // Hàm POST request với input
  // Future<dynamic> _postRequest({
  //   required String endpoint,
  //   required Map<String, dynamic> body,
  //   String? redirect
  // }) async {
  //   final Uri url = redirect == null ? Uri.parse(baseUrl + endpoint) : Uri.parse(redirect);
  //   print(url);
  //
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(body),
  //     );
  //     print(jsonEncode(body));
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return jsonDecode(response.body); // Parse JSON
  //     } else if (response.statusCode == 307) {
  //       final redirectedUrl = response.headers['location'];
  //       _postRequest(endpoint: endpoint, body: body, redirect: redirectedUrl);
  //     } else {
  //       throw Exception('Failed POST request: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error during POST request: $e');
  //   }
  // }

  Future<List<String>> callApiRecommend(String userId, int amount) async {
    try {
      Uri uri = Uri.parse("$baseUrl/recommend?uid=$userId&max=$amount");
      // print(uri);
      final response = await http.post(uri);
      // print(response.body);
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint(e.toString());
    }
    return [];
  }
}