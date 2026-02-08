import 'package:flutter/material.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/auth/screens/pin_screen.dart';
import '../../features/auth/screens/setup_pin_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/diary/screens/diary_entry_screen.dart';
import '../../features/diary/screens/diary_detail_screen.dart';
import '../../features/diary/screens/voice_diary_screen.dart';
import '../../features/mood/screens/mood_calendar_screen.dart';
import '../../features/mood/screens/mood_analytics_screen.dart';
import '../../features/chat/screens/ai_chat_screen.dart';
import '../../features/summary/screens/summary_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String setupPin = '/setup-pin';
  static const String pin = '/pin';
  static const String home = '/home';
  static const String diaryEntry = '/diary/entry';
  static const String diaryDetail = '/diary/detail';
  static const String voiceDiary = '/diary/voice';
  static const String moodCalendar = '/mood/calendar';
  static const String moodAnalytics = '/mood/analytics';
  static const String aiChat = '/chat';
  static const String summary = '/summary';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen());
      
      case onboarding:
        return _slideRoute(const OnboardingScreen());
      
      case setupPin:
        return _slideRoute(const SetupPinScreen());
      
      case pin:
        return _fadeRoute(const PinScreen());
      
      case home:
        return _fadeRoute(const HomeScreen());
      
      case diaryEntry:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slideRoute(
          DiaryEntryScreen(
            entryId: args?['entryId'],
            promptQuestion: args?['promptQuestion'],
          ),
        );
      
      case diaryDetail:
        final entryId = settings.arguments as String;
        return _slideRoute(DiaryDetailScreen(entryId: entryId));
      
      case voiceDiary:
        return _slideRoute(const VoiceDiaryScreen());
      
      case moodCalendar:
        return _slideRoute(const MoodCalendarScreen());
      
      case moodAnalytics:
        return _slideRoute(const MoodAnalyticsScreen());
      
      case aiChat:
        return _slideRoute(const AiChatScreen());
      
      case summary:
        return _slideRoute(const SummaryScreen());
      
      case AppRouter.settings:
        return _slideRoute(const SettingsScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
