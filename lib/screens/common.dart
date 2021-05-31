import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:placemap/models/app_data.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PlacemapButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color textColor;
  final Color backgroundColor;

  const PlacemapButton(
      {Key key,
      @required this.onPressed,
      @required this.text,
      this.textColor,
      this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: backgroundColor ?? theme.primaryColor,
          textStyle: theme.textTheme.headline4,
        ),
        onPressed: onPressed,
        child: Text(
          text.toUpperCase(),
          style: theme.textTheme.headline5
              .copyWith(color: textColor ?? theme.textTheme.bodyText1.color),
          textAlign: TextAlign.center,
        ));
  }
}

class DividerText extends StatelessWidget {
  final String text;

  DividerText({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 35, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Divider(
              thickness: 2,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          if (text != null)
            Flexible(
                child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                text,
                style: theme.textTheme.bodyText1,
              ),
            )),
          Flexible(
            child: Divider(
              thickness: 2,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class ParticipantBubbles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppData appData = context.read<AppData>();
    final CollectionReference participants =
        appData.session.docRef.collection('participants');

    return StreamBuilder<QuerySnapshot>(
        stream: participants.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return SizedBox(
              height: 50,
              width: 0,
            );

          final int participantCount = snapshot.data.size;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                for (int i = 0; i < min(5, participantCount); i++)
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Material(
                      shape: CircleBorder(),
                      color: theme.colorScheme.onPrimary,
                      child: Container(
                        height: 50,
                        width: 50,
                        child: Center(
                          child: Text(
                            i == 0
                                ? 'You'
                                : (participantCount > 5 && i == 5
                                    ? '...'
                                    : 'P${i + 1}'),
                            style: theme.textTheme.headline6.copyWith(
                                color: theme.colorScheme.primaryVariant),
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          );
        });
  }
}

class StrokeText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color color;
  final Color strokeColor;
  final double strokeWidth;

  const StrokeText(
    this.text, {
    Key key,
    @required this.style,
    @required this.color,
    @required this.strokeColor,
    @required this.strokeWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: style.fontSize,
            fontWeight: style.fontWeight,
            foreground: Paint()..color = color,
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: style.fontSize,
            fontWeight: style.fontWeight,
            foreground: Paint()
              ..strokeWidth = strokeWidth
              ..color = strokeColor
              ..style = PaintingStyle.stroke,
          ),
        ),
      ],
    );
  }
}

class VideoControlsOverlay extends StatefulWidget {
  const VideoControlsOverlay({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  _VideoControlsOverlayState createState() => _VideoControlsOverlayState();
}

class _VideoControlsOverlayState extends State<VideoControlsOverlay> {
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        if (!_started)
          Container(
            color: Colors.black26,
            child: Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 100.0,
              ),
            ),
          ),
        GestureDetector(
          onTap: () {
            if (!_started)
              setState(() {
                _started = true;
              });

            widget.controller.value.isPlaying
                ? widget.controller.pause()
                : widget.controller.play();
          },
        ),
      ],
    );
  }
}

class RestartWidget extends StatefulWidget {
  RestartWidget({this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>().restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
