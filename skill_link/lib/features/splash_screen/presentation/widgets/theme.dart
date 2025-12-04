import 'package:flutter/material.dart';

const Color navyBlue = Color(0xFF003366);

ThemeData getApplication() {
  return ThemeData(
    useMaterial3: false,
    primaryColor: navyBlue,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: navyBlue,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    fontFamily: "Roboto",
  );
}
