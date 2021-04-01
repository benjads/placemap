import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/models/session.dart';
import 'package:placemap/screens/activity_wrapper.dart';
import 'package:placemap/screens/common.dart';
import 'package:placemap/screens/intro.dart';
import 'package:provider/provider.dart';

class ExitScreen extends StatelessWidget {
  static const exitMsg = 'This is a group experience, so all the party should be OK with ending it. '
      'Let’s wait for everyone to decide.';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActivityWrapper(
      child: IntroScreen(
        showTitle: false,
        footer: null,
        content: Column(
          children: [
            Text(
              'PlaceMap',
              style: GoogleFonts.nanumBrushScript(
                  textStyle: theme.textTheme.headline3),
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                exitMsg,
                style: theme.textTheme.headline5,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            ReturnButton(),
            ExitButton()
          ],
        ),
      ),
    );
  }
}

class ReturnButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, _) {
        if (appData.session.state == SessionState.ended) {
          return SizedBox.shrink();
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: PlacemapButton(
                onPressed: () {
                  final AppData appData = context.read<AppData>();
                  appData.clearReview();
                  appData.session.setSelfQuit(false);
                  appData.routeChange = true;
                  appData.session.setState(SessionState.search, true);
                },
                text: 'Go Back'),
          );
        }
      },
    );
  }
}

class ExitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AppData>(
      builder: (context, appData, _) {
        if (appData.session.allQuit()) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: PlacemapButton(
                onPressed: () async {
                  final AppData appData = context.read<AppData>();
                  appData.session.setState(SessionState.ended, true);
                  SystemNavigator.pop();
                  exit(0);
                },
                text: 'Exit'),
          );
        } else {
          return Text(
            'Waiting for others to exit...',
            style: theme.textTheme.bodyText1,
          );
        }
      },
    );
  }

}