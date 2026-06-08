import 'package:app/core/constants.dart';
import 'package:app/core/routes.dart';
import 'package:app/utils/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_SlideData> _slides = [
    _SlideData(
      icon: HugeIcons.strokeRoundedSafeBox,
      tag: 'Welcome',
      title: 'Your Private\nDigital Vault',
      description:
          'One secure place for everything that matters. Built for privacy, designed for you.',
      accentColor: const Color(0xFF63C1FF),
      bgColor: const Color(0xFFEDFAFF),
    ),
    _SlideData(
      icon: HugeIcons.strokeRoundedNote,
      tag: 'Organize',
      title: 'Notes &\nDocuments',
      description:
          'Write freely, store securely. Your thoughts and files, always within reach.',
      accentColor: const Color(0xFF00B894),
      bgColor: const Color(0xFFE6FAF5),
    ),
    _SlideData(
      icon: HugeIcons.strokeRoundedSquareLock02,
      tag: 'Passwords',
      title: 'Never Forget\nA Password',
      description:
          'Store your credentials with strong encryption. Access anytime, share with no one.',
      accentColor: const Color(0xFFE17055),
      bgColor: const Color(0xFFFFF0EC),
    ),
    _SlideData(
      icon: HugeIcons.strokeRoundedShieldKey,
      tag: 'Encrypted',
      title: 'Strong Data \nEncryption',
      description:
          'Your data is securely encrypted to keep it protected at all times. Privacy and safety are built into the system.',
      accentColor: const Color(0xFF0984E3),
      bgColor: const Color(0xFFE8F4FD),
    ),
  ];

  void _skipPage() {
    _pageController.jumpToPage(_slides.length - 1);
  }

  void _nextPage() async {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      await SharedPrefs.setBool(Constants.isWelcomeCompleted, true);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.signupRoute,
        (route) => false,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];
    final isLast = _currentPage == _slides.length - 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      color: slide.bgColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 10),

              // Skip button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedOpacity(
                      opacity: isLast ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: () => _skipPage(),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: slide.accentColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    return _SlidePage(data: _slides[index]);
                  },
                ),
              ),

              // Indicators row
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (i) {
                    final active = i == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? slide.accentColor
                            : slide.accentColor.withAlpha(50),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 20),

              // Nav buttons row
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Prev
                    AnimatedOpacity(
                      opacity: _currentPage > 0 ? 1 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: GestureDetector(
                        onTap: _prevPage,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: slide.accentColor.withAlpha(30),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: slide.accentColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ),

                    // Next / Get Started
                    GestureDetector(
                      onTap: _nextPage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                        width: isLast ? 160 : 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: slide.accentColor,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: slide.accentColor.withAlpha(80),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isLast
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Get Started',
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                )
                              : const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  final _SlideData data;

  const _SlidePage({required this.data});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 120),

          // Icon card
          HugeIcon(
            icon: data.icon,
            color: data.accentColor,
            size: size.width * 0.30,
          ),

          const SizedBox(height: 28),

          // Tag
          Text(
            data.tag.toUpperCase(),
            style: GoogleFonts.nunitoSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.2,
              color: data.accentColor,
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            data.title,
            style: GoogleFonts.nunitoSans(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1.15,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 14),

          // Description
          Text(
            data.description,
            style: GoogleFonts.nunitoSans(
              fontSize: 18,
              height: 1.65,
              color: const Color(0xFF1A1A2E).withAlpha(140),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  final dynamic icon;
  final String tag;
  final String title;
  final String description;
  final Color accentColor;
  final Color bgColor;

  const _SlideData({
    required this.icon,
    required this.tag,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.bgColor,
  });
}
