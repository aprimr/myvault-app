import 'package:app/core/routes.dart';
import 'package:app/core/theme.dart';
import 'package:app/screens/auth/login_screen.dart';
import 'package:app/screens/auth/signup_screen.dart';
import 'package:app/screens/auth/verify_account_screen.dart';
import 'package:app/screens/welcome/splash_screen.dart';
import 'package:app/screens/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

      initialRoute: AppRoutes.splashRoute,
      routes: {
        AppRoutes.splashRoute: (context) => SplashScreen(),
        AppRoutes.welcomeRoute: (context) => WelcomeScreen(),
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
