import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:europhia/src/presentation/bloc/auth/auth_bloc.dart';
import 'package:europhia/src/data/repositories/auth_repository.dart';
import 'package:europhia/src/presentation/screens/signup_screen.dart';
import 'package:europhia/src/presentation/screens/home_screen.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(AuthRepository()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Europhia',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/signup',
        routes: {
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
          // Later we’ll add:
          // '/login': (context) => const LoginScreen(),
          // '/profileCompletion': (context) => const ProfileCompletionScreen(),
        },
      ),
    );
  }
}