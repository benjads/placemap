import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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

// class MainFlow extends StatefulWidget {
//   _MainFlowState createState() => _MainFlowState();
// }
//
// class _MainFlowState extends State<MainFlow> {
//   Session _session;
//
//   @override
//   void initState() {
//     super.initState();
//     SessionRepo().createSession().then((session) => _setSession(session));
//   }
//
//   void _setSession(Session session) {
//     setState(() {
//       _session = session;
//     });
//   }
//
//   Widget _loading() {
//     return SafeArea(
//       child: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
//
//   Widget _stateWidget() {
//     switch (_session.state) {
//       case SessionState.waiting:
//         return LandingScreen();
//       case SessionState.inGame:
//         // TODO: Handle this case.
//         break;
//     }
//
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_session == null) {
//       return _loading();
//     }
//
//     return StreamBuilder<DocumentSnapshot>(
//       stream: _session.docRef.snapshots(),
//       builder:
//           (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//         if (snapshot.hasError) {
//           return Text('Error....');
//         }
//
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return _loading();
//         }
//
//         return Provider<Session>(
//           create: (_) => Session.fromSnapshot(snapshot.data),
//           child: _stateWidget(),
//         );
//       },
//     );
//   }
// }
