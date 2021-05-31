import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' show Random;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/models/session.dart';
import 'package:placemap/models/participant.dart';
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
  StreamSubscription<DocumentSnapshot> selfStream;

  @override
  void initState() {
    super.initState();
    appData = context.read<AppData>();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (appData.session.state == SessionState.tutorial) return;

    if (state != _currentState) {
      _currentState = state;
      appData.session.getSelf().then((self) {
        if (state == AppLifecycleState.paused ||
            state == AppLifecycleState.inactive) {
          self.distracted = true;
          if (selfStream == null) {
            selfStream = self.docRef.snapshots().listen((doc) {
              log('Background participant update received');
              final Participant participant =
              Participant.fromSnapshot(doc, appData.session.docRef);
              if (participant.distracted && participant.recallMsg != null) {
                log('Sending push notification');
                PlacemapUtils.showNotification(
                    'Hey, come back!', self.recallMsg);
              }
            });
          }
        } else if (state == AppLifecycleState.resumed) {
          self.distracted = false;
          self.camera = false;
          selfStream?.cancel();
          selfStream = null;
        }
        self.update();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            ParticipantBubble(),
          ],
        );
      },
      child: widget.child,
    );
  }
}

class ParticipantBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppData appData = context.watch<AppData>();
    final CollectionReference participants =
        appData.session.docRef.collection('participants');

    int participantCount = 0;
    List<Participant> distracted = [];

    return StreamBuilder<QuerySnapshot>(
        stream: participants.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          log('Updated participant data received from the remote');

          Participant self;
          if (snapshot.hasData) {
            final data = snapshot.data;
            participantCount = data.size;
            distracted = [];

            data.docs.forEach((doc) {
              final Participant participant =
                  Participant.fromSnapshot(doc, appData.session.docRef);
              if (participant.deviceId == PlacemapUtils.cachedDeviceId)
                self = participant;

              if (participant.distracted && !participant.camera ||
                  participant.recallMsg != null) distracted.add(participant);
            });

            if (distracted.length == 0 && appData.recallAck)
              Future.microtask(() => appData.recallAck = false);
          }

          return Stack(
            alignment: Alignment.topCenter,
            children: [
              (distracted.length > 0 &&
                          !appData.recallAck &&
                          !self.distracted) ||
                      appData.demoRecallMenu
                  ? RecallMenu(participantCount, distracted)
                  : Positioned(
                      top: 40,
                      left: 20,
                      child: Material(
                        shape: CircleBorder(),
                        color: appData.demoDecrease
                            ? theme.colorScheme.error
                            : theme.colorScheme.primaryVariant,
                        child: Container(
                          height: 50,
                          width: 50,
                          child: Center(
                            child: Text(
                              participantCount == 0
                                  ? ''
                                  : (participantCount -
                                          distracted.length -
                                          (appData.demoDecrease ? 1 : 0))
                                      .toString(),
                              style: theme.textTheme.headline4
                                  .copyWith(color: Colors.white, height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
              if ((self?.recallImg != null && self?.recallMsg != null) ||
                  appData.demoRecallPopup)
                if (self != null) RecallPopup(self),
              if (Platform.isAndroid)
                Positioned(
                    bottom: 60,
                    right: 20,
                    child: GestureDetector(
                      onTap: () {
                        self.camera = true;
                        self.update();
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
        });
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

  final int participantCount;
  final List<Participant> distracted;

  RecallMenu(this.participantCount, this.distracted);

  void sendMessage(AppData appData) {
    final Random rng = Random();
    for (final participant in distracted) {
      if (participant.recallMsg != null || participant.recallImg != null)
        continue;

      participant.recallImg = 'graphics/recall/meme${rng.nextInt(12) + 1}.jpeg';
      participant.recallMsg = messages[rng.nextInt(messages.length)];
      participant.update();
    }
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
              participantCount == 0
                  ? SizedBox(width: 15, height: 20)
                  : Text(
                      (participantCount -
                              distracted.length -
                              (appData.demoDecrease ? 1 : 0))
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
                          if (appData.demoRecallMenu) return;

                          appData.recallAck = true;
                        },
                        text: 'Ignore',
                        textColor: Colors.white,
                        backgroundColor: theme.colorScheme.onError,
                      ),
                      SizedBox(height: 10),
                      PlacemapButton(
                        onPressed: () {
                          if (appData.demoRecallMenu) return;

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
  static const demoRecall =
      "Hey! Shouldn't you get back to your shared mealtime experience?";

  final Participant self;

  RecallPopup(this.self);

  void closePopup(AppData appData, Participant self) {
    self.recallImg = null;
    self.recallMsg = null;
    self.update();
    PlacemapUtils.cancelNotification();
  }

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
                if (!appData.demoRecallPopup)
                  Material(
                    child: IconButton(
                        onPressed: () => closePopup(appData, self),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                        )),
                    color: Colors.transparent,
                  ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: Image(
                  image: AssetImage(
                      self.recallImg ?? 'graphics/recall/meme1.jpeg')),
            ),
            SizedBox(height: 20),
            Text(self.recallMsg ?? demoRecall,
                style: theme.textTheme.bodyText1.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
