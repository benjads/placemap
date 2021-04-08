import 'dart:developer';
import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/models/session.dart';
import 'package:placemap/screens/common.dart';
import 'package:placemap/speech_service.dart';
import 'package:placemap/utils.dart';
import 'package:provider/provider.dart';

class ActivityWrapper extends StatefulWidget {
  final Widget child;

  ActivityWrapper({Key key, this.child}) : super(key: key);

  @override
  _ActivityWrapperState createState() => _ActivityWrapperState();
}

class _ActivityWrapperState extends State<ActivityWrapper>
    with WidgetsBindingObserver {
  AppLifecycleState _currentState;
  AppData appData;

  @override
  void initState() {
    super.initState();
    appData = context.read<AppData>();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state != _currentState) {
      _currentState = state;

      if (state == AppLifecycleState.paused) {
        appData.session.setSelfDistracted(true);
      } else if (state == AppLifecycleState.resumed) {
        appData.session.setSelfDistracted(false);
        appData.session.recallMsg = null;
        PlacemapUtils.cancelNotification();
      }
    }
  }

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
          alignment: Alignment.topCenter,
          children: [
            Positioned.fill(child: child),
            appData.session.defector() && !appData.recallAck
                ? RecallMenu()
                : Positioned(
                    top: 40,
                    left: 20,
                    child: Material(
                      shape: CircleBorder(),
                      color: theme.colorScheme.primaryVariant,
                      child: Container(
                        height: 50.0,
                        width: 50.0,
                        child: Center(
                          child: Text(
                            appData.session.participantCount.toString(),
                            style: theme.textTheme.headline4
                                .copyWith(color: Colors.white, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  )
          ],
        );
      },
      child: widget.child,
    );
  }
}

class RecallMenu extends StatelessWidget {

  static final List<String> messages = [
    "You'll miss out!"
  ];

  void sendMessage(AppData appData) {
    final choice = Random().nextInt(messages.length);
    appData.session.recallMsg = messages[choice];
    appData.session.update();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppData appData = context.read<AppData>();

    return Positioned(
        top: 50,
        child: Container(
          height: 220,
          width: 320,
          padding:
          EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          decoration: BoxDecoration(
              color: theme.colorScheme.error,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.zero,
                bottomLeft: Radius.zero,
                topLeft: Radius.circular(20),
              )),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (appData.session.participantCount - 1).toString(),
                style: theme.textTheme.headline4
                    .copyWith(color: Colors.white, height: 1.5),
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Someone closed the app how would like to respond?'
                            .toUpperCase(),
                        style: theme.textTheme.bodyText1.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      PlacemapButton(
                        onPressed: () {
                          appData.recallAck = true;
                        },
                        text: 'Ignore',
                        textColor: Colors.white,
                        backgroundColor: theme.colorScheme.onError,
                      ),
                      SizedBox(height: 10),
                      PlacemapButton(
                        onPressed: () {
                          sendMessage(appData);
                        },
                        text: 'Send a Message',
                        textColor: Colors.white,
                        backgroundColor: theme.colorScheme.onError,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

}