import 'package:app/core/routes.dart';
import 'package:app/core/storage.dart';
import 'package:flutter/material.dart';

class PostLoginRouter extends StatefulWidget {
  const PostLoginRouter({super.key});

  @override
  State<PostLoginRouter> createState() => _PostLoginRouterState();
}

class _PostLoginRouterState extends State<PostLoginRouter> {
  final AppPin _appPin = AppPin();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _check();
    });
  }

  Future<void> _check() async {
    final pin = await _appPin.getPin();

    if (!mounted) return;

    if (pin == null || pin.isEmpty) {
      Navigator.pushReplacementNamed(context, AppRoutes.setupPinRoute);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.enterPinRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
