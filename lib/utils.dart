import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:device_info/device_info.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PlacemapUtils {
  static DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  static String _deviceId = 'device-' + DateTime.now().millisecondsSinceEpoch.toString();

  static String get cachedDeviceId => _deviceId;

  static FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static void initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    notifications.initialize(initializationSettings);
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        'PlaceMap', 'PlaceMap Meal', 'PlaceMap Mealtime Notifications',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await notifications.show(
        0, title, body, platformChannelSpecifics,
        payload: body);
  }

  static Future<void> cancelNotification() {
    return notifications.cancel(0);
  }

  static const platform = const MethodChannel('edu.ucsc.setlab.placemap/native');

  static Future<void> openCamera() async {
    if (Platform.isAndroid) {
      await platform.invokeMethod('openCamera');
    }
  }


  static Map<String, dynamic> toMap(Map<dynamic, dynamic> data) {
    return Map<String, dynamic>.from(data);
  }

  static Map<String, int> toStringIntMap(Map<dynamic, dynamic> data) {
    return Map<String, int>.from(data);
  }

  static List<String> toStringList(List<dynamic> data) {
    return List<String>.from(data);
  }

  static Future<String> currentDeviceId() async {
    if (_deviceId != null && !_deviceId.startsWith('device'))
      return _deviceId;

    if (Platform.isAndroid) {
      _deviceId = (await _deviceInfoPlugin.androidInfo).id;
      return _deviceId;
    } else if (Platform.isIOS) {
      _deviceId = (await _deviceInfoPlugin.iosInfo).identifierForVendor;
      return _deviceId;
    }

    return null;
  }

  static const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static final Random _rnd = Random();
  static String getSessionCode() => String.fromCharCodes(Iterable.generate(
      5, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  static Future<void> firestoreOp(GlobalKey<ScaffoldState> scaffoldKey, Future Function() op, VoidCallback onSuccess) async {
    try {
      await op.call();
    } on FirebaseException {
      scaffoldKey.currentState.showSnackBar(SnackBar(
          content:
          Text('Unable to connect! Is your device offline?')));
      return;
    }
    onSuccess?.call();
  }
}
