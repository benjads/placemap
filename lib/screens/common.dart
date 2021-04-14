import 'package:flutter/material.dart';
import 'package:placemap/models/app_data.dart';
import 'package:provider/provider.dart';

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

    return TextButton(
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.primaryColor,
          textStyle: theme.textTheme.headline4,
          shape: BeveledRectangleBorder(),
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
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 10),
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

    return Consumer<AppData>(
      builder: (context, appData, _) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (int i = 0; i < appData.session.participantCount; i++)
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
                        i == 0 ? 'You' : 'P${i + 1}',
                        style: theme.textTheme.headline6
                            .copyWith(color: theme.colorScheme.primaryVariant),
                      ),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
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
