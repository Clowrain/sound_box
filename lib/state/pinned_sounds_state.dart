import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinnedSoundsState extends ChangeNotifier {
  PinnedSoundsState() {
    _restore();
  }

  static const _prefsKey = 'pinned_sound_variant_ids';
  final LinkedHashSet<String> _pinned = LinkedHashSet<String>();

  List<String> get pinnedKeys => List.unmodifiable(_pinned);

  bool isPinned(String key) => _pinned.contains(key);

  void toggle(String key) {
    if (_pinned.contains(key)) {
      _pinned.remove(key);
    } else {
      _pinned.add(key);
    }
    _persist();
    notifyListeners();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_prefsKey);
    if (stored != null) {
      _pinned
        ..clear()
        ..addAll(stored);
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _pinned.toList());
  }
}
