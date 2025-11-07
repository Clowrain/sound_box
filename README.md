# Sound Box · 白噪音收音机

Flutter 版的白噪音体验，完整迁移自 `rn/` 目录下的 React Native 原型，并针对手机 / 平板 / 桌面 / Web 做了布局适配和组件拆分。这里既是睡眠/专注工具，也是组件化 Flutter 应用的参考实现。

## 核心体验

- **双姿态主屏**：点阵时钟随容器实时缩放，Portrait/ Landscape 拥有不同控制布局。
- **音效混音管理**：卡片可一键播放、展开音量滑块，底部控制条可统一播放/暂停。
- **浮层反馈**：正在播放的音效以 Chips 浮层呈现，随时支持移除。
- **定时器**：底部计时器按钮唤起自定义 Bottom Sheet，倒计时结束自动暂停所有音效。
- **跨端视觉一致**：自定义渐变、阴影、拟物化按钮在多平台上保持一致表现。

## 代码结构

```
lib/
├─ app.dart                  // MaterialApp + 主题
├─ data/sound_presets.dart   // 白噪音预设
├─ models/white_noise_sound.dart
├─ features/
│  ├─ home/
│  │  ├─ home_page.dart
│  │  └─ widgets/dot_matrix_clock.dart
│  └─ sounds/
│     ├─ sounds_page.dart
│     └─ widgets/
│        ├─ sound_card.dart
│        ├─ playing_sounds_chips.dart
│        ├─ player_control_bar.dart
│        └─ timer_sheet.dart
```

React Native 版本保留在 `rn/` 目录，可作为样式／交互对照。

## 快速开始

```bash
flutter pub get
flutter run        # 运行到任意已连接设备或模拟器
flutter test       # 执行基本 widget 测试
```

项目已启用 `analysis_options.yaml`，保持 `flutter analyze` 无警告即可。

## 迁移策略 & 后续方向

1. **渐进方案**：在现有架构上补充真实的音频资源（可接入 `just_audio` + 本地/远程声音）。
2. **激进方案**：引入状态管理（如 Riverpod）+ 场景编排（例：专注 / 助眠 Preset），开放多端同步。
3. **无限预算方案**：结合声场建模和触觉反馈，做自定义声景编辑器 + 云端分享。

当前实现主要关注 UI/状态迁移，音频解码与素材管理可以按业务需求再行扩展。欢迎在此基础上继续雕琢体验。
