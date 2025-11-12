import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:europhia/src/presentation/bloc/auth/auth_bloc.dart';
import 'package:europhia/src/data/models/user_model.dart';
import 'package:europhia/src/presentation/bloc/auth/auth_event.dart';
import 'package:europhia/src/presentation/bloc/auth/auth_state.dart';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:europhia/src/presentation/bloc/auth/auth_bloc.dart';
import 'package:europhia/src/presentation/bloc/auth/auth_event.dart';
import 'package:europhia/src/presentation/bloc/auth/auth_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _pronounsController = TextEditingController();

  String? _dob;
  String _selectedGender = 'Male';
  String _selectedOrientation = 'Straight';
  String? _selectedInterestedIn;

  bool _isPasswordVisible = false;

  final List<String> _interestedInOptions = ['Male', 'Female', 'Both'];

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dob =
        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _submitSignup() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(SignupRequested(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        displayName: _displayNameController.text.trim(),
        dob: _dob ?? '',
        gender: _selectedGender,
        sexualOrientation: _selectedOrientation,
        pronouns: _pronounsController.text.trim(),
        interestedIn: _selectedInterestedIn ?? '',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error.toString())),
            );
          } else if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Signup Successful ✅")),
            );

            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.pushReplacementNamed(context, '/home');
            });
          }
        },

        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Signup",
                      style:
                      TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: "Username"),
                    validator: (v) => v!.isEmpty ? "Enter username" : null,
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    validator: (v) => v!.isEmpty ? "Enter email" : null,
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (v) => v!.length < 6
                        ? "Password must be at least 6 characters"
                        : null,
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _displayNameController,
                    decoration:
                    const InputDecoration(labelText: "Display Name"),
                    validator: (v) => v!.isEmpty ? "Enter display name" : null,
                  ),
                  const SizedBox(height: 10),

                  // DOB Calendar Picker
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration:
                      const InputDecoration(labelText: "Date of Birth"),
                      child: Text(
                        _dob ?? "Select your birth date",
                        style: TextStyle(
                          color: _dob == null
                              ? Colors.grey.shade600
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(
                          value: 'Non-binary', child: Text('Non-binary')),
                    ],
                    onChanged: (v) => setState(() => _selectedGender = v!),
                    decoration: const InputDecoration(labelText: "Gender"),
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: _selectedOrientation,
                    items: const [
                      DropdownMenuItem(
                          value: 'Straight', child: Text('Straight')),
                      DropdownMenuItem(value: 'Gay', child: Text('Gay')),
                      DropdownMenuItem(
                          value: 'Lesbian', child: Text('Lesbian')),
                      DropdownMenuItem(
                          value: 'Bisexual', child: Text('Bisexual')),
                    ],
                    onChanged: (v) => setState(() => _selectedOrientation = v!),
                    decoration:
                    const InputDecoration(labelText: "Sexual Orientation"),
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _pronounsController,
                    decoration: const InputDecoration(
                        labelText: "Pronouns (he/him, she/her, etc.)"),
                  ),
                  const SizedBox(height: 10),

                  // Interested In Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedInterestedIn,
                    items: _interestedInOptions
                        .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedInterestedIn = val),
                    decoration:
                    const InputDecoration(labelText: "Interested In"),
                    validator: (v) =>
                    v == null ? "Please select interested in" : null,
                  ),
                  const SizedBox(height: 30),

                  if (state is AuthLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Sign Up",
                            style:
                            TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


