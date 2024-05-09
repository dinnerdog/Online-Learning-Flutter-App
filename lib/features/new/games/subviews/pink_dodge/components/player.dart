import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';

enum PlayerState {
  idle,
  walking,
  jumping,
  hit,
  jump,
  death,

}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef, CollisionCallbacks {
  final current_position;
  Player({this.current_position});

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation walkingAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation hurtAnimation;
  late final SpriteAnimation deathAnimation;
  late final SpriteAnimation jumpAnimation;
  

   double _jumpForce = 420;
  final double _terminalVelocity = 800;

  final double stepTime = 0.1;
  double moveSpeed = 150;
  Vector2 velocity = Vector2.zero();
   double _gravity = 279.8;
    bool hasJumped = false;
     late ShapeHitbox hitbox;
     bool isDead = false;
  

  Vector2 lastPosition = Vector2.zero();
  Vector2 nextPosition = Vector2.zero();
  


  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {

     FlameAudio.play('bounce.wav', volume: 1);
    super.onCollisionStart(intersectionPoints, other);

    current = PlayerState.hit;
    this._gravity = 500;
    add(ScaleEffect.to(
  Vector2.all(0.7),
  EffectController(duration: 1),
  
));

    
    isDead = true;
    
  }


void reset(){
  isDead = false;
  this._gravity = 279.8;
  current = PlayerState.jump;
  position = Vector2(0, 0);
  this.scale = Vector2.all(1);
}







  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-500, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  @override
  FutureOr<void> onLoad() async {



    priority = 3;
    await game.images.loadAllImages();
    this.size = Vector2.all(64);
    this.anchor = Anchor.center;
    



    hitbox = RectangleHitbox();


    add(hitbox);

    _loadAllAnimations();

    return super.onLoad();
  }



  @override
  void update(double dt) {
    _applyGravity(dt);
    _updatePosition(dt);
    _updateAnimation();
    _playerJump(dt);
    super.update(dt);
  }

 void _playerJump(double dt) {
    if (!hasJumped) {
      return;
    }


    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    _jumpForce -= 10;
    if (_jumpForce <= 0) {
      hasJumped = false;
      _jumpForce = 420;
    }
   

  }


  void jump()  async {
     FlameAudio.play('jump.wav', volume: 1);
   
   

    hasJumped = true;
  }


  void _updatePosition(double dt) {
    if (position.distanceTo(nextPosition) < 5) {
      velocity = Vector2.zero();
      return;
    }
    velocity = (nextPosition - lastPosition).normalized() * moveSpeed;
    position += velocity * dt;
  }

  void _updateAnimation() {

    if (isDead) {
      
      current = PlayerState.hit;
      return;
    } else
    if (velocity.x != 0) {
      current = PlayerState.walking;
      if (velocity.x < 0 && scale.x > 0) {
        flipHorizontallyAroundCenter();
      } else if (velocity.x > 0 && scale.x < 0) {
        flipHorizontallyAroundCenter();
      }
    } else {
      current = PlayerState.jump;
    }
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 4);
    walkingAnimation = _spriteAnimation('Walk', 6);
    jumpingAnimation = _spriteAnimation('Jump', 8);
    hurtAnimation = _spriteAnimation('Hurt', 4);
deathAnimation =  _specialSpriteAnimation('Death', 8);
   jumpAnimation = _spriteAnimation('Jump', 8);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.walking: walkingAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.hit: hurtAnimation,
      PlayerState.death: deathAnimation,
      PlayerState.jump: jumpAnimation,
    };

    current = PlayerState.jump;
  }

 SpriteAnimation _specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('games/1 Pink_Monster/Pink_Monster_${state}_${amount}.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
        loop: false,
      ),
    );
  }
  

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(
          'games/1 Pink_Monster/Pink_Monster_${state}_${amount}.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }
}

