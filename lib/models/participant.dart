class Participant {
  final String deviceId;
  bool tutorialComplete = false;
  bool quit = false;
  bool camera = false;
  bool distracted = false;

  Participant.fromMap(Map<String, dynamic> map)
      : assert(map['deviceId'] != null),
        deviceId = map['deviceId'],
        tutorialComplete = map['tutorialComplete'],
        quit = map['quit'],
        camera = map['camera'],
        distracted = map['distracted'];

  Participant.initialize(this.deviceId);

  Map<String, dynamic> get map => {
        'deviceId': deviceId,
        'tutorialComplete': tutorialComplete,
        'quit': quit,
        'camera': camera,
        'distracted': distracted
      };
}
