import 'package:app/core/routes.dart';
import 'package:app/core/storage.dart';
import 'package:app/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class EnterPinScreen extends StatefulWidget {
  const EnterPinScreen({super.key});

  @override
  State<EnterPinScreen> createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> {
  final appPin = AppPin();

  String pin = "";
  String savedPin = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final pinValue = await appPin.getPin();

    setState(() {
      savedPin = pinValue ?? "";
      isLoading = false;
    });
  }

  void _onKeyTap(String value) {
    if (isLoading) return;

    setState(() {
      if (value == "back") {
        if (pin.isNotEmpty) {
          pin = pin.substring(0, pin.length - 1);
        }
        return;
      }

      if (pin.length < 4) {
        pin += value;
      }

      if (pin.length == 4) {
        Future.delayed(const Duration(milliseconds: 150), _checkPin);
      }
    });
  }

  void _checkPin() {
    if (isLoading) return;

    if (savedPin.isEmpty) {
      AppSnackbar.show(context, message: "Please wait...");
      return;
    }

    if (pin == savedPin) {
      Navigator.pushReplacementNamed(context, AppRoutes.homeRoute);
    } else {
      setState(() => pin = "");

      AppSnackbar.show(
        context,
        message: "PINs do not match",
        isError: true,
        actionLabel: "Get Help",
        onAction: () {
          Navigator.pushReplacementNamed(context, AppRoutes.signupRoute);
        },
      );
    }
  }

  Widget _dot(int index, ColorScheme colorScheme) {
    final filled = index < pin.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: filled ? colorScheme.primary : colorScheme.primary.withAlpha(40),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _key(String value, ColorScheme colorScheme) {
    final isEmpty = value.isEmpty;

    return Expanded(
      child: Center(
        child: isEmpty
            ? const SizedBox()
            : Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(36),
                  onTap: () => _onKeyTap(value),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.onSurface.withAlpha(8),
                    ),
                    child: Center(
                      child: value == "back"
                          ? Icon(
                              Icons.backspace_outlined,
                              color: colorScheme.onSurface.withAlpha(180),
                              size: 22,
                            )
                          : Text(
                              value,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _row(List<String> keys, ColorScheme colorScheme) {
    return Row(children: keys.map((k) => _key(k, colorScheme)).toList());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),

              // Icon
              HugeIcon(
                icon: HugeIcons.strokeRoundedSafeBox,
                color: colorScheme.primary,
                size: 50,
              ),

              const SizedBox(height: 14),

              // Title
              Text(
                "Enter PIN",
                style: GoogleFonts.nunitoSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 6),

              // Subtitle
              Text(
                "Enter your 4-digit PIN to continue",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  height: 1.5,
                  color: colorScheme.onSurface.withAlpha(140),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // Dots
              if (isLoading)
                SizedBox(
                  height: 14,
                  width: 14,
                  child: const CircularProgressIndicator(strokeWidth: 1.5),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) => _dot(i, colorScheme)),
                ),
              const SizedBox(height: 40),

              // Keypad
              Column(
                children: [
                  _row(["1", "2", "3"], colorScheme),
                  const SizedBox(height: 20),
                  _row(["4", "5", "6"], colorScheme),
                  const SizedBox(height: 20),
                  _row(["7", "8", "9"], colorScheme),
                  const SizedBox(height: 20),
                  _row(["", "0", "back"], colorScheme),
                ],
              ),

              const SizedBox(height: 76),
            ],
          ),
        ),
      ),
    );
  }
}
