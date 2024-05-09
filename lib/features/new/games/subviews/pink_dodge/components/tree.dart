import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:test1/features/new/games/subviews/pink_dodge/components/player.dart';
import 'package:test1/features/new/games/subviews/pink_dodge/pink_dodge.dart';


class Tree extends SpriteComponent with CollisionCallbacks, HasGameRef {
Tree({image, required this.finalPosition, required this.startPosition,required this.isUpsideDown}) : super.fromImage(image);

  final double moveSpeed = 150;
  late final Vector2 velocity;
  bool isUpsideDown;
  final Vector2 finalPosition;
  final Vector2 startPosition;
  late ShapeHitbox hitbox;
  bool isScored = false;










@override
  void onLoad() {



     
    hitbox = RectangleHitbox(
      size: Vector2(size.x - 60 , size.y - 40),
      position: Vector2(position.x + 30, position.y + 40)
      
    )
    

    ;
    add(hitbox);

    
    if (isUpsideDown) {
      this.scale = Vector2(1, -1);
    }
    anchor = Anchor.center;
    
    velocity =  (finalPosition - startPosition).normalized() * moveSpeed;
    this.position = startPosition;
    super.onLoad();
  }




  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    hitbox.paint.color = Color.fromARGB(255, 18, 204, 4);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (!isColliding) {
      hitbox.paint.color = const Color(0xFFFF00FF);
    }
  }
  

  @override
  void update(double dt) {
    updateCurrentPosition(dt);
    isOutsideOfScreen(this);
    isScore((game as PinkDodgeGame).level.mainCharacter);
    
    super.update(dt);
  }


  void updateCurrentPosition(double dt) {
    this.position += velocity * dt;
  }

  

  

void isScore(Player c) {
    if (isScored) {
      return;
    }

    if (c.position.x > this.position.x) {
      (game as PinkDodgeGame).score += 1;
      isScored = true;
      
    }
  }


void isOutsideOfScreen(Tree c) {
    if (
        c.position.x < - game.size.x / 2 ) {
      c.removeFromParent();
    }
  }




  
}
