import 'package:flutter/material.dart';
import 'package:skill_link/app/constant/theme_constant.dart';

class AppTheme {
  AppTheme._();

  static ThemeData getApplicationTheme({required bool isDarkMode}) {
    return ThemeData(
      colorScheme: isDarkMode
          ? const ColorScheme.dark(primary: ThemeConstant.darkPrimaryColor)
          : const ColorScheme.light(primary: ThemeConstant.primaryColor),
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      fontFamily: 'Montserrat',
      useMaterial3: false,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: ThemeConstant.appBarColor,
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      scaffoldBackgroundColor: isDarkMode ? Colors.black : Colors.white,

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: Colors.white,
          backgroundColor: ThemeConstant.primaryColor,
          textStyle: const TextStyle(fontSize: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      inputDecorationTheme: const InputDecorationTheme(
        contentPadding: EdgeInsets.all(15),
        border: OutlineInputBorder(),
        labelStyle: TextStyle(fontSize: 20),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ThemeConstant.primaryColor),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ThemeConstant.primaryColor,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ThemeConstant.primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.black, // fallback
        behavior: SnackBarBehavior.floating,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );

  }
}