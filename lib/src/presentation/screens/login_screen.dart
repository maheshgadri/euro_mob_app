
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:europhia/src/presentation/bloc/auth/auth_bloc.dart';
import 'package:europhia/src/presentation/bloc/auth/auth_state.dart';
import 'package:europhia/src/presentation/bloc/auth/auth_event.dart';
class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Login successful!")));
            // Navigate to Home or Profile Completion Screen
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
                TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(LoginRequested(
                        emailController.text, passwordController.text));
                  },
                  child: Text("Login"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
