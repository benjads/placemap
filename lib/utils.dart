import 'dart:io';
import 'dart:math';

import 'package:device_info/device_info.dart';

class PlacemapUtils {
  static DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

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
