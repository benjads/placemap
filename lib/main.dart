import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:placemap/theme.dart';
import 'package:placemap/view/landing.dart';

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
          return Center(
            child: Text('Error...'),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Placemap',
            theme: appTheme,
            home: LandingScreen(),
          );
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
