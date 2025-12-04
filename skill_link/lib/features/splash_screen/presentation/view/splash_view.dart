import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();

    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Always navigate to login page after splash
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // Calculate responsive dimensions
    final logoSize = screenWidth * 0.4; // 40% of screen width
    final containerPadding = screenWidth * 0.05; // 5% of screen width
    final titleFontSize = screenWidth * 0.08; // 8% of screen width
    final subtitleFontSize = screenWidth * 0.04; // 4% of screen width
    final loadingSize = screenWidth * 0.1; // 10% of screen width

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF003366), // Primary color - deep blue
              Color(0xFF004080), // Slightly lighter blue
              Color(0xFF0055AA), // Medium blue
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: containerPadding,
                      vertical: screenHeight * 0.05,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo and Animation Container
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            _fadeController,
                            _scaleController,
                          ]),
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Opacity(
                                opacity: _fadeAnimation.value,
                                child: Container(
                                  width:
                                      screenWidth * 0.85, // 85% of screen width
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        400, // Maximum width for large screens
                                    minHeight:
                                        screenHeight * 0.4, // Minimum height
                                  ),
                                  padding: EdgeInsets.all(containerPadding),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Lottie Animation
                                      Flexible(
                                        child: Lottie.asset(
                                          'assets/animation/animation_123.json',
                                          width: logoSize,
                                          height: logoSize,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.02),

                                      // App Name with responsive styling
                                      Flexible(
                                        child: Text(
                                          "SkillLink",
                                          style: TextStyle(
                                            fontSize: titleFontSize.clamp(
                                              24.0,
                                              48.0,
                                            ),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 2.0,
                                            shadows: const [
                                              Shadow(
                                                color: Colors.black26,
                                                offset: Offset(2, 2),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),

                                      SizedBox(height: screenHeight * 0.01),

                                      // Tagline
                                      Flexible(
                                        child: Text(
                                          "Find Your Perfect Home",
                                          style: TextStyle(
                                            fontSize: subtitleFontSize.clamp(
                                              14.0,
                                              20.0,
                                            ),
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w300,
                                            letterSpacing: 1.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: screenHeight * 0.08),

                        // Loading indicator
                        AnimatedBuilder(
                          animation: _fadeController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimation.value,
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: loadingSize,
                                    height: loadingSize,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  Text(
                                    "Loading...",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: subtitleFontSize.clamp(
                                        12.0,
                                        16.0,
                                      ),
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        SizedBox(height: screenHeight * 0.06),

                        // Version or additional info
                        AnimatedBuilder(
                          animation: _fadeController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimation.value * 0.7,
                              child: Text(
                                "v1.0.0",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: (subtitleFontSize * 0.8).clamp(
                                    10.0,
                                    14.0,
                                  ),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
