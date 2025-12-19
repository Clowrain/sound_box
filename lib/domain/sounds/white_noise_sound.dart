import 'dart:ui';

/// 单一音色模型，对应 sounds.json 中的扁平条目。
class WhiteNoiseSound {
  const WhiteNoiseSound({
    required this.id,
    required this.name,
    required this.path,
    required this.iconAsset,
    this.color,
    this.locked = false,
  });

  final String id;
  final String name;
  final String path;
  final String iconAsset;
  final Color? color;
  final bool locked;

  String get svgAsset => _resolveSvgAsset(iconAsset);

  WhiteNoiseSound copyWith({
    String? name,
    String? path,
    String? iconAsset,
    Color? color,
    bool? locked,
  }) {
    return WhiteNoiseSound(
      id: id,
      name: name ?? this.name,
      path: path ?? this.path,
      iconAsset: iconAsset ?? this.iconAsset,
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
      iconAsset: json['icon'] as String? ?? _defaultSvgAsset,
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

const String _defaultSvgAsset = 'assets/icons/default.svg';

String _resolveSvgAsset(String raw) {
  if (raw.isEmpty) return _defaultSvgAsset;
  if (raw.endsWith('.svg')) return raw;
  return _defaultSvgAsset;
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
