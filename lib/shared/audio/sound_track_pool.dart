import 'dart:convert';
import 'dart:developer'; // log()

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 简易的音轨池（just_audio 版本）
/// - 最多同时存在 [maxTracks] 条 AudioPlayer 实例
/// - 使用 key + path + volume 管理音轨
/// - 支持：toggleTrack / setVolume / isPlaying / dispose
/// - 使用 audio_session 做音频会话配置
class SoundTrackPool {
  SoundTrackPool._internal() : maxTracks = 10;

  static final SoundTrackPool instance = SoundTrackPool._internal();

  final int maxTracks;

  /// 空闲超过这个时间且未启用的轨道会被自动清理
  static const Duration idleTimeout = Duration(minutes: 5);

  final Map<String, _Track> _tracks = {};
  final Map<String, double> _preferredVolumes = {};
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<void>? _restoreFuture;

  bool _audioSessionInitialized = false;
  bool _disposed = false;

  static const _prefsKey = 'preferred_sound_volumes';

  Future<void> toggleTrack({
    required String key,
    required String path,
    required double volume,
    bool loop = true,
  }) async {
    if (_disposed) {
      log('[SoundTrackPool] toggleTrack ignored, pool disposed. key=$key');
      return;
    }
    if (path.isEmpty) {
      log('[SoundTrackPool] toggleTrack ignored, empty path. key=$key');
      return;
    }

    await _initAudioSessionIfNeeded();
    await restorePreferredVolumes();

    setPreferredVolume(key, volume);
    final now = DateTime.now();

    await _cleanupIdleTracks(now);

    final existing = _tracks[key];

    log(
      '[SoundTrackPool] toggleTrack: key=$key '
      'path=$path volume=${_preferredVolumes[key]} '
      'hasExisting=${existing != null}',
    );

    // ===== 已有轨道 =====
    if (existing != null) {
      log(
        '[SoundTrackPool] toggleTrack(existing): '
        'before enabled=${existing.enabled} '
        'player.playing=${existing.player.playing} '
        'track.path=${existing.path}',
      );

      existing.enabled = !existing.enabled;
      existing.lastUsed = now;

      try {
        if (existing.enabled) {
          if (existing.path != path) {
            log(
              '[SoundTrackPool] existing path changed: '
              '${existing.path} -> $path, reload source',
            );
            existing.path = path;
            existing.sourcePrepared = false;
          }

          if (!existing.sourcePrepared) {
            log(
              '[SoundTrackPool] existing setAudioSource: key=$key path=${existing.path}',
            );
            await existing.player.setAudioSource(
              AudioSource.asset(existing.path),
            );
            await existing.player.setLoopMode(
              loop ? LoopMode.one : LoopMode.off,
            );
            existing.sourcePrepared = true;
          }

          existing.volume = _preferredVolumes[key]!;
          log(
            '[SoundTrackPool] existing play: key=$key volume=${existing.volume} loop=$loop',
          );

          await existing.player.setVolume(existing.volume);
          existing.player.play(); // 不 await
        } else {
          log('[SoundTrackPool] existing pause: key=$key');
          await existing.player.pause();
        }
      } catch (e, st) {
        log(
          '[SoundTrackPool] ERROR in toggleTrack(existing): key=$key error=$e\n$st',
        );
      }

      log(
        '[SoundTrackPool] toggleTrack(existing) done: '
        'enabled=${existing.enabled} player.playing=${existing.player.playing}',
      );
      return;
    }

    // ===== 新轨道 =====

    if (_tracks.length >= maxTracks) {
      final evictedKey = _evictCandidateKey(now);
      log(
        '[SoundTrackPool] pool full: size=${_tracks.length}, evictCandidate=$evictedKey',
      );
      if (evictedKey == null) return;
      await _disposeTrack(evictedKey);
    }

    final player = AudioPlayer();

    log(
      '[SoundTrackPool] create new track: key=$key path=$path volume=${_preferredVolumes[key]} loop=$loop',
    );

    try {
      await player.setAudioSource(AudioSource.asset(path));
      await player.setLoopMode(loop ? LoopMode.one : LoopMode.off);

      final clampedVolume = _preferredVolumes[key]!;
      await player.setVolume(clampedVolume);
      player.play(); // 不 await

      _tracks[key] = _Track(
        player: player,
        path: path,
        volume: clampedVolume,
        enabled: true,
        lastUsed: now,
        sourcePrepared: true,
      );

      log(
        '[SoundTrackPool] new track started: key=$key player.playing=${player.playing}',
      );
    } catch (e, st) {
      log(
        '[SoundTrackPool] ERROR create new track: key=$key path=$path error=$e\n$st',
      );
      await player.dispose();
    }
  }

