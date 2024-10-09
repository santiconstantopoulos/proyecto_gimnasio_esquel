import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color.fromARGB(255, 54, 32, 68);
  static const Color accentColor = Color.fromARGB(255, 255, 187, 0);
  static const Color textColor = Colors.white; 
  static const Color greyColor = Colors.grey;
  static const Color buttonTextColor = Color.fromARGB(255, 100, 92, 119);

  static const Color backgroundSoftColor = Color.fromARGB(255, 221, 213, 213);

  static final ThemeData appTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accentColor,
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 221, 213, 213),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      titleTextStyle: TextStyle(
        fontSize: 22, 
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: textColor,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary, 
      shape: StadiumBorder(),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(), 
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: greyColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: accentColor),
      ), 
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 16,
        color: greyColor
      ), 
    ),
  );
}