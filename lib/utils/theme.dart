import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get blueTheme {
    return ThemeData(
      primarySwatch: Colors.lightGreen,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.lightGreen,
      ).copyWith(
        secondary: Colors.lightGreenAccent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.lightGreen,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.lightGreen,
        foregroundColor: Colors.white,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.lightGreen,
        textTheme: ButtonTextTheme.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightGreen),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black), // Black border
        ),
        errorBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Colors.red), // Red border for error state
        ),
      ),
    );
  }
}
