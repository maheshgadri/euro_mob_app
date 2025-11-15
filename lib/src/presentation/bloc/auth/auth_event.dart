import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

class SignupRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String displayName;
  final String dob;
  final String gender;
  final String sexualOrientation;
  final String pronouns;
  final String interestedIn;
  final String location;

  SignupRequested({
    required this.username,
    required this.email,
    required this.password,
    required this.displayName,
    required this.dob,
    required this.gender,
    required this.sexualOrientation,
    required this.pronouns,
    required this.interestedIn,
    required this.location
  });
}
