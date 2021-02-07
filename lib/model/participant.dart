class Participant {
  final String deviceId;

  Participant.fromMap(Map<String, dynamic> map)
      : assert(map['deviceId'] != null),
        deviceId = map['deviceId'];

  Participant.initialize(this.deviceId);

  Map<String, dynamic> get map => {
        'deviceId': deviceId,
      };
}
