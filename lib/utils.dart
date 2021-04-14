import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';

import 'package:device_info/device_info.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PlacemapUtils {
  static DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

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
        importance: Importance.max,
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
    if (Platform.isAndroid) {
      return (await _deviceInfoPlugin.androidInfo).id;
    } else if (Platform.isIOS) {
      return (await _deviceInfoPlugin.iosInfo).identifierForVendor;
    }

    return null;
  }

  static const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static final Random _rnd = Random();
  static String getSessionCode() => String.fromCharCodes(Iterable.generate(
      5, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}
