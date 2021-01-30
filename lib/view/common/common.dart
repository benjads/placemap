import 'package:flutter/material.dart';

class PlacemapButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  PlacemapButton({@required this.onPressed, @required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
        style: TextButton.styleFrom(
          primary: theme.textTheme.bodyText1.color,
          backgroundColor: theme.primaryColor,
          textStyle: theme.textTheme.headline4,
          shape: BeveledRectangleBorder(),
        ),
        onPressed: onPressed,
        child: Text(
          text.toUpperCase(),
        ));
  }
}
