import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_constants.dart';
import '../models/user_model.dart';
import 'package:http/http.dart'as http;

class AuthRepository {
  final http.Client _client = http.Client();

  // LOGIN
  Future<UserModel> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // final user = UserModel.fromJson(data);
      //
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString('token', user.token);
      // return user;


      final token = data['token'];
      final userData = data['user'];

      final user = UserModel.fromJson({
        'id': userData['id'],
        'email': userData['email'],
        'username': userData['username'],
        'token': token,
      });

      // ✅ Save token + userId locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userId', user.id.toString());

      return user;
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  // SIGNUP
  Future<UserModel> signup({
    required String username,
    required String email,
    required String password,
    required String displayName,
    required String dob,
    required String gender,
    required String sexualOrientation,
    required String pronouns,
    required String interestedIn,
    required String location,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.signup),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "username": username,
        "password": password,
        "displayName": displayName,
        "dob": dob,
        "gender": gender,
        "sexualOrientation": sexualOrientation,
        "pronouns": pronouns,
        "interestedIn": interestedIn,
        "location": location
      }),
    );

    print("📤 SIGNUP SENDING => countryName: $location");

    // ✅ Debugging line — see the full backend response in your console
    print('Signup response: ${response.statusCode} => ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      // final user = UserModel.fromJson(data);
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString('token', user.token);
      // return user;

      // ✅ Extract user + token
      final token = data['token'];
      final userData = data['user'];

      final user = UserModel.fromJson({
        'id': userData['id'],
        'email': userData['email'],
        'username': userData['username'],
        'token': token,
      });

      // ✅ Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userId', user.id.toString());

      return user;
    } else {
      print("exception${response.body}");
      throw Exception("Failed to signup: ${response.body}");

    }
  }

  // GET TOKEN
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
