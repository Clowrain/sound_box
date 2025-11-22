import 'package:flutter/material.dart';

class WhiteNoiseSound {
  const WhiteNoiseSound({
    required this.id,
    required this.name,
    required this.category,
    required this.iconName,
    required this.variants,
    this.color,
    this.locked = false,
  });

  final String id;
  final String name;
  final String category;
  final String iconName;
  final List<WhiteNoiseSoundVariant> variants;
  final Color? color;
  final bool locked;

  IconData get icon => _WhiteNoiseIcons.iconFor(iconName);

  String get categoryLabel =>
      _categoryLabels[category] ?? category.toUpperCase();

  WhiteNoiseSound copyWith({
    String? name,
    String? category,
    String? iconName,
    List<WhiteNoiseSoundVariant>? variants,
    Color? color,
    bool? locked,
  }) {
    return WhiteNoiseSound(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      variants: variants ?? this.variants,
      color: color ?? this.color,
      locked: locked ?? this.locked,
    );
  }

  factory WhiteNoiseSound.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) {
    final variants = (json['variants'] as List<dynamic>? ?? const [])
        .map(
          (variant) =>
              WhiteNoiseSoundVariant.fromJson(variant as Map<String, dynamic>),
        )
        .toList(growable: false);

    return WhiteNoiseSound(
      id: id,
      name: json['name'] as String? ?? id,
      category: json['category'] as String? ?? 'other',
      iconName: json['icon'] as String? ?? 'graphic-eq',
      variants: variants,
      color: _parseColor(json['color'] as String?),
    );
  }

  static const Map<String, String> _categoryLabels = {
    'background': '背景',
    'ambient': '氛围',
    'place': '场所',
    'noise': '噪音',
    'asmr': 'ASMR',
    'lofi': 'Lo-Fi',
    'other': '其他',
  };
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

class WhiteNoiseSoundVariant {
  const WhiteNoiseSoundVariant({
    required this.name,
    required this.path,
    this.color,
  });

  factory WhiteNoiseSoundVariant.fromJson(Map<String, dynamic> json) {
    return WhiteNoiseSoundVariant(
      name: json['name'] as String? ?? '',
      path: json['path'] as String? ?? '',
      color: _parseColor(json['color'] as String?),
    );
  }

  final String name;
  final String path;
  final Color? color;
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
