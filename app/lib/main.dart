import 'package:app/core/api.dart';
import 'package:app/core/routes.dart';
import 'package:app/core/service_locator.dart';
import 'package:app/core/theme.dart';
import 'package:app/screens/app/credentials/add_credential_screen.dart';
import 'package:app/screens/app/credentials/view_credential_screen.dart';
import 'package:app/screens/app/home_layout.dart';
import 'package:app/screens/app/notes/add_note_screen.dart';
import 'package:app/screens/app/notes/view_note_screen.dart';
import 'package:app/screens/auth/enter_pin_screen.dart';
import 'package:app/screens/auth/login_screen.dart';
import 'package:app/screens/auth/post_login_router.dart';
import 'package:app/screens/auth/setup_pin_screen.dart';
import 'package:app/screens/auth/signup_screen.dart';
import 'package:app/screens/auth/verify_account_screen.dart';
import 'package:app/screens/welcome/splash_screen.dart';
import 'package:app/screens/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  apiClient = ApiClient(navigatorKey: navigatorKey);

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

      navigatorKey: navigatorKey,
      initialRoute: AppRoutes.splashRoute,
      routes: {
        // Splash & welcome
        AppRoutes.splashRoute: (context) => SplashScreen(),
        AppRoutes.welcomeRoute: (context) => WelcomeScreen(),

        // Pin
        AppRoutes.postLoginRoute: (context) => PostLoginRouter(),
        AppRoutes.setupPinRoute: (context) => SetupPinScreen(),
        AppRoutes.enterPinRoute: (context) => EnterPinScreen(),

        // Auth
        AppRoutes.loginRoute: (context) => LoginScreen(),
        AppRoutes.signupRoute: (context) => SignupScreen(),
        AppRoutes.verifyAccountRoute: (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;

          return VerifyAccountScreen(email: args["email"], uid: args["uid"]);
        },

        // Protected routes
        AppRoutes.homeRoute: (context) => HomeLayout(),

        // Credential
        AppRoutes.addCredentialRoute: (context) => AddCredentialScreen(),
        AppRoutes.viewCredentialRoute: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return ViewCredentialScreen(id: args);
        },

        // Notes
        AppRoutes.addNoteRoute: (context) => AddNoteScreen(),
        AppRoutes.viewNoteRoute: (context) {
          final id = ModalRoute.of(context)!.settings.arguments as String;
          return ViewNoteScreen(noteId: id);
        },
      },
    );
  }
}
