import 'package:flutter/material.dart';
import 'package:placemap/screens/common.dart';
import 'package:placemap/screens/intro.dart';

class AboutScreen extends StatelessWidget {
  static const desc =
      "PlaceMap is an app designed to support playful and social interaction at mealtime. It was designed by a team of researchers at UC Santa Cruz. "
      "If you'd like to know more about the project, please reach out to faltarri@ucsc.edu";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntroScreen(
      showTitle: true,
      footer: null,
      content: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              desc,
              style: theme.textTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 10),
          PlacemapButton(onPressed: () => Navigator.pop(context), text: 'Back'),
        ],
      ),
    );
  }
}