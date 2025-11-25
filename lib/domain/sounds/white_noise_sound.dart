import 'package:flutter/material.dart';

/// 单一音色模型，对应 sounds.json 中的扁平条目。
class WhiteNoiseSound {
  const WhiteNoiseSound({
    required this.id,
    required this.name,
    required this.path,
    required this.iconName,
    this.color,
    this.locked = false,
  });

  final String id;
  final String name;
  final String path;
  final String iconName;
  final Color? color;
  final bool locked;

  IconData get icon => _WhiteNoiseIcons.iconFor(iconName);

  WhiteNoiseSound copyWith({
    String? name,
    String? path,
    String? iconName,
    Color? color,
    bool? locked,
  }) {
    return WhiteNoiseSound(
      id: id,
      name: name ?? this.name,
      path: path ?? this.path,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      locked: locked ?? this.locked,
    );
  }

  factory WhiteNoiseSound.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) {
    return WhiteNoiseSound(
      id: id,
      name: json['name'] as String? ?? id,
      path: json['path'] as String? ?? '',
      iconName: json['icon'] as String? ?? 'graphic-eq',
      color: _parseColor(json['color'] as String?),
    );
  }
}

class WhiteNoiseSoundState {
  const WhiteNoiseSoundState({required this.volume, required this.isPlaying});

  final double volume;
  final bool isPlaying;

  WhiteNoiseSoundState copyWith({double? volume, bool? isPlaying}) {
    return WhiteNoiseSoundState(
      volume: volume ?? this.volume,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

class _WhiteNoiseIcons {
  static IconData iconFor(String key) {
    return _iconMap[key] ?? Icons.graphic_eq;
  }

  static const Map<String, IconData> _iconMap = {
    'airplane-engines': Icons.flight_takeoff,
    'bell-fill': Icons.notifications_active,
    'broadcast-pin': Icons.podcasts,
    'bug-fill': Icons.bug_report,
    'building-fill': Icons.apartment,
    'buildings-fill': Icons.location_city,
    'cart-fill': Icons.shopping_cart,
    'chat-dots-fill': Icons.chat_bubble_outline,
    'chat-square-quote-fill': Icons.format_quote,
    'clock-fill': Icons.access_time_filled,
    'cloud-lightning-fill': Icons.thunderstorm,
    'cloud-rain-fill': Icons.cloud,
    'cookie': Icons.cookie,
    'cup-hot-fill': Icons.local_cafe,
    'dribbble': Icons.sports_basketball,
    'droplet-fill': Icons.water_drop,
    'egg-fill': Icons.egg,
    'emoji-smile-fill': Icons.sentiment_satisfied_alt,
    'fan': Icons.toys,
    'fire': Icons.local_fire_department,
    'flower1': Icons.local_florist,
    'gear-fill': Icons.settings,
    'hand-index-thumb': Icons.back_hand,
    'house-fill': Icons.house_rounded,
    'keyboard-fill': Icons.keyboard,
    'life-preserver': Icons.sailing,
    'moon-stars-fill': Icons.nights_stay,
    'music-note-beamed': Icons.music_note,
    'person-walking': Icons.directions_walk,
    'printer-fill': Icons.print,
    'puzzle-fill': Icons.extension,
    'scissors': Icons.content_cut,
    'signpost-2-fill': Icons.alt_route,
    'stars': Icons.stars,
    'tools': Icons.handyman,
    'train-front-fill': Icons.train,
    'train-lightrail-front': Icons.tram,
    'tree-fill': Icons.park,
    'triangle-fill': Icons.change_history,
    'twitter': Icons.flutter_dash,
    'water': Icons.waves,
    'wind': Icons.air,
  };
}

Color? _parseColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  final cleaned = hex.replaceFirst('#', '');
  if (cleaned.length != 6 && cleaned.length != 8) return null;
  final value = int.tryParse(
    cleaned.length == 6 ? 'FF$cleaned' : cleaned,
    radix: 16,
  );
  if (value == null) return null;
  return Color(value);
}
