import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:test1/features/new/games/subviews/pink_dodge/components/player.dart';
import 'package:test1/features/new/games/subviews/pink_dodge/components/tree.dart';
import 'package:test1/features/new/games/subviews/pink_dodge/components/utils.dart';
import 'package:test1/features/new/games/subviews/pink_dodge/pink_dodge.dart';

class Level extends World with HasGameRef, TapCallbacks, HasCollisionDetection{
  final Player mainCharacter = Player();
  final backgroundTile = BackgroundTile();
  late Timer interval;



  @override
  void update(double dt) {
    interval.update(dt);
    isOutsideOfScreen(mainCharacter, this);
    
  

    super.update(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (mainCharacter.isDead) {
      return;
    }

    mainCharacter.jump();
  }





  void treeGenerator() async {
    final treeImage = await game.images.load('backgrounds/pink_dodge/tree.png');
    final isUpsideDown = Random().nextBool();
    final gap = game.size.y / 3;

    final tree = Tree(
        image: treeImage,

        finalPosition: Vector2(0, isUpsideDown ? -gap : gap ),
        startPosition: Vector2(game.size.x / 2, isUpsideDown ? -gap : gap ),
        isUpsideDown: isUpsideDown)..size = Vector2(game.size.x / 5, game.size.y / 2);


    add(tree);

  }

  @override
  Future<void> onLoad() async {

    interval = Timer(
      2,
      onTick: () => treeGenerator(),
      repeat: true,
    );



  


    add(backgroundTile..anchor = Anchor.center);

    addAll([
      mainCharacter,
    ]);
  }


  

  void isOutsideOfScreen(PositionComponent c, Level world) {
    if (c.position.y > world.gameRef.size.y / 2 ||
        c.position.y < -world.gameRef.size.y / 2 ||
        c.position.x > world.gameRef.size.x / 2 ||
        c.position.x < -world.gameRef.size.x / 2) {
      // c.removeFromParent();


    
      game.overlays.add('GameOver');
      game.pauseEngine();

    }
  }
}
