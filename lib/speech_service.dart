import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {

  final FlutterTts _tts = FlutterTts();
  bool _playing = false;

  SpeechService() {
    _tts.setStartHandler(() => _playing = true);
    _tts.setCompletionHandler(() => _playing = false);
    _tts.setCancelHandler(() => _playing = false);
    _tts.setErrorHandler((_) => _playing = false);
  }

  void speak(String message) {
    if (_playing)
      return;

    _tts.speak(message);
  }
}