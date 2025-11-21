import 'package:flutter/material.dart';

/// 方形操作按钮，支持纯图标或图标+文字，便于多端统一皮肤和点击反馈。
class HomeSquareButton extends StatelessWidget {
  const HomeSquareButton({super.key, this.icon, this.label, this.onTap});

  final IconData? icon;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isIconOnly = (label == null) || label!.isEmpty;
    final Color iconColor = isIconOnly ? Colors.black : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          decoration: _outerDecoration(),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: _innerDecoration(),
            child: Center(
              child: isIconOnly
                  ? Icon(icon, color: iconColor, size: 24)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: iconColor, size: 22),
                        const SizedBox(height: 6),
                        Text(
                          label!,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /// 外层暗色渐变，强调立体边框。
  BoxDecoration _outerDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2E3548), Color(0xFF171C28)],
      ),
      border: Border.all(color: Colors.black.withValues(alpha: 0.55), width: 2),
      boxShadow: const [
        BoxShadow(
          color: Colors.black54,
          offset: Offset(0, 10),
          blurRadius: 18,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Color(0x3329394D),
          offset: Offset(-2, -2),
          blurRadius: 8,
        ),
      ],
    );
  }

  /// 内层柔和渐变，便于后续按平台调整亮度。
  BoxDecoration _innerDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF232838), Color(0xFF171C28)],
      ),
      border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
    );
  }
}
