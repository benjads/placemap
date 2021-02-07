import 'package:flutter/material.dart';

class IntroScreen extends StatelessWidget {
  final bool showTitle;
  final Widget footer;
  final Widget content;

  IntroScreen({this.showTitle = true, this.footer, @required this.content});

  Widget _title() => Container(
        padding: EdgeInsets.fromLTRB(0, 40, 0, 100),
        child: SizedBox(
          height: 80,
          child: Image(
            image: AssetImage('graphics/placemap_logo.png'),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        padding: EdgeInsets.only(top: 40),
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.primaryColor,
            Color.fromRGBO(5, 56, 79, 1),
          ],
        )),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  if (showTitle) _title(),
                  content
                ],
              ),
            ),
            footer == null
                ? Positioned(
                    height: 450,
                    bottom: -300,
                    child: Image(
                      image: AssetImage('graphics/globe.png'),
                    ),
                  )
                : Positioned(
                    bottom: 0,
                    child: footer,
                  )
          ],
        ),
      ),
    );
  }
}
