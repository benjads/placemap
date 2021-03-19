import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/models/session.dart';
import 'package:placemap/speech_service.dart';
import 'package:provider/provider.dart';

class ActivityWrapper extends StatelessWidget {
  final Widget child;

  ActivityWrapper({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AppData>(
      builder: (context, appData, child) {
        if (appData.dirtyScreen) {
          appData.dirtyScreen = false;
         if (appData.session.state != SessionState.ended) {
           Future.microtask(() {
             log('Resolving dirty screen; new state is: ${appData.session.state}');
             final SpeechService speechService = context.read<SpeechService>();
             speechService.stop();
             Navigator.popAndPushNamed(context, appData.session.state.route);
           });
         }
        }

        return Stack(
          children: [
            Positioned.fill(child: child),
            Positioned(
              top: 80,
              left: 20,
              child: Material(
                shape: CircleBorder(),
                color: theme.colorScheme.primaryVariant,
                child: Container(
                  height: 60.0,
                  width: 60.0,
                  child: Center(
                    child: Text(
                      appData.session.participantCount.toString(),
                      style: theme.textTheme.headline4
                          .copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
      child: child,
    );
  }
}
