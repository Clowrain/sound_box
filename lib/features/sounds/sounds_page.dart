import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_box/domain/sounds/white_noise_sound.dart';
import 'package:sound_box/shared/state/pinned_sounds_state.dart';
import 'package:sound_box/shared/state/sound_selection_state.dart';
import 'package:sound_box/shared/utils/pinned_variant_resolver.dart';

import 'widgets/sound_card.dart';

class SoundsPage extends StatefulWidget {
  const SoundsPage({super.key});

  @override
  State<SoundsPage> createState() => _SoundsPageState();
}

class _SoundsPageState extends State<SoundsPage> {
  final Map<String, WhiteNoiseSoundState> _soundStates = {};
  String? _activeCategory;

  String _variantKey(WhiteNoiseSound sound, int variantIndex) =>
      '${sound.id}::$variantIndex';

  WhiteNoiseSoundState _stateForVariant(
    WhiteNoiseSound sound,
    int variantIndex,
  ) {
    final key = _variantKey(sound, variantIndex);
    return _soundStates[key] ??
        const WhiteNoiseSoundState(volume: 0.6, isPlaying: false);
  }

  void _toggleVariant(WhiteNoiseSound sound, int variantIndex) {
    if (sound.locked) return;
    final key = _variantKey(sound, variantIndex);
    final current = _stateForVariant(sound, variantIndex);
    setState(() {
      _soundStates[key] = current.copyWith(isPlaying: !current.isPlaying);
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
    setState(() {
      _soundStates[key] = current.copyWith(volume: value.clamp(0, 1));
    });
  }

  void _toggleVariantPin(WhiteNoiseSound sound, int variantIndex) {
    final key = _variantKey(sound, variantIndex);
    context.read<PinnedSoundsState>().toggle(key);
  }

  void _setCategory(String? category) {
    setState(() {
      if (_activeCategory == category) {
        _activeCategory = null;
      } else {
        _activeCategory = category;
      }
    });
  }

  List<WhiteNoiseSound> _applyCategoryFilter(List<WhiteNoiseSound> sounds) {
    if (_activeCategory == null) return List.of(sounds);
    return sounds
        .where((sound) => sound.category == _activeCategory)
        .toList(growable: false);
  }

  List<_CategoryOption> _categoryOptionsFor(List<WhiteNoiseSound> sounds) {
    final seen = <String>{};
    final options = <_CategoryOption>[];
    for (final sound in sounds) {
      if (seen.add(sound.category)) {
        options.add(
          _CategoryOption(value: sound.category, label: sound.categoryLabel),
        );
      }
    }
    return options;
  }

  void _handlePinnedVariantTap(PinnedVariantEntry entry) {
    _toggleVariantPin(entry.sound, entry.variantIndex);
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
                            child: _PinnedSoundStrip(
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
                        _CategoryFilterBar(
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
                sliver: filteredSounds.isEmpty
                    ? const SliverToBoxAdapter(child: _EmptyFilterState())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final sound = filteredSounds[index];
                          return _buildSoundTile(
                            sound: sound,
                            pinnedState: pinnedState,
                          );
                        }, childCount: filteredSounds.length),
                      ),
              ),
              if (showFilterEmptyState)
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(child: _EmptyFilterState()),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundTile({
    required WhiteNoiseSound sound,
    required PinnedSoundsState pinnedState,
  }) {
    final variants = variantEntriesForSound(sound);
    return Padding(
      key: ValueKey('tile_${sound.id}'),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sound.name, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Column(
            children: variants.map((entry) {
              final state = _stateForVariant(entry.sound, entry.variantIndex);
              final pinned = pinnedState.isPinned(
                _variantKey(entry.sound, entry.variantIndex),
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SoundCard(
                  sound: entry.sound,
                  variant: entry.variant,
                  volume: state.volume,
                  isPlaying: state.isPlaying,
                  onToggle: () =>
                      _toggleVariant(entry.sound, entry.variantIndex),
                  onVolumeChanged: (value) => _changeVariantVolume(
                    entry.sound,
                    entry.variantIndex,
                    value,
                  ),
                  isPinned: pinned,
                  onTogglePin: () =>
                      _toggleVariantPin(entry.sound, entry.variantIndex),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PinnedSoundStrip extends StatelessWidget {
  const _PinnedSoundStrip({required this.variants, required this.onUnpin});

  final List<PinnedVariantEntry> variants;
  final ValueChanged<PinnedVariantEntry> onUnpin;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: variants.isEmpty
          ? const _PinnedHint()
          : _PinnedList(
              key: const ValueKey('pinned_list'),
              variants: variants,
              onUnpin: onUnpin,
            ),
    );
  }
}

class _PinnedHint extends StatelessWidget {
  const _PinnedHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Text(
        '点击音效右侧的图钉，可将常用音色固定在这里',
        maxLines: 1,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

class _PinnedList extends StatelessWidget {
  const _PinnedList({super.key, required this.variants, required this.onUnpin});

  final List<PinnedVariantEntry> variants;
  final ValueChanged<PinnedVariantEntry> onUnpin;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: variants.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = variants[index];
          final sound = entry.sound;
          final label = entry.variant.name.isNotEmpty
              ? entry.variant.name
              : sound.name;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Icon(sound.icon, color: Colors.white, size: 16),
                  ),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: GestureDetector(
                      onTap: () => onUnpin(entry),
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: 48,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.options,
    required this.activeCategory,
    required this.onChanged,
  });

  final List<_CategoryOption> options;
  final String? activeCategory;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length + 1,
        padding: EdgeInsets.zero,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryChip(
              label: '全部',
              selected: activeCategory == null,
              onTap: () => onChanged(null),
            );
          }
          final option = options[index - 1];
          return _CategoryChip(
            label: option.label,
            selected: activeCategory == option.value,
            onTap: () => onChanged(option.value),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.06);
    final border = Colors.white.withValues(alpha: selected ? 0.2 : 0.08);
    final textColor = Colors.white.withValues(alpha: selected ? 0.95 : 0.7);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: textColor),
        ),
      ),
    );
  }
}

class _CategoryOption {
  const _CategoryOption({required this.value, required this.label});

  final String value;
  final String label;
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
