import 'package:flutter/foundation.dart';
import 'package:sound_box/models/white_noise_sound.dart';

class SoundSelectionState extends ChangeNotifier {
  SoundSelectionState({required List<WhiteNoiseSound> initialOrder})
    : _sounds = List.of(initialOrder);

  final List<WhiteNoiseSound> _sounds;

  List<WhiteNoiseSound> get sounds => List.unmodifiable(_sounds);

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    if (oldIndex < newIndex) newIndex -= 1;
    final moving = _sounds.removeAt(oldIndex);
    _sounds.insert(newIndex, moving);
    notifyListeners();
  }

  List<WhiteNoiseSound> primary(int count) =>
      _sounds.take(count).toList(growable: false);
}
