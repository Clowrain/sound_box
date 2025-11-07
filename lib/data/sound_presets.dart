import 'package:flutter/material.dart';
import 'package:sound_box/models/white_noise_sound.dart';

const whiteNoiseSounds = <WhiteNoiseSound>[
  WhiteNoiseSound(id: 'rain', label: '滑滑细雨', icon: Icons.water_drop_outlined),
  WhiteNoiseSound(
    id: 'fire',
    label: '篝火串串',
    icon: Icons.local_fire_department_outlined,
  ),
  WhiteNoiseSound(id: 'thunder', label: '夏雷阵阵', icon: Icons.bolt_outlined),
  WhiteNoiseSound(id: 'stream', label: '流水潺潺', icon: Icons.waterfall_chart),
  WhiteNoiseSound(
    id: 'ocean',
    label: '沧海桑田',
    icon: Icons.waves_outlined,
    locked: true,
  ),
  WhiteNoiseSound(
    id: 'cat',
    label: '猫儿梦呓',
    icon: Icons.pets_outlined,
    locked: true,
  ),
  WhiteNoiseSound(
    id: 'forest',
    label: '静谧森林',
    icon: Icons.park_outlined,
    locked: true,
  ),
  WhiteNoiseSound(
    id: 'night',
    label: '阑夜虫鸣',
    icon: Icons.nightlight_outlined,
    locked: true,
  ),
  WhiteNoiseSound(
    id: 'whale',
    label: '鲸鱼',
    icon: Icons.sailing_outlined,
    locked: true,
  ),
  WhiteNoiseSound(
    id: 'coffee',
    label: '咖啡',
    icon: Icons.coffee_outlined,
    locked: true,
  ),
  WhiteNoiseSound(
    id: 'clock',
    label: '时钟',
    icon: Icons.access_time_outlined,
    locked: true,
  ),
];
