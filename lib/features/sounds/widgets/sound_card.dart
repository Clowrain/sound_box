import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sound_box/domain/sounds/white_noise_sound.dart';

class SoundCard extends StatelessWidget {
  const SoundCard({
    super.key,
    required this.sound,
    required this.volume,
    required this.isPlaying,
    required this.onToggle,
    required this.onVolumeChanged,
  });

  final WhiteNoiseSound sound;
  final double volume;
  final bool isPlaying;
  final VoidCallback onToggle;
  final ValueChanged<double> onVolumeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locked = sound.locked;
    final actionIcon = locked
        ? Icons.lock_outline
        : isPlaying
            ? Icons.pause_rounded
            : Icons.play_arrow_rounded;
    final title = sound.name;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        void handleDrag(double dx) {
          if (locked) return;
          final ratio = (dx / width).clamp(0, 1).toDouble();
          onVolumeChanged(ratio);
        }

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (details) =>
              handleDrag(details.localPosition.dx),
          onHorizontalDragUpdate: (details) =>
              handleDrag(details.localPosition.dx),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1B1C29),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 12,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: volume.clamp(0, 1),
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const SizedBox(width: 4),
                          SvgPicture.asset(
                            sound.svgAsset,
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: theme.textTheme.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SoundCardIconButton(
                      icon: actionIcon,
                      onPressed: locked ? null : onToggle,
                      muted: locked,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
