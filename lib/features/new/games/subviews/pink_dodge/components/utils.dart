
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';

class BackgroundTile extends ParallaxComponent {
  
  BackgroundTile({
    position,
  }) : super(
          position: position,
        );

  final double scrollSpeed = 40;

  @override
  FutureOr<void> onLoad() async {
    priority = -10;
   
    parallax = await game.loadParallax([
      ParallaxImageData('backgrounds/pink_dodge/10_Sky.png',),
      ParallaxImageData('backgrounds/pink_dodge/09_Forest.png',), 
      ParallaxImageData('backgrounds/pink_dodge/08_Forest.png',),
      ParallaxImageData('backgrounds/pink_dodge/07_Forest.png',),
      ParallaxImageData('backgrounds/pink_dodge/06_Forest.png',),
      ParallaxImageData('backgrounds/pink_dodge/05_Particles.png',),
      ParallaxImageData('backgrounds/pink_dodge/04_Forest.png',),
      ParallaxImageData('backgrounds/pink_dodge/03_Particles.png',),
      ParallaxImageData('backgrounds/pink_dodge/02_Bushes.png',),
      ParallaxImageData('backgrounds/pink_dodge/01_Mist.png',),


      ],

      baseVelocity: Vector2(scrollSpeed, 0),
      velocityMultiplierDelta: Vector2(1.1, 1.0),
      repeat: ImageRepeat.repeat,
      fill: LayerFill.none,

      
    );
    return super.onLoad();
  }
}

