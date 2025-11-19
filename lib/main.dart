import 'package:flutter/material.dart';
import 'package:sound_box/app.dart';
import 'package:sound_box/data/sound_presets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sounds = await loadWhiteNoiseSounds();
  runApp(SoundBoxApp(initialSounds: sounds));
}
