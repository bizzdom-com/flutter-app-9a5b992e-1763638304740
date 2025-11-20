import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Constants - Matching App Icon Blue Gradient
  static const Color _primaryBackground = Color(0xFF0D0D0D);
  static const Color _secondaryBackground = Color(0xFF1A1A1A);
  static const Color _primaryBlue = Color(0xFF812A83); // #812a83 from configuration
  static const Color _accentBlue = Color(0xFF3B82F6); // Brighter blue from icon  
  static const Color _lightBlue = Color(0xFF60A5FA); // Light blue highlight
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9CA3AF);
  static const Color _successColor = Color(0xFF22C55E);
  static const Color _errorColor = Color(0xFFEF4444);
  static const Color _goldAccent = Color(0xFFFBBF24); // Gold star color

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: _primaryBlue,
        onPrimary: _primaryText,
        secondary: _accentBlue,
        onSecondary: _primaryBackground,
        surface: _primaryBackground,
        onSurface: _primaryText,
        surfaceVariant: _secondaryBackground,
        onSurfaceVariant: _secondaryText,
        error: _errorColor,
        onError: _primaryText,
        errorContainer: Color(0xFF2D1B1B),
        onErrorContainer: Color(0xFFFFB4AB),
        outline: Color(0xFF3A3A3A),
        outlineVariant: Color(0xFF2A2A2A),
      ),

      // Scaffold Background
      scaffoldBackgroundColor: _primaryBackground,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryBackground,
        foregroundColor: _primaryText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _primaryText,
        ),
      ),

      // Text Theme
      textTheme: GoogleFonts.interTextTheme().copyWith(
        // Headings
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: _primaryText,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: _primaryText,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: _primaryText,
        ),
        
        // Body text
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _primaryText,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _primaryText,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: _secondaryText,
        ),

        // Labels
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _primaryText,
          letterSpacing: 1.2,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _primaryText,
          letterSpacing: 1.1,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _secondaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: _accentBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: _errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: _secondaryText,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: _secondaryText,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        prefixIconColor: _secondaryText,
        suffixIconColor: _secondaryText,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: _primaryText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ).copyWith(
          // Add glow effect on press
          elevation: MaterialStateProperty.resolveWith<double>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) return 8;
              if (states.contains(MaterialState.hovered)) return 4;
              return 0;
            },
          ),
          shadowColor: MaterialStateProperty.all(_lightBlue.withOpacity(0.3)),
        ),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: _primaryText,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ).copyWith(
          // Add glow effect
          elevation: MaterialStateProperty.resolveWith<double>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) return 8;
              if (states.contains(MaterialState.hovered)) return 4;
              return 2;
            },
          ),
          shadowColor: MaterialStateProperty.all(_lightBlue.withOpacity(0.4)),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lightBlue,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: _lightBlue,
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: _secondaryBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: _primaryText,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3A3A3A),
        thickness: 1,
      ),
    );
  }

  // Neuromorphic Container Decoration
  static BoxDecoration neuromorphicDecoration({
    Color? color,
    double borderRadius = 20,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      color: color ?? _secondaryBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        // Outer glow
        BoxShadow(
          color: _lightBlue.withOpacity(0.1),
          blurRadius: 20,
          spreadRadius: -5,
        ),
        // Subtle shadow
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Input Field Focus Glow
  static BoxDecoration inputFocusDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: _lightBlue.withOpacity(0.4),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ],
    );
  }

  // Combined Input Field Decoration (neuromorphic + focus glow when focused)
  static BoxDecoration inputDecoration({
    bool isFocused = false,
    Color? color,
    double borderRadius = 20,
  }) {
    List<BoxShadow> shadows = [
      // Outer glow (neuromorphic)
      BoxShadow(
        color: _lightBlue.withOpacity(0.1),
        blurRadius: 20,
        spreadRadius: -5,
      ),
      // Subtle shadow (neuromorphic)
      BoxShadow(
        color: Colors.black.withOpacity(0.5),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];

    // Add focus glow when focused
    if (isFocused) {
      shadows.insert(0, BoxShadow(
        color: _lightBlue.withOpacity(0.4),
        blurRadius: 20,
        spreadRadius: 0,
      ));
    }

    return BoxDecoration(
      color: color ?? _secondaryBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadows,
    );
  }
}