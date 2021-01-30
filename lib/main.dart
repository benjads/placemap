import 'package:flutter/material.dart';
import 'package:placemap/view/landing.dart';

void main() {
  runApp(PlacemapApp());
}

class PlacemapApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Placemap',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(0, 113, 188, 1),
        textTheme: TextTheme(
          bodyText1: TextStyle(),
        ).apply(
          bodyColor: Color.fromRGBO(163, 237, 244, 1),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color.fromRGBO(0, 113, 188, 1),
        ),
        fontFamily: 'Vinson',
      ),
      home: LandingScreen(),
    );
  }
}
