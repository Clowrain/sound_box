import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 简易的音轨池，最多同时播放 [maxTracks] 条音轨。
class SoundTrackPool {
  SoundTrackPool._internal() : maxTracks = 10;

  static final SoundTrackPool instance = SoundTrackPool._internal();

  final int maxTracks;
  final Map<String, _Track> _tracks = {};
  final Map<String, double> _preferredVolumes = {};
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<void>? _restoreFuture;

  static const _prefsKey = 'preferred_sound_volumes';

  /// 切换音轨播放/暂停，如果池已满且没有空闲轨道则直接返回。
  Future<void> toggleTrack({
    required String key,
    required String path,
    required double volume,
    bool loop = true,
  }) async {
    if (path.isEmpty) return;

    await restorePreferredVolumes();
    setPreferredVolume(key, volume);
    final existing = _tracks[key];
    if (existing != null) {
      existing.enabled = !existing.enabled;
      existing.lastUsed = DateTime.now();
      if (existing.enabled) {
        existing.volume = _preferredVolumes[key]!;
        await existing.player.setVolume(existing.volume);
        await existing.player.resume();
      } else {
        await existing.player.pause();
      }
      return;
    }

    if (_tracks.length >= maxTracks) {
      final evictedKey = _evictCandidateKey();
      if (evictedKey == null) return;
      await _disposeTrack(evictedKey);
    }

    final player = AudioPlayer();
    await player.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
    // 便于排查音频路径问题。
    // ignore: avoid_print
    print(
      '[SoundTrackPool] play key=$key path=$path volume=${_preferredVolumes[key]}',
    );
    await player.setSource(AssetSource(path, mimeType: 'audio/mp3'));
    final clampedVolume = _preferredVolumes[key]!;
    await player.setVolume(clampedVolume);
    await player.resume();

    _tracks[key] = _Track(
      player: player,
      path: path,
      volume: clampedVolume,
      enabled: true,
      lastUsed: DateTime.now(),
    );
  }

  /// 仅调整音量，不改变播放状态。
  Future<void> setVolume(String key, double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    _setPreferredVolumeInMemory(key, clamped);
    final track = _tracks[key];
    if (track == null) return;
    track.volume = clamped;
    if (track.enabled) {
      await track.player.setVolume(clamped);
    }
  }

  /// 获取预设音量，默认 0.6。
  double preferredVolume(String key) => _preferredVolumes[key] ?? 0.6;

  /// 仅记录预设音量，不触发播放器。
  void setPreferredVolume(String key, double volume) {
    _setPreferredVolumeInMemory(key, volume);
    _persistPreferredVolumes();
  }

  /// 当前是否正在播放。
  bool isPlaying(String key) => _tracks[key]?.enabled ?? false;

  /// 停止并释放所有轨道。
  Future<void> dispose() async {
    for (final entry in _tracks.entries) {
      await entry.value.player.dispose();
    }
    _tracks.clear();
  }

  String? _evictCandidateKey() {
    // 优先选择已停用的轨道，其次选最久未使用的。
    final disabled = _tracks.entries
        .where((entry) => entry.value.enabled == false)
        .toList(growable: false);
    if (disabled.isNotEmpty) {
      disabled.sort((a, b) => a.value.lastUsed.compareTo(b.value.lastUsed));
      return disabled.first.key;
    }
    if (_tracks.isEmpty) return null;
    return _tracks.entries
        .reduce(
          (prev, curr) =>
              prev.value.lastUsed.isBefore(curr.value.lastUsed) ? prev : curr,
        )
        .key;
  }

  Future<void> _disposeTrack(String key) async {
    final track = _tracks.remove(key);
    if (track == null) return;
    await track.player.stop();
    await track.player.dispose();
  }

  /// 启动时恢复上次的音量偏好。
  Future<void> restorePreferredVolumes() {
    _restoreFuture ??= _restorePreferredVolumes();
    return _restoreFuture!;
  }

  Future<void> _restorePreferredVolumes() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        for (final entry in decoded.entries) {
          final value = entry.value;
          if (value is num) {
            _preferredVolumes[entry.key] = value.toDouble().clamp(0.0, 1.0);
          }
        }
      }
    } catch (_) {
      // ignore parse errors
    }
  }

  void _setPreferredVolumeInMemory(String key, double volume) {
    _preferredVolumes[key] = volume.clamp(0.0, 1.0);
  }

  Future<void> _persistPreferredVolumes() async {
    final prefs = await _prefs;
    await prefs.setString(_prefsKey, jsonEncode(_preferredVolumes));
  }
}

class _Track {
  _Track({
    required this.player,
    required this.path,
    required this.volume,
    required this.enabled,
    required this.lastUsed,
  });

  final AudioPlayer player;
  final String path;
  double volume;
  bool enabled;
  DateTime lastUsed;
}
