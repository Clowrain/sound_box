import 'package:flutter/material.dart';

/// 分类筛选条，支持“全部”与动态分类切换。
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.options,
    required this.activeCategory,
    required this.onChanged,
  });

  final List<CategoryOption> options;
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

class CategoryOption {
  const CategoryOption({required this.value, required this.label});

  final String value;
  final String label;
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
