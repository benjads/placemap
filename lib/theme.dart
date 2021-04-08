import 'package:flutter/material.dart';

final appTheme = ThemeData(
  primaryColor: Color.fromRGBO(0, 113, 188, 1),
  colorScheme: ColorScheme.light(
    primary: Color.fromRGBO(0, 113, 188, 1),
    primaryVariant: Color.fromRGBO(5, 56, 79, 1),
    onPrimary: Color.fromRGBO(163, 237, 244, 1),
    error: Color.fromRGBO(163, 19, 10, 1),
    onError: Color.fromRGBO(193, 39, 45, 1)

  ),
  textTheme: TextTheme(
    headline1: TextStyle(),
    headline2: TextStyle(),
    headline3: TextStyle(),
    headline4: TextStyle(),
    headline5: TextStyle(),
    headline6: TextStyle(),
    bodyText1: TextStyle(),
  ).apply(
    bodyColor: Color.fromRGBO(163, 237, 244, 1),
    displayColor: Color.fromRGBO(163, 237, 244, 1),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Color.fromRGBO(0, 113, 188, 1),
  ),
  fontFamily: 'Vinson',
);