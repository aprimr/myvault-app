import 'package:app/core/routes.dart';
import 'package:app/core/theme.dart';
import 'package:app/screens/auth/login_screen.dart';
import 'package:app/screens/auth/signup_screen.dart';
import 'package:app/screens/auth/verify_account_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Vault',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),

      initialRoute: AppRoutes.loginRoute,
      routes: {
        AppRoutes.loginRoute: (context) => LoginScreen(),
        AppRoutes.signupRoute: (context) => SignupScreen(),
        AppRoutes.verifyAccountRoute: (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;

          return VerifyAccountScreen(email: args["email"], uid: args["uid"]);
        },
      },
    );
  }
}
