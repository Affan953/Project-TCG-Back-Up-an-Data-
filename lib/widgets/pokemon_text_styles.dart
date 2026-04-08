import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PokemonTextStyles {
  // Brand Logo
  static TextStyle brandLogo({Color? color, double fontSize = 36}) {
    return GoogleFonts.pressStart2p(
      textStyle: TextStyle(
        fontSize: fontSize,
        color: color ?? const Color(0xFFfbbf24),
        letterSpacing: 0.05 * fontSize,
      ),
    );
  }

  // Subtitle
  static TextStyle subtitle({Color? color, double fontSize = 16}) {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        fontSize: fontSize,
        color: color ?? const Color(0xFFbfdbfe),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // Label, Input, Button
  static TextStyle inter({
    Color color = Colors.white,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
    );
  }
}
