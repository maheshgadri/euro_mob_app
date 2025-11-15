import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile_model.dart';
import 'package:europhia/src/core/api_constants.dart';

class ProfileRepository {

  Future<UserProfileModel> fetchProfile(String userId) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/profile/$userId");


    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return UserProfileModel.fromJson(jsonData);
    } else {
      throw Exception("Failed to load profile: ${response.body}");
    }
  }
}
