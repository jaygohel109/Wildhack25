import 'package:flutter/material.dart';
import 'login_screen.dart';

// Updated vibrant theme
const Color kcPrimary = Color(0xFF2B1A62);     // Deep Purple
const Color kcAccent = Color(0xFFFF82A9);      // Soft Pink
const Color kcSecondary = Color(0xFFE3D9FF);   // Light Lilac
const Color kcSurface = Color(0xFF3B2C80);     // Darker Purple
const Color kcWhite = Colors.white;
const Color kcMutedText = Color(0xFFB7B1D2);   // Muted subtitle

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _taglineController;
  late AnimationController _buttonController;

  late Animation<Offset> _logoOffset;
  late Animation<double> _logoOpacity;
  late Animation<double> _taglineFade;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoOffset = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeIn),
    );

    _buttonScale = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );

    _logoController.forward().whenComplete(() {
      _taglineController.forward();
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _taglineController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _goToLogin(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kcPrimary, kcSurface],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              SlideTransition(
                position: _logoOffset,
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: Text(
                    'KindCare',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: kcAccent,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: kcAccent.withOpacity(0.6),
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _taglineFade,
                child: const Text(
                  'Connecting Seniors with Helping Hands',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kcMutedText,
                    fontSize: 16,
                  ),
                ),
              ),
              const Spacer(),
              ScaleTransition(
                scale: _buttonScale,
                child: ElevatedButton(
                  onPressed: () => _goToLogin(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kcAccent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}