import 'package:flutter/material.dart';
import 'package:sound_box/app.dart';
import 'package:sound_box/data/sounds/sound_presets.dart';
import 'package:sound_box/shared/audio/sound_track_pool.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SoundTrackPool.instance.restorePreferredVolumes();
  final sounds = await loadWhiteNoiseSounds();
  runApp(SoundBoxApp(initialSounds: sounds));
}
