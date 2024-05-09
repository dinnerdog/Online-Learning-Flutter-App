import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test1/features/new/games/subviews/pink_dodge/pink_dodge.dart';

class QuitButton extends StatelessWidget {
  final PinkDodgeGame game;

  const QuitButton({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, size: 52,),
      onPressed: () {
        Navigator.pop(context);
           Flame.device.setOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);
      },
    );

  }
}