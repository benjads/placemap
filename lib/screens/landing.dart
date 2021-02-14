import 'package:flutter/material.dart';
import 'package:placemap/screens/common.dart';
import 'package:placemap/screens/intro.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntroScreen(
      showTitle: true,
      footer: null,
      content: Column(
        children: [
          PlacemapButton(
              onPressed: () => Navigator.pushNamed(context, '/join'),
              text: 'Start'),
          SizedBox(height: 30),
          PlacemapButton(
              onPressed: () => Navigator.pushNamed(context, '/about'),
              text: 'About'),
        ],
      ),
    );
  }
}
