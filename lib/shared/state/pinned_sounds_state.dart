import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinnedSoundsState extends ChangeNotifier {
  PinnedSoundsState() {
    _restore();
  }

  static const _prefsKey = 'pinned_sound_variant_ids';
  final LinkedHashSet<String> _pinned = LinkedHashSet<String>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<String> get pinnedKeys => List.unmodifiable(_pinned);

  bool isPinned(String key) {
    final normalized = _normalizeKey(key);
    return _pinned.contains(normalized);
  }

  void toggle(String key) {
    final normalized = _normalizeKey(key);
    if (_pinned.contains(normalized)) {
      _pinned.remove(normalized);
    } else {
      _pinned.add(normalized);
    }
    _persist();
    notifyListeners();
  }

  Future<void> _restore() async {
    final prefs = await _prefs;
    final stored = prefs.getStringList(_prefsKey);
    if (stored != null) {
      _pinned
        ..clear()
        ..addAll(stored.map(_normalizeKey));
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await _prefs;
    await prefs.setStringList(_prefsKey, _pinned.toList());
  }

  String _normalizeKey(String key) => key.contains('::') ? key.split('::').first : key;
}
