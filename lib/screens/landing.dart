import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/screens/common.dart';
import 'package:placemap/screens/intro.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appData = context.read<AppData>();
    _cacheAssets(context, appData);

    return IntroScreen(
      showTitle: true,
      footer: null,
      content: Column(
        children: [
          PlacemapButton(
              onPressed: () => Navigator.pushNamed(context, '/join'),
              text: 'Start'),
          SizedBox(height: 30),
          PlacemapButton(
              onPressed: () => Navigator.pushNamed(context, '/about'),
              text: 'About'),
        ],
      ),
    );
  }

  void _cacheAssets(BuildContext context, AppData appData) {
    if (appData.cachedAssets)
      return;

    Future.microtask(() {
      GoogleFonts.nanumBrushScript();
      appData.cachedAssets = true;
    });
  }
}
