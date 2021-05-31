import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/screens/common.dart';
import 'package:placemap/screens/intro.dart';
import 'package:placemap/utils.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _loading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final appData = context.read<AppData>();
    _cacheAssets(context, appData);

    return IntroScreen(
      showTitle: true,
      loading: _loading,
      footer: null,
      scaffoldKey: _scaffoldKey,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlacemapButton(
              onPressed: () async {
                setState(() {
                  _loading = true;
                });
                PlacemapUtils.firestoreOp(
                    _scaffoldKey,
                    () => appData.createSession(),
                    () => Navigator.pushNamed(context, '/join'));
              },
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
    if (appData.cachedAssets) return;

    Future.microtask(() {
      GoogleFonts.nanumBrushScript();
      appData.cachedAssets = true;
    });
  }
}
