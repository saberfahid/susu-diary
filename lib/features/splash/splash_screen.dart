import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/security_service.dart';
import '../../core/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    try {
      final securityService = SecurityService.instance;
      final isFirstLaunch = await securityService.isFirstLaunch();
      final isPinSet = await securityService.isPinSet();

      if (!mounted) return;

      if (isFirstLaunch) {
        Navigator.pushReplacementNamed(context, AppRouter.onboarding);
      } else if (isPinSet) {
        Navigator.pushReplacementNamed(context, AppRouter.pin);
      } else {
        Navigator.pushReplacementNamed(context, AppRouter.home);
      }
    } catch (e) {
      // On error, go to home
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.gradientStart,
              AppTheme.gradientMiddle,
              AppTheme.gradientEnd,
            ],
          ),
        ),
        child: Stack(
          children: [
            // ✨ Decorative sparkles
            Positioned(
              top: 80,
              left: 30,
              child: Text('✨', style: TextStyle(fontSize: 24))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn()
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1500.ms),
            ),
            Positioned(
              top: 120,
              right: 50,
              child: Text('🌟', style: TextStyle(fontSize: 20))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(delay: 200.ms)
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.1, 1.1), duration: 1300.ms),
            ),
            Positioned(
              bottom: 150,
              left: 60,
              child: Text('💖', style: TextStyle(fontSize: 18))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(delay: 400.ms)
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.15, 1.15), duration: 1400.ms),
            ),
            Positioned(
              bottom: 200,
              right: 40,
              child: Text('🌸', style: TextStyle(fontSize: 22))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(delay: 300.ms)
                  .scale(begin: const Offset(0.85, 0.85), end: const Offset(1.1, 1.1), duration: 1600.ms),
            ),
            Positioned(
              top: 200,
              left: 100,
              child: Text('⭐', style: TextStyle(fontSize: 16))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(delay: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1200.ms),
            ),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo - Custom branded icon
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.4),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        'assets/icons/app_icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            size: 70,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(delay: 200.ms, begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
                  
                  const SizedBox(height: 36),
                  
                  // App name
                  Text(
                    'Susu',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: 12),
                  
                  // Tagline with sparkles
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        'Your AI Diary',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.95),
                              letterSpacing: 1,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(width: 8),
                      const Text('✨', style: TextStyle(fontSize: 16)),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 600.ms),
                  
                  const SizedBox(height: 70),
                  
                  // Cute loading hearts
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBouncingHeart(0),
                      const SizedBox(width: 8),
                      _buildBouncingHeart(150),
                      const SizedBox(width: 8),
                      _buildBouncingHeart(300),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 400.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBouncingHeart(int delayMs) {
    return Icon(
      Icons.favorite,
      color: Colors.white.withOpacity(0.9),
      size: 16,
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          delay: Duration(milliseconds: delayMs),
          duration: 600.ms,
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
        );
  }
}
