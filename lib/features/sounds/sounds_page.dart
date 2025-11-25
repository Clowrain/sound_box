import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_box/domain/sounds/white_noise_sound.dart';
import 'package:sound_box/features/sounds/widgets/sound_list.dart';
import 'package:sound_box/shared/audio/sound_track_pool.dart';
import 'package:sound_box/shared/state/sound_selection_state.dart';

/// 声音列表页，拆分为独立部件，便于多端适配与维护。
class SoundsPage extends StatefulWidget {
  const SoundsPage({super.key});

  @override
  State<SoundsPage> createState() => _SoundsPageState();
}

class _SoundsPageState extends State<SoundsPage> {
  final Map<String, WhiteNoiseSoundState> _soundStates = {};
  final SoundTrackPool _pool = SoundTrackPool.instance;

  String _soundKey(WhiteNoiseSound sound) => sound.id;

  WhiteNoiseSoundState _stateForSound(WhiteNoiseSound sound) {
    final key = _soundKey(sound);
    final preferredVolume = _pool.preferredVolume(key);
    final isPlaying = _pool.isPlaying(key);
    final existing = _soundStates[key];
    if (existing != null) {
      return existing.copyWith(isPlaying: isPlaying);
    }
    return WhiteNoiseSoundState(volume: preferredVolume, isPlaying: isPlaying);
  }

  void _toggleSound(WhiteNoiseSound sound) {
    if (sound.locked) return;
    final key = _soundKey(sound);
    final current = _stateForSound(sound);
    final nextPlaying = !current.isPlaying;
    if (sound.path.isNotEmpty) {
      _pool.toggleTrack(
        key: key,
        path: sound.path,
        volume: current.volume,
        loop: true,
      );
    }
    setState(() {
      _soundStates[key] = current.copyWith(isPlaying: nextPlaying);
    });
  }

  void _changeSoundVolume(
    WhiteNoiseSound sound,
    double value,
  ) {
    if (sound.locked) return;
    final key = _soundKey(sound);
    final current = _stateForSound(sound);
    final double clamped = value.clamp(0, 1).toDouble();
    _pool.setVolume(key, clamped);
    _pool.setPreferredVolume(key, clamped);
    setState(() {
      _soundStates[key] = current.copyWith(volume: clamped);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selection = context.watch<SoundSelectionState>();
    final orderedSounds = selection.sounds;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF171722), Color(0xFF0A0A11)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    Text(
                      '音效排序（前 8 个将展示在首页快捷区）',
                      style: theme.textTheme.titleMedium,
                    ),
                    const Spacer(),
                    _GhostButton(
                      icon: Icons.close,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: orderedSounds.isEmpty
                    ? const _EmptyFilterState()
                    : SoundList(
                        sounds: orderedSounds,
                        stateBuilder: _stateForSound,
                        onReorder:
                            context.read<SoundSelectionState>().reorder,
                        onToggle: _toggleSound,
                        onVolumeChanged: _changeSoundVolume,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFilterState extends StatelessWidget {
  const _EmptyFilterState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          Icon(Icons.filter_alt_off, color: Colors.white54, size: 48),
          const SizedBox(height: 12),
          Text(
            '暂无可用声音',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '请检查资源配置或稍后重试',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
