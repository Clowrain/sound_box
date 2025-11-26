import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sound_box/domain/sounds/white_noise_sound.dart';

/// 管理音效列表排序，支持持久化。
class SoundSelectionState extends ChangeNotifier {
  SoundSelectionState({required List<WhiteNoiseSound> initialOrder})
      : _sounds = List.of(initialOrder) {
    _restoreOrder();
  }

  static const _prefsKey = 'sound_order_ids';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final List<WhiteNoiseSound> _sounds;

  List<WhiteNoiseSound> get sounds => List.unmodifiable(_sounds);

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    if (oldIndex < newIndex) newIndex -= 1;
    final moving = _sounds.removeAt(oldIndex);
    _sounds.insert(newIndex, moving);
    _persistOrder();
    notifyListeners();
  }

  List<WhiteNoiseSound> primary(int count) =>
      _sounds.take(count).toList(growable: false);

  Future<void> _restoreOrder() async {
    final prefs = await _prefs;
    final stored = prefs.getStringList(_prefsKey);
    if (stored == null || stored.isEmpty) return;
    final soundMap = {for (final sound in _sounds) sound.id: sound};
    final restored = <WhiteNoiseSound>[];
    for (final id in stored) {
      final sound = soundMap.remove(id);
      if (sound != null) restored.add(sound);
    }
    // 追加新增未存储的音效，保持兼容。
    restored.addAll(soundMap.values);
    if (restored.isEmpty) return;
    _sounds
      ..clear()
      ..addAll(restored);
    notifyListeners();
  }

  Future<void> _persistOrder() async {
    final prefs = await _prefs;
    await prefs.setStringList(
      _prefsKey,
      _sounds.map((sound) => sound.id).toList(),
    );
  }
}
