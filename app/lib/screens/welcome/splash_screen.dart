import 'package:app/core/constants.dart';
import 'package:app/core/routes.dart';
import 'package:app/core/storage.dart';
import 'package:app/utils/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFlow();
  }

  Future<void> _checkFlow() async {
    final isWelcomeCompleted =
        await SharedPrefs.getBool(Constants.isWelcomeCompleted) ?? false;

    final loginToken = await SecureStorage().getToken();

    if (!mounted) return;

    // First time user → Welcome
    if (!isWelcomeCompleted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.welcomeRoute,
        (route) => false,
      );
      return;
    }

    // Already logged in → Home
    if (loginToken != null && loginToken.isNotEmpty) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.postLoginRoute,
        (route) => false,
      );
      return;
    }

    // Not logged in → Login
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.loginRoute,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Logo
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedSafeBox,
                    color: colorScheme.primary,
                    size: 86,
                  ),
                ],
              ),
            ),
          ),

          // Spinner
          Padding(
            padding: const EdgeInsets.only(bottom: 82),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
