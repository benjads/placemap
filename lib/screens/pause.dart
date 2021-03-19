import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/models/session.dart';
import 'package:placemap/screens/activity_wrapper.dart';
import 'package:placemap/screens/common.dart';
import 'package:placemap/screens/intro.dart';
import 'package:provider/provider.dart';

class PauseScreen extends StatelessWidget {
  static const readyMsg = 'Are you ready to learn a new play-food tradition?';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActivityWrapper(
      child: IntroScreen(
        showTitle: false,
        footer: null,
        content: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Text(
                'PlaceMap',
                style: GoogleFonts.nanumBrushScript(
                    textStyle: theme.textTheme.headline3),
              ),
              SizedBox(height: 120),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  readyMsg,
                  style: theme.textTheme.headline5,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 30),
              PlacemapButton(
                  onPressed: () {
                    final AppData appData = context.read<AppData>();
                    appData.clearReview();
                    appData.routeChange = true;
                    appData.session.setState(SessionState.search, true);
                  },
                  text: 'Get a Tradition'),
              DividerText(text: 'or'),
              PlacemapButton(
                  onPressed: () {
                    final AppData appData = context.read<AppData>();
                    appData.session.setSelfQuit(true);
                    Navigator.popAndPushNamed(context, '/exit');
                  },
                  text: 'Exit'),
            ],
          ),
        ),
      ),
    );
  }

}