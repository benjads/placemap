import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroScreen extends StatelessWidget {
  final bool showTitle;
  final bool simpleLogo;
  final bool footerPadding;
  final Widget footer;
  final Widget content;

  const IntroScreen(
      {Key key,
      this.showTitle = true,
      this.simpleLogo = false,
      this.footer,
      this.footerPadding = true,
      @required this.content})
      : super(key: key);

  Widget _title() => Container(
        padding: EdgeInsets.fromLTRB(0, 40, 0, 60),
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
        padding: EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.colorScheme.primary, theme.colorScheme.primaryVariant],
        )),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            footer == null
                ? Positioned(
                    height: 450,
                    bottom: -200,
                    child: Image(
                      image: AssetImage('graphics/globe.png'),
                    ),
                  )
                : Positioned(
                    bottom: 0,
                    child: footer,
                  ),
            Positioned.fill(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: footer == null && footerPadding ? 200 : 0,
                    top: simpleLogo ? 70 : 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (showTitle) _title(),
                    Expanded(
                        child: Align(
                      alignment: Alignment.center,
                      child: content,
                    )),
                  ],
                ),
              ),
            ),
            if (simpleLogo)
              Positioned(
                top: 20,
                child: Text(
                  'PlaceMap',
                  style: GoogleFonts.nanumBrushScript(
                      textStyle: theme.textTheme.headline3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