  /// 音量调整，不改变播放状态
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

  double preferredVolume(String key) => _preferredVolumes[key] ?? 0.6;

  void setPreferredVolume(String key, double volume) {
    _setPreferredVolumeInMemory(key, volume);
    _persistPreferredVolumes();
  }

  bool isPlaying(String key) => _tracks[key]?.enabled ?? false;

  Future<void> dispose() async {
    _disposed = true;
    for (final entry in _tracks.entries) {
      await entry.value.player.dispose();
    }
    _tracks.clear();
  }

  Future<void> stop(String key) async {
    final track = _tracks[key];
    if (track == null) return;
    track.enabled = false;
    track.lastUsed = DateTime.now();
    await track.player.stop();
  }

  Future<void> pauseAll() async {
    final now = DateTime.now();
    for (final entry in _tracks.entries) {
      final track = entry.value;
      if (track.enabled) {
        track.lastUsed = now;
        await track.player.pause();
      }
    }
  }

  Future<void> resumeAll({bool loop = true}) async {
    final now = DateTime.now();
    for (final entry in _tracks.entries) {
      final track = entry.value;
      if (track.enabled) {
        track.lastUsed = now;

        if (!track.sourcePrepared) {
          await track.player.setAudioSource(AudioSource.asset(track.path));
          await track.player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
          track.sourcePrepared = true;
        }

        track.player.play();
      }
    }
  }

  String? _evictCandidateKey(DateTime now) {
    if (_tracks.isEmpty) return null;

    final disabled = _tracks.entries
        .where((e) => e.value.enabled == false)
        .toList();
    if (disabled.isNotEmpty) {
      disabled.sort((a, b) => a.value.lastUsed.compareTo(b.value.lastUsed));
      return disabled.first.key;
    }

    return _tracks.entries.reduce((prev, curr) {
      return prev.value.lastUsed.isBefore(curr.value.lastUsed) ? prev : curr;
    }).key;
  }

  Future<void> _disposeTrack(String key) async {
    final track = _tracks.remove(key);
    if (track == null) return;
    await track.player.stop();
    await track.player.dispose();
  }

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
    } catch (_) {}
  }

  void _setPreferredVolumeInMemory(String key, double volume) {
    _preferredVolumes[key] = volume.clamp(0.0, 1.0);
  }

  Future<void> _persistPreferredVolumes() async {
    final prefs = await _prefs;
    await prefs.setString(_prefsKey, jsonEncode(_preferredVolumes));
  }

  Future<void> _cleanupIdleTracks(DateTime now) async {
    if (_tracks.isEmpty) return;

    final toRemove = <String>[];
    _tracks.forEach((key, track) {
      if (!track.enabled && now.difference(track.lastUsed) > idleTimeout) {
        toRemove.add(key);
      }
    });

    for (final key in toRemove) {
      await _disposeTrack(key);
    }
  }

  Future<void> _initAudioSessionIfNeeded() async {
    if (_audioSessionInitialized) return;
    _audioSessionInitialized = true;

    final session = await AudioSession.instance;

    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          usage: AndroidAudioUsage.media,
          contentType: AndroidAudioContentType.music,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: false,
      ),
    );

    session.interruptionEventStream.listen((event) async {
      if (event.begin) {
        await pauseAll();
      } else {
        await resumeAll();
      }
    });

    session.becomingNoisyEventStream.listen((_) async {
      await pauseAll();
    });
  }
}

class _Track {
  _Track({
    required this.player,
    required this.path,
    required this.volume,
    required this.enabled,
    required this.lastUsed,
    this.sourcePrepared = false,
  });

  final AudioPlayer player;
  String path;
  double volume;
  bool enabled;
  DateTime lastUsed;
  bool sourcePrepared;
}
