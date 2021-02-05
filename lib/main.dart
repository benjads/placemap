import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:placemap/repo/session_repo.dart';
import 'package:placemap/view/landing.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(PlacemapApp());
}

class PlacemapApp extends StatelessWidget {

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container();
          // TODO
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Placemap',
            theme: ThemeData(
              primaryColor: Color.fromRGBO(0, 113, 188, 1),
              textTheme: TextTheme(
                headline1: TextStyle(),
                headline2: TextStyle(),
                headline3: TextStyle(),
                headline4: TextStyle(),
                headline5: TextStyle(),
                headline6: TextStyle(),
                bodyText1: TextStyle(),
              ).apply(
                bodyColor: Color.fromRGBO(163, 237, 244, 1),
                displayColor: Color.fromRGBO(163, 237, 244, 1),
              ),
              buttonTheme: ButtonThemeData(
                buttonColor: Color.fromRGBO(0, 113, 188, 1),
              ),
              fontFamily: 'Vinson',
            ),
            home: FutureProvider(
              create: (_) async => SessionRepo().createSession(),
              lazy: true,
              child: LandingScreen(),
            ),
          );
        }

        return Container();
        // TODO
      },
    );
  }
}