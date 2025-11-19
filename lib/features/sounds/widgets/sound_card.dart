import 'package:flutter/material.dart';
import 'package:sound_box/models/white_noise_sound.dart';

class SoundCard extends StatelessWidget {
  const SoundCard({
    super.key,
    required this.sound,
    required this.volume,
    required this.isPlaying,
    required this.onToggle,
    required this.onVolumeChanged,
    required this.isPinned,
    required this.onTogglePin,
  });

  final WhiteNoiseSound sound;
  final double volume;
  final bool isPlaying;
  final VoidCallback onToggle;
  final ValueChanged<double> onVolumeChanged;
  final bool isPinned;
  final VoidCallback onTogglePin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locked = sound.locked;
    final actionIcon = locked
        ? Icons.lock_outline
        : isPlaying
        ? Icons.pause_rounded
        : Icons.play_arrow_rounded;
    final pinIcon = isPinned ? Icons.push_pin : Icons.push_pin_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F2D),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(sound.icon, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sound.name, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        _buildMetaLabel(sound),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: _VolumeRail(
              value: volume,
              locked: locked,
              onChanged: locked ? null : onVolumeChanged,
            ),
          ),
          const SizedBox(width: 16),
          SoundCardIconButton(
            icon: actionIcon,
            onPressed: locked ? null : onToggle,
            muted: locked,
          ),
          const SizedBox(width: 8),
          SoundCardIconButton(icon: pinIcon, onPressed: onTogglePin),
        ],
      ),
    );
  }

  String _buildMetaLabel(WhiteNoiseSound sound) {
    final variantCount = sound.variants.length;
    return variantCount > 0 ? '$variantCount 种音色' : '';
  }
}

class _VolumeRail extends StatelessWidget {
  const _VolumeRail({
    required this.value,
    required this.locked,
    required this.onChanged,
  });

  final double value;
  final bool locked;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF13131E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.45)),
      ),
      child: Center(
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: locked
                ? SliderComponentShape.noThumb
                : const RoundSliderThumbShape(enabledThumbRadius: 9),
            overlayShape: SliderComponentShape.noOverlay,
            activeTrackColor: Colors.white.withValues(
              alpha: locked ? 0.2 : 0.9,
            ),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
            thumbColor: locked ? Colors.transparent : Colors.white,
          ),
          child: Slider(
            min: 0,
            max: 1,
            value: value.clamp(0, 1),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class SoundCardIconButton extends StatelessWidget {
  const SoundCardIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.muted = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white.withValues(alpha: muted ? 0.04 : 0.12);
    final iconColor = Colors.white.withValues(alpha: muted ? 0.4 : 0.9);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: muted ? 0.05 : 0.12),
          ),
        ),
        child: Icon(icon, color: iconColor),
      ),
    );
  }
}
