import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/game_repository.dart';
import 'package:test1/features/new/games/subviews/pink_dodge/components/game_over.dart';
import 'package:test1/features/new/games/subviews/pink_dodge/components/level.dart';
import 'package:test1/features/new/games/subviews/pink_dodge/components/menu.dart';
import 'package:test1/features/new/games/subviews/pink_dodge/components/pause_button.dart';
import 'package:test1/features/new/games/subviews/pink_dodge/components/quit_button.dart';

class PinkDodgeGame extends FlameGame with KeyboardEvents {
  final level = Level();
  late final CameraComponent cam;
  late final TextComponent scoreText;
  final UserModel user;

  PinkDodgeGame({required this.user});

  int score = 0;
   late int highScore;

  final TextPaint textPaint = TextPaint(
      style: TextStyle(
          fontFamily: 'ValMore',
          color: Color.fromARGB(255, 64, 97, 55),
          fontSize: 32));

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isSpace = keysPressed.contains(LogicalKeyboardKey.space);

    if (level.mainCharacter.isDead) {
      return KeyEventResult.ignored;
    }

    if (isSpace) {
      level.mainCharacter.jump();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Future<void> onLoad() async {
    Flame.device.setOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

      highScore =  await getHighestScore();

    cam = CameraComponent(
      world: level,
      hudComponents: [
        scoreText = TextComponent(
            anchor: Anchor.center,
            position: Vector2(this.size.x / 2, 50),
            textRenderer: textPaint)
      ],
    );

  }

  Future<int> getHighestScore() async {
    try {

      print(user.id );
  final int score  = await  GameRepository()
          .getScore(user.id).then((value) {
         
            return value?.pinkDodgeScore ?? 0;
          }
          );
          

         return score;
    } catch (e) {
      print(
          'Error getting highest score: $e'
      );
      return 0;
    }
  }

  void start() {
    addAll([
      level,
      cam,
    ]);
  }

  void reset() {
    level.mainCharacter.position = Vector2(0, 0);
    level.mainCharacter.isDead = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    scoreText.text = 'Score: $score   Higest Score: $highScore';
  }
}

class PinkDodge extends StatelessWidget {
  final UserModel user;

  const PinkDodge({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget.controlled(
        gameFactory: () => PinkDodgeGame(
          user: user,
        ),
        overlayBuilderMap: {
          'MainMenu': (_, game) => MainMenu(game: game as PinkDodgeGame),
          'PauseButton': (_, game) => PauseButton(
                game: game as PinkDodgeGame,
              ),
          'QuitButton': (_, game) => QuitButton(
                game: game as PinkDodgeGame,
              ),
          'GameOver': (_, game) => GameOver(game: game as PinkDodgeGame),
        },
        initialActiveOverlays:  ['MainMenu', 'QuitButton'],
      ),
    );
  }
}
