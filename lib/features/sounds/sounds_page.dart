import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_box/domain/sounds/white_noise_sound.dart';
import 'package:sound_box/features/sounds/widgets/category_filter_bar.dart';
import 'package:sound_box/features/sounds/widgets/pinned_strip.dart';
import 'package:sound_box/features/sounds/widgets/sound_list.dart';
import 'package:sound_box/shared/audio/sound_track_pool.dart';
import 'package:sound_box/shared/state/pinned_sounds_state.dart';
import 'package:sound_box/shared/state/sound_selection_state.dart';
import 'package:sound_box/shared/utils/pinned_variant_resolver.dart';

/// 声音列表页，拆分为独立部件，便于多端适配与维护。
class SoundsPage extends StatefulWidget {
  const SoundsPage({super.key});

  @override
  State<SoundsPage> createState() => _SoundsPageState();
}

class _SoundsPageState extends State<SoundsPage> {
  final Map<String, WhiteNoiseSoundState> _soundStates = {};
  String? _activeCategory;
  final SoundTrackPool _pool = SoundTrackPool.instance;

  String _variantKey(WhiteNoiseSound sound, int variantIndex) =>
      '${sound.id}::$variantIndex';

  WhiteNoiseSoundState _stateForVariant(
    WhiteNoiseSound sound,
    int variantIndex,
  ) {
    final key = _variantKey(sound, variantIndex);
    final preferredVolume = _pool.preferredVolume(key);
    final isPlaying = _pool.isPlaying(key);
    final existing = _soundStates[key];
    if (existing != null) {
      return existing.copyWith(isPlaying: isPlaying);
    }
    return WhiteNoiseSoundState(volume: preferredVolume, isPlaying: isPlaying);
  }

  void _toggleVariant(WhiteNoiseSound sound, int variantIndex) {
    if (sound.locked) return;
    final key = _variantKey(sound, variantIndex);
    final current = _stateForVariant(sound, variantIndex);
    final nextPlaying = !current.isPlaying;
    final path = _variantPath(sound, variantIndex);
    if (path.isNotEmpty) {
      _pool.toggleTrack(
        key: key,
        path: path,
        volume: current.volume,
        loop: true,
      );
    }
    setState(() {
      _soundStates[key] = current.copyWith(isPlaying: nextPlaying);
    });
  }

  void _changeVariantVolume(
    WhiteNoiseSound sound,
    int variantIndex,
    double value,
  ) {
    if (sound.locked) return;
    final key = _variantKey(sound, variantIndex);
    final current = _stateForVariant(sound, variantIndex);
    final double clamped = value.clamp(0, 1).toDouble();
    _pool.setVolume(key, clamped);
    _pool.setPreferredVolume(key, clamped);
    setState(() {
      _soundStates[key] = current.copyWith(volume: clamped);
    });
  }

  void _toggleVariantPin(WhiteNoiseSound sound, int variantIndex) {
    final key = _variantKey(sound, variantIndex);
    context.read<PinnedSoundsState>().toggle(key);
  }

  void _setCategory(String? category) {
    setState(() {
      _activeCategory = _activeCategory == category ? null : category;
    });
  }

  List<WhiteNoiseSound> _applyCategoryFilter(List<WhiteNoiseSound> sounds) {
    if (_activeCategory == null) return List.of(sounds);
    return sounds
        .where((sound) => sound.category == _activeCategory)
        .toList(growable: false);
  }

  List<CategoryOption> _categoryOptionsFor(List<WhiteNoiseSound> sounds) {
    final seen = <String>{};
    final options = <CategoryOption>[];
    for (final sound in sounds) {
      if (seen.add(sound.category)) {
        options.add(
          CategoryOption(value: sound.category, label: sound.categoryLabel),
        );
      }
    }
    return options;
  }

  void _handlePinnedVariantTap(PinnedVariantEntry entry) {
    _toggleVariantPin(entry.sound, entry.variantIndex);
  }

  String _variantPath(WhiteNoiseSound sound, int variantIndex) {
    final variants = variantEntriesForSound(sound);
    if (variantIndex < 0 || variantIndex >= variants.length) return '';
    return variants[variantIndex].variant.path;
  }

  @override
  Widget build(BuildContext context) {
    final selection = context.watch<SoundSelectionState>();
    final pinnedState = context.watch<PinnedSoundsState>();
    final orderedSounds = selection.sounds;
    final categoryOptions = _categoryOptionsFor(orderedSounds);
    final filteredSounds = _applyCategoryFilter(orderedSounds);
    final pinnedVariants = pinnedEntriesFromKeys(
      pinnedState.pinnedKeys,
      orderedSounds,
    );
    final showFilterEmptyState = filteredSounds.isEmpty;

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: PinnedSoundStrip(
                              variants: pinnedVariants,
                              onUnpin: _handlePinnedVariantTap,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _GhostButton(
                            icon: Icons.close,
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        ],
                      ),
                      if (categoryOptions.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        CategoryFilterBar(
                          options: categoryOptions,
                          activeCategory: _activeCategory,
                          onChanged: _setCategory,
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: showFilterEmptyState
                    ? const SliverToBoxAdapter(child: _EmptyFilterState())
                    : SoundList(
                        sounds: filteredSounds,
                        pinnedState: pinnedState,
                        stateBuilder: _stateForVariant,
                        variantKeyBuilder: _variantKey,
                        onToggle: _toggleVariant,
                        onVolumeChanged: _changeVariantVolume,
                        onTogglePin: _toggleVariantPin,
                      ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
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
            '暂无该场景的声音',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '试试其他分类或清空筛选',
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
