
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

  final double scrollSpeed = 10;

  @override
  FutureOr<void> onLoad() async {
    priority = -10;
   
    parallax = await game.loadParallax([

       ParallaxImageData('backgrounds/puzzle/sky.png',),

      ParallaxImageData('backgrounds/puzzle/far-clouds.png', ),
      ParallaxImageData('backgrounds/puzzle/far-mountains.png',),
      ParallaxImageData('backgrounds/puzzle/mountains.png',),
      ParallaxImageData('backgrounds/puzzle/near-clouds.png',),
      ParallaxImageData('backgrounds/puzzle/near-clouds.png',),
     
      ParallaxImageData('backgrounds/puzzle/trees.png',),
      ],

      baseVelocity: Vector2(scrollSpeed, 0),
      filterQuality: FilterQuality.high,
      velocityMultiplierDelta: Vector2(1.2, 1.1),
      repeat: ImageRepeat.repeatX,
      fill: LayerFill.height,

      
    );
    return super.onLoad();
  }
}

