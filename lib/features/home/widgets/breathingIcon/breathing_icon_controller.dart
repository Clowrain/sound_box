import 'package:flutter/material.dart';

/// 外部统一调度用的控制器（按 key 控制）
class BreathingIconGroupController extends ChangeNotifier {
  /// 当前正在呼吸的按钮 key 列表
  final Set<String> _activeKeys = {};

  /// 获取全部正在呼吸的 key
  Set<String> get activeKeys => _activeKeys;

  /// 开始呼吸
  void start(String key) {
    if (_activeKeys.add(key)) notifyListeners();
  }

  /// 停止呼吸
  void stop(String key) {
    if (_activeKeys.remove(key)) notifyListeners();
  }

  /// 切换呼吸状态
  void toggle(String key) {
    if (_activeKeys.contains(key)) {
      _activeKeys.remove(key);
    } else {
      _activeKeys.add(key);
    }
    notifyListeners();
  }

  /// 全部开始
  void startAll(Iterable<String> keys) {
    bool changed = false;
    for (final k in keys) {
      if (_activeKeys.add(k)) changed = true;
    }
    if (changed) notifyListeners();
  }

  /// 全部停止
  void stopAll() {
    if (_activeKeys.isEmpty) return;
    _activeKeys.clear();
    notifyListeners();
  }

  /// 是否有任何按钮在呼吸
  bool get hasAnyActive => _activeKeys.isNotEmpty;
}
