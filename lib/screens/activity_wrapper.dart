import 'dart:developer';
import 'dart:io';
import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/models/session.dart';
import 'package:placemap/screens/common.dart';
import 'package:placemap/speech_service.dart';
import 'package:placemap/utils.dart';
import 'package:provider/provider.dart';

const int inactivitySeconds = 25;

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
  Stopwatch inactivityStopwatch;

  @override
  void initState() {
    super.initState();
    appData = context.read<AppData>();
    inactivityStopwatch = context.read<Stopwatch>();
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
        if (inactivityStopwatch.elapsed <
            Duration(seconds: inactivitySeconds)) {
          appData.session.setSelfDistracted(true);
          appData.selfDistracted = true;
        }
      } else if (state == AppLifecycleState.resumed) {
        appData.session.setSelfDistracted(false);
        appData.session.setSelCamera(false);
        PlacemapUtils.cancelNotification();
      }
    }
  }

  void closePopup() {
    appData.session.recallImg = null;
    appData.session.recallMsg = null;
    appData.selfDistracted = false;
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
            appData.session.distractedCount() > 0 && !appData.recallAck
                ? RecallMenu()
                : Positioned(
                    top: 40,
                    left: 20,
                    child: Material(
                      shape: CircleBorder(),
                      color: theme.colorScheme.primaryVariant,
                      child: Container(
                        height: 50,
                        width: 50,
                        child: Center(
                          child: Text(
                            (appData.session.participantCount -
                                    appData.session.distractedCount())
                                .toString(),
                            style: theme.textTheme.headline4
                                .copyWith(color: Colors.white, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
            if (appData.selfDistracted &&
                appData.session.recallImg != null &&
                appData.session.recallMsg != null)
              RecallPopup(closePopup),
            if (Platform.isAndroid)
              Positioned(
                  bottom: 60,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      appData.session.setSelCamera(true);
                      PlacemapUtils.openCamera();
                    },
                    child: Material(
                        shape: CircleBorder(),
                        color: theme.colorScheme.secondary.withOpacity(0.5),
                        child: Container(
                            height: 50,
                            width: 50,
                            child: Center(
                                child: Icon(Icons.camera_alt,
                                    color: Colors.white)))),
                  ))
          ],
        );
      },
      child: widget.child,
    );
  }
}

class RecallMenu extends StatelessWidget {
  static final List<String> messages = [
    "Hey! We miss you! Will you come back soon?",
    "I’d like to think I’m more interesting than your phone… Am I?",
    "Unless you’re looking at a 1,000,000 dollar prize, you better "
        "raise your head from your phone and get back to the conversation.",
    "Dining table calling the moon. I repeat. "
        "Dining table calling the moon. Anyone out there?"
  ];

  void sendMessage(AppData appData) {
    final Random rng = Random();
    appData.session.recallImg = 'graphics/recall/meme${rng.nextInt(12)}.jpeg';
    appData.session.recallMsg = messages[rng.nextInt(messages.length)];
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
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
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
                (appData.session.participantCount -
                        appData.session.distractedCount())
                    .toString(),
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
                          appData.recallAck = true;
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

class RecallPopup extends StatelessWidget {
  final VoidCallback closePopup;

  RecallPopup(this.closePopup);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppData appData = context.read<AppData>();

    return Positioned(
      top: 50,
      child: Container(
        height: 310,
        width: 320,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PlaceMap',
                  style: GoogleFonts.nanumBrushScript(
                      textStyle: theme.textTheme.headline3
                          .copyWith(color: Colors.white)),
                ),
                Material(
                  child: IconButton(
                      onPressed: closePopup,
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      )),
                  color: Colors.transparent,
                )
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: Image(image: AssetImage(appData.session.recallImg)),
            ),
            SizedBox(height: 20),
            Text(appData.session.recallMsg,
                style: theme.textTheme.bodyText1.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
