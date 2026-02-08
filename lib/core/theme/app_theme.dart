import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class AppTheme {
  // 🌈 Kawaii Pastel Brand Colors
  static const Color primaryColor = Color(0xFFB388EB);      // Soft lavender purple
  static const Color secondaryColor = Color(0xFFFFB3C6);    // Soft pink
  static const Color accentColor = Color(0xFF8BD3E6);       // Soft sky blue
  static const Color tertiaryColor = Color(0xFFFFE6A7);     // Soft warm yellow
  
  // ✨ Gradient Colors
  static const Color gradientStart = Color(0xFFFFB6C1);     // Light pink
  static const Color gradientMiddle = Color(0xFFDDA0DD);    // Plum/lavender
  static const Color gradientEnd = Color(0xFFB0E0E6);       // Powder blue
  
  // 💖 Mood Colors (Soft pastel versions)
  static const Color happyColor = Color(0xFFFFE066);        // Soft sunny yellow
  static const Color excitedColor = Color(0xFFFF9ECD);      // Bright pink
  static const Color calmColor = Color(0xFFA8E6CF);         // Mint green
  static const Color gratefulColor = Color(0xFFFFB347);     // Soft orange
  static const Color hopefulColor = Color(0xFFB4D4FF);      // Sky blue
  static const Color neutralColor = Color(0xFFD4B8E0);      // Light purple
  static const Color stressedColor = Color(0xFFFFAB91);     // Soft coral
  static const Color anxiousColor = Color(0xFFE6B3CC);      // Dusty pink
  static const Color sadColor = Color(0xFFA4C2F4);          // Soft blue
  static const Color angryColor = Color(0xFFFFB4B4);        // Light red/coral
  
  // 🌸 Light Theme Colors (Main theme - cozy & warm)
  static const Color lightBackground = Color(0xFFFFF5F7);   // Very soft pink white
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF5D4E6D);         // Soft purple-gray
  static const Color lightTextSecondary = Color(0xFF9B8FB0);
  
  // 🌙 Dark Theme Colors (Gentle dark, not harsh)
  static const Color darkBackground = Color(0xFF2D2540);    // Soft purple night
  static const Color darkSurface = Color(0xFF3D3550);
  static const Color darkText = Color(0xFFF5EEF8);
  static const Color darkTextSecondary = Color(0xFFB8A8C8);

  // 🎀 Decorative colors
  static const Color sparkleColor = Color(0xFFFFE4B5);
  static const Color heartColor = Color(0xFFFF7E9D);
  static const Color starColor = Color(0xFFFFD700);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: lightSurface,
        background: lightBackground,
        onPrimary: Colors.white,
        onSecondary: Color(0xFF5D4E6D),
        onSurface: lightText,
        onBackground: lightText,
      ),
      // Use a cute rounded font
      textTheme: GoogleFonts.quicksandTextTheme().apply(
        bodyColor: lightText,
        displayColor: lightText,
      ).copyWith(
        headlineLarge: GoogleFonts.comfortaa(
          color: lightText,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.comfortaa(
          color: lightText,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.quicksand(
          color: lightText,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.comfortaa(
          color: lightText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      cardTheme: CardTheme(
        color: lightSurface,
        elevation: 4,
        shadowColor: primaryColor.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),  // Extra rounded!
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: primaryColor.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),  // Pill-shaped
          ),
          textStyle: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(color: lightTextSecondary.withOpacity(0.7)),
        prefixIconColor: primaryColor,
        suffixIconColor: primaryColor,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: lightTextSecondary.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: secondaryColor.withOpacity(0.2),
        selectedColor: primaryColor,
        labelStyle: GoogleFonts.quicksand(
          color: lightText,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        backgroundColor: Colors.white,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryColor,
        contentTextStyle: GoogleFonts.quicksand(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(
        color: primaryColor.withOpacity(0.1),
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: primaryColor,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: primaryColor.withOpacity(0.2),
        thumbColor: primaryColor,
        overlayColor: primaryColor.withOpacity(0.2),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: darkSurface,
        background: darkBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkText,
        onBackground: darkText,
      ),
      textTheme: GoogleFonts.quicksandTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: darkText,
        displayColor: darkText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.comfortaa(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      cardTheme: CardTheme(
        color: darkSurface,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
    );
  }
  
  // 🌈 Get gradient decoration
  static BoxDecoration get pastelGradient => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [gradientStart, gradientMiddle, gradientEnd],
    ),
  );

  static BoxDecoration get pinkPurpleGradient => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        secondaryColor.withOpacity(0.8),
        primaryColor.withOpacity(0.8),
      ],
    ),
    borderRadius: BorderRadius.circular(24),
  );
  
  // 💖 Mood color getter
  static Color getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'joyful':
        return happyColor;
      case 'excited':
        return excitedColor;
      case 'calm':
      case 'peaceful':
      case 'relaxed':
        return calmColor;
      case 'grateful':
        return gratefulColor;
      case 'hopeful':
        return hopefulColor;
      case 'sad':
      case 'depressed':
      case 'down':
        return sadColor;
      case 'stressed':
        return stressedColor;
      case 'anxious':
      case 'worried':
        return anxiousColor;
      case 'angry':
      case 'frustrated':
      case 'irritated':
        return angryColor;
      default:
        return neutralColor;
    }
  }
  
  // 🎀 Mood emoji getter (cuter emojis)
  static String getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'joyful':
        return '🥰';
      case 'excited':
        return '✨';
      case 'calm':
      case 'peaceful':
        return '🌸';
      case 'relaxed':
        return '😌';
      case 'grateful':
        return '💖';
      case 'hopeful':
        return '🌈';
      case 'sad':
      case 'depressed':
        return '🥺';
      case 'down':
        return '💙';
      case 'stressed':
        return '😮‍💨';
      case 'anxious':
      case 'worried':
        return '🫧';
      case 'angry':
      case 'frustrated':
        return '😤';
      case 'irritated':
        return '😾';
      default:
        return '🌟';
    }
  }

  // ✨ Cute decorative elements
  static List<String> get sparkleEmojis => ['✨', '⭐', '💫', '🌟', '💖', '🌸', '🎀'];
  
  // 🔒 Get heart lock icon (for privacy feeling)
  static IconData get privacyIcon => Icons.favorite;
  
  // 🧠 Get AI icon (friendly, not robotic)
  static IconData get aiIcon => Icons.auto_awesome;
  static IconData get aiSparkIcon => Icons.psychology_alt;
}

// 🌸 Cute decorative widget for sparkles
class SparkleDecoration extends StatelessWidget {
  final double size;
  final Color? color;
  
  const SparkleDecoration({
    super.key,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '✨',
      style: TextStyle(
        fontSize: size,
        color: color,
      ),
    );
  }
}

// 💖 Heart decoration widget
class HeartDecoration extends StatelessWidget {
  final double size;
  final Color? color;
  
  const HeartDecoration({
    super.key,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.favorite,
      size: size,
      color: color ?? AppTheme.heartColor,
    );
  }
}

// 🌟 Star decoration widget
class StarDecoration extends StatelessWidget {
  final double size;
  final Color? color;
  
  const StarDecoration({
    super.key,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.star_rounded,
      size: size,
      color: color ?? AppTheme.starColor,
    );
  }
}
