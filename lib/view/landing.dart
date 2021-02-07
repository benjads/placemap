import 'package:flutter/material.dart';
import 'package:placemap/view/common/common.dart';
import 'package:placemap/view/common/intro.dart';
import 'package:placemap/view/join.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntroScreen(
      showTitle: true,
      footer: null,
      content: Column(
        children: [
          PlacemapButton(
              onPressed: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          JoinScreen(),
                      transitionDuration: Duration(seconds: 0))),
              text: 'Start'),
          SizedBox(height: 30),
          PlacemapButton(
              onPressed: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          AboutScreen(),
                      transitionDuration: Duration(seconds: 0))),
              text: 'About'),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  static const desc =
      "PlaceMap is an app designed to support playful and social interaction at mealtime. It was designed by a team of researchers at UC Santa Cruz. If you'd like to know more about the project, please reach out to faltarri@ucsc.edu";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntroScreen(
      showTitle: true,
      footer: null,
      content: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Text(
              desc,
              style: theme.textTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
          ),
          PlacemapButton(onPressed: () => Navigator.pop(context), text: 'Back'),
        ],
      ),
    );
  }
}
