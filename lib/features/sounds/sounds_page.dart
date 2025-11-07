import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_box/data/sound_presets.dart';
import 'package:sound_box/models/white_noise_sound.dart';
import 'package:sound_box/state/sound_selection_state.dart';

import 'widgets/sound_card.dart';

class SoundsPage extends StatefulWidget {
  const SoundsPage({super.key});

  @override
  State<SoundsPage> createState() => _SoundsPageState();
}

class _SoundsPageState extends State<SoundsPage> {
  final Map<String, WhiteNoiseSoundState> _soundStates = {};
  late final List<WhiteNoiseSound> _orderedSounds;
  static const int _primaryCount = 8;

  @override
  void initState() {
    super.initState();
    _orderedSounds = List.of(whiteNoiseSounds);
  }

  WhiteNoiseSoundState _stateFor(WhiteNoiseSound sound) {
    return _soundStates[sound.id] ??
        const WhiteNoiseSoundState(volume: 0.6, isPlaying: false);
  }

  void _toggleSound(WhiteNoiseSound sound) {
    if (sound.locked) return;
    final current = _stateFor(sound);
    setState(() {
      _soundStates[sound.id] = current.copyWith(isPlaying: !current.isPlaying);
    });
  }

  void _changeVolume(WhiteNoiseSound sound, double value) {
    if (sound.locked) return;
    final current = _stateFor(sound);
    setState(() {
      _soundStates[sound.id] = current.copyWith(volume: value.clamp(0, 1));
    });
  }

  void _handleReorder(int oldIndex, int newIndex) {
    final selection = context.read<SoundSelectionState>();
    selection.reorder(oldIndex, newIndex);
    setState(() {
      _orderedSounds
        ..clear()
        ..addAll(selection.sounds);
    });
  }

  bool get _hasSecondary => _orderedSounds.length > _primaryCount;

  @override
  Widget build(BuildContext context) {
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
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          _GhostButton(
                            icon: Icons.close,
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const _InstructionCard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverReorderableList(
                  itemCount: _orderedSounds.length,
                  onReorder: _handleReorder,
                  proxyDecorator: (child, index, animation) =>
                      Material(color: Colors.transparent, child: child),
                  itemBuilder: (context, index) => _buildSoundTile(index),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundTile(int index) {
    final selection = context.watch<SoundSelectionState>();
    final sound = selection.sounds[index];
    final state = _stateFor(sound);
    final isSecondary = _hasSecondary && index >= _primaryCount;

    Widget handle;
    if (sound.locked) {
      handle = const SoundCardIconButton(
        icon: Icons.drag_indicator,
        muted: true,
      );
    } else {
      handle = ReorderableDragStartListener(
        index: index,
        child: const SoundCardIconButton(icon: Icons.drag_indicator),
      );
    }

    Widget card = SoundCard(
      key: ValueKey(sound.id),
      sound: sound,
      volume: state.volume,
      isPlaying: state.isPlaying,
      onToggle: () => _toggleSound(sound),
      onVolumeChanged: (value) => _changeVolume(sound, value),
      reorderHandle: handle,
    );

    if (isSecondary) {
      card = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SideActionButton(),
          const SizedBox(width: 12),
          Expanded(child: card),
        ],
      );
    }

    if (_hasSecondary && index == _primaryCount) {
      card = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const _DottedDivider(),
          const SizedBox(height: 18),
          card,
        ],
      );
    }

    return Padding(
      key: ValueKey('tile_${sound.id}'),
      padding: const EdgeInsets.only(bottom: 18),
      child: card,
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const tips = [
      '长按  上下拖动可以调整声音的顺序。',
      '左右滑动可以单独调节声音的音量。',
      '排在前 8 个的声音将在首页显示。',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF20202F),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '声音排序和音量设置',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: const Icon(Icons.drag_indicator, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            tips.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index == tips.length - 1 ? 0 : 8,
              ),
              child: Text(
                '${index + 1}. ${tips[index]}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dotCount = (constraints.maxWidth / 12).floor();
        return Row(
          children: List.generate(
            dotCount,
            (_) => Expanded(
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SideActionButton extends StatelessWidget {
  const _SideActionButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: const Icon(Icons.arrow_upward_rounded, color: Colors.white70),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
