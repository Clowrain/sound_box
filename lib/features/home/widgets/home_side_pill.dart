import 'package:flutter/material.dart';

/// 侧边胶囊按钮，支持竖直排列的快捷操作，桌面端/平板均可共用。
class HomeSidePill extends StatelessWidget {
  const HomeSidePill({super.key, this.child, this.height = 110, this.onTap});

  final Widget? child;
  final double height;
  final VoidCallback? onTap;
  static const double _width = 70;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          width: _width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF1B1F2C).withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.45),
              width: 2,
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
