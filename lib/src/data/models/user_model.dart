class UserModel {
  final int id;
  final String email;
  final String username;
  final String token;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handles both formats:
      // 1️⃣ { "token": "...", "user": { "id": 1, "email": "...", "username": "..." } }
      // 2️⃣ { "id": 1, "email": "...", "username": "...", "token": "..." }
      final userData = json['user'] ?? json;

      return UserModel(
        id: userData['id'] ?? 0,
        email: userData['email'] ?? '',
        username: userData['username'] ?? '',
        token: json['token'] ?? userData['token'] ?? '',
      );
    } catch (e) {
      throw Exception("UserModel parse error: $e | Data: $json");
    }
  }
}
