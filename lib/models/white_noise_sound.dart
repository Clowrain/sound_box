import 'package:flutter/widgets.dart';

class WhiteNoiseSound {
  const WhiteNoiseSound({
    required this.id,
    required this.label,
    required this.icon,
    this.assetPath,
    this.loopDuration,
    this.locked = false,
  });

  final String id;
  final String label;
  final IconData icon;
  final String? assetPath;
  final Duration? loopDuration;
  final bool locked;

  WhiteNoiseSound copyWith({IconData? icon, bool? locked}) {
    return WhiteNoiseSound(
      id: id,
      label: label,
      icon: icon ?? this.icon,
      assetPath: assetPath,
      loopDuration: loopDuration,
      locked: locked ?? this.locked,
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
