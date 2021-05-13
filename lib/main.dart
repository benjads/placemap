import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:placemap/models/app_data.dart';
import 'package:placemap/models/preferences.dart';
import 'package:placemap/screens/about.dart';
import 'package:placemap/screens/exit.dart';
import 'package:placemap/screens/join.dart';
import 'package:placemap/screens/landing.dart';
import 'package:placemap/screens/pause.dart';
import 'package:placemap/screens/review.dart';
import 'package:placemap/screens/search.dart';
import 'package:placemap/screens/tradition_overview.dart';
import 'package:placemap/screens/tutorial.dart';
import 'package:placemap/screens/wait.dart';
import 'package:placemap/speech_service.dart';
import 'package:placemap/theme.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(PlacemapApp());
}

class PlacemapApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error...'),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<Preferences>(create: (_) => Preferences()),
              ChangeNotifierProvider<AppData>(create: (_) => AppData()),
              Provider<SpeechService>(create: (_) => SpeechService()),
            ],
            child: MaterialApp(
              title: 'Placemap',
              theme: appTheme,
              initialRoute: '/',
              onGenerateRoute: (RouteSettings settings) {
                return PageRouteBuilder(
                  pageBuilder: (_, __, ___) {
                    switch (settings.name) {
                      case '/':
                        return LandingScreen();
                      case '/about':
                        return AboutScreen();
                      case '/join':
                        return JoinScreen();
                      case '/join/wait':
                        return WaitScreen();
                      case '/tutorial/1':
                        return Tutorial1();
                      case '/tutorial/2':
                        return Tutorial2();
                      case '/tutorial/3':
                        return Tutorial3();
                      case '/tutorial/4':
                        return Tutorial4();
                      case '/tutorial/5':
                        return Tutorial5();
                      case '/tutorial/6':
                        return Tutorial6();
                      case '/tutorial/end':
                        return TutorialScreen.end();
                      case '/tradition':
                        return TraditionView();
                      case '/review':
                        return ReviewScreen();
                      case '/search':
                        return SearchScreen();
                      case '/pause':
                        return PauseScreen();
                      case '/exit':
                        return ExitScreen();
                    }

                    return null;
                  },
                  transitionDuration: Duration(seconds: 0),
                );
              },
            ),
          );
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
