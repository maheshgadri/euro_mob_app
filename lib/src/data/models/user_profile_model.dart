class UserProfileModel {
  final int id;
  final String name;
  final int? age;
  final String? location;
  final String? about;
  final String? hobbies;
  final String gender;
  final List<String> photos;

  UserProfileModel({
    required this.id,
    required this.name,
    this.age,
    this.location,
    this.about,
    this.hobbies,
    required this.gender,
    required this.photos,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      name: json['name'] ?? '',
      age: json['age'],
      location: json['location'],
      about: json['about'],
      hobbies: json['hobbies'],
      gender: json['gender'] ?? '',
      photos: json['photos'] != null
          ? List<String>.from(json['photos'])
          : [],
    );
  }
}
