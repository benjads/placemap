import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/models/participant.dart';
import 'package:placemap/models/session.dart';
import 'package:placemap/screens/activity_wrapper.dart';
import 'package:placemap/screens/common.dart';
import 'package:placemap/screens/intro.dart';
import 'package:provider/provider.dart';

class ExitScreen extends StatelessWidget {
  static const exitMsg =
      'This is a group experience, so all the party should be OK with ending it. '
      'Let’s wait for everyone to decide.';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActivityWrapper(
      child: IntroScreen(
        showTitle: false,
        simpleLogo: true,
        footer: null,
        footerPadding: false,
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
  Future<void> back(AppData appData) async {
    appData.clearReview();
    final Participant self = await appData.session.getSelf();
    self.quit = false;
    await self.update();
    appData.routeChange = true;
    appData.session.setState(SessionState.search, true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, _) {
        if (appData.session.state == SessionState.ended) {
          return SizedBox.shrink();
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child:
                PlacemapButton(onPressed: () => back(appData), text: 'Go Back'),
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
    final AppData appData = context.read<AppData>();
    final CollectionReference participants =
        appData.session.docRef.collection('participants');

    return StreamBuilder<QuerySnapshot>(
        stream: participants.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();

          final bool allQuit = snapshot.data.docs.firstWhere(
                  (doc) =>
                      !Participant.fromSnapshot(doc, appData.session.docRef)
                          .quit,
                  orElse: () => null) ==
              null;

          if (allQuit) {
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
        });
  }
}
