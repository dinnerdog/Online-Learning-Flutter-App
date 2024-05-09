import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/game_repository.dart';
import 'package:test1/features/new/games/subviews/puzzle/components/background.dart';
import 'package:test1/features/new/games/subviews/puzzle/components/quit_button.dart';

import 'dart:ui' as ui;

import 'package:test1/features/new/games/subviews/puzzle/components/side_panel.dart';
import 'package:test1/features/new/games/subviews/puzzle/components/win_menu.dart';

class PuzzleGame extends FlameGame {
  final List<PuzzlePiece> pieces = [];
  final UserModel user;

  PuzzleGame({required this.user});


   String imageUrl = 'backgrounds/puzzle/puzzle_1.jpg';
   
  final background = BackgroundTile();


  bool isShuffling = false;
  int side = 3;
  bool isMoving = false;
  bool isWin = false;


  double pieceSideLength = 200;
  double sidePanelWidth = 300;


  int score = 0;






  Future<int> getHighestScore() async {
    try {
  final int score  = await  GameRepository()
          .getScore(user.id).then((value) => 
          value?.puzzleScore ?? 0
          );
          

         return score;
    } catch (e) {
      print(e);
      return 0;
    }
  }
 

  @override
  Future<void> onLoad() async {
    Flame.device.setOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    await images.loadAllImages();

    final image = await images.load(imageUrl);
      add(background  );

    await cropImage(image, this);

     score = await getHighestScore();
  }



  void changeImage(String newImageUrl) async {
    imageUrl = newImageUrl;
    pieces.forEach((element) { element.removeFromParent();});
    pieces.clear();

    
    final image = await images.load(imageUrl);
     cropImage(image, this);
  }



  void isSolved() async {
    final solved = pieces.every((element) => element.index == element.currentIndex);
    if (solved)  {
      print('Solved');
      isWin = true;
      overlays.add('WinMenu');
          FlameAudio.play('tile.mp3');



      await GameRepository().updateScore(
        
          {'puzzleScore': score + 1}
        
        ,user.id);
          

  
      

    }

  }
  void shuffleTiles() {
    if (isShuffling) {
      return;
    }

    isShuffling = true;

    pieces.shuffle();
    for (var i = 0; i < pieces.length; i++) {
      final piece = pieces[i];

      final targetPosition =
          Vector2((i % side) * pieceSideLength + this.size.x / 2 - pieceSideLength * side /2  - sidePanelWidth /2  , (i ~/ side) * pieceSideLength + this.size.y / 2  - pieceSideLength * side / 2  );

        
      
      piece.currentIndex = i;

      piece.add(MoveEffect.to(
        targetPosition,
        EffectController(duration: 0.5),
        onComplete: () => isShuffling = false,
      ));
    }

   
  }

  void SwapPieces(PuzzlePiece piece1, PuzzlePiece piece2) {
   

    if (isMoving) {
      return;
    }

    FlameAudio.play('Click.wav');
    isMoving = true;
    
    final tempPosition = piece1.position;

    final tempIndex = piece1.currentIndex;

    piece1.currentIndex = piece2.currentIndex;
    piece2.currentIndex = tempIndex;

     isSolved();
    
    piece1.add(MoveEffect.to(
      piece2.position,
      EffectController(duration: 0.5),
      onComplete: () => isMoving = false,
    ));
    piece2.add(MoveEffect.to(
      tempPosition,
      EffectController(duration: 0.5),
      onComplete: () => isMoving = false,
    ));
  }

  void oneStepToWin() {
    pieces.forEach((element) {
      element.currentIndex = element.index;
      element.add(MoveEffect.to(
        Vector2((element.index % side) * pieceSideLength + 100, (element.index ~/ side) * pieceSideLength + 100),
        EffectController(duration: 0.5),
        onComplete: () => isWin = true,
      ));
    });
  }



  Future cropImage(ui.Image image, PuzzleGame game) async {
    image.toByteData(format: ui.ImageByteFormat.png).then((byteData) async {
      final buffer = byteData!.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(buffer);
      codec.getNextFrame().then((frameInfo) async {
        final image = frameInfo.image;
        final pieceSize = pieceSideLength;

        for (var i = 0; i < side; i++) {
          for (var j = 0; j < side; j++) {
            if (i == 0 && j == 0) {


              final piece = PuzzlePiece(

                  i * side + j,
                 i * side + j,
                image: await images.load('backgrounds/puzzle/logo.png'),
                position: Vector2(j * pieceSize.toDouble()  - 300,
                    i * pieceSize.toDouble()  ),
                size: Vector2(pieceSize.toDouble(), pieceSize.toDouble()),
               

               
              );

              pieces.add(piece);
              add(piece);

            } else {
              final rect = Rect.fromLTWH(
                  j * (image.width / side),
                  i * (image.height / side),
                  (image.width / side),
                  (image.height / side));

              final piece = PuzzlePiece(
                i * side + j,
                 i * side + j,

                image: image,
                position: Vector2(j * pieceSize.toDouble() + 100,
                    i * pieceSize.toDouble() + 100),
                size: Vector2(pieceSize.toDouble(), pieceSize.toDouble()),
               
                srcPosition:
                    i == 0 && j == 0 ? null : Vector2(rect.left, rect.top),
                srcSize:
                    i == 0 && j == 0 ? null : Vector2(rect.width, rect.height),
               
              );

              pieces.add(piece);
              add(piece);
            }
          }
        }
        game.shuffleTiles();

      });
    });
  }
}

class PuzzlePiece extends SpriteComponent  with TapCallbacks, HasGameRef<PuzzleGame>{


  final int index;
     int currentIndex;
  
  PuzzlePiece(this.index, this.currentIndex,  {
    
    required ui.Image image,
    required Vector2 position,
    required Vector2 size,
  
    Vector2? srcPosition,
    Vector2? srcSize,

    
  }) : super(
          position: position,
          size: size,
         
        ) {
    sprite = Sprite(image, srcPosition: srcPosition, srcSize: srcSize);
  }




   @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    isSwappable();

    
    
  }

  void isSwappable() {
    final staticPiece = gameRef.pieces.firstWhere((element) => element.index == 0);

    if (staticPiece.currentIndex == currentIndex + 1 ||
        staticPiece.currentIndex == currentIndex - 1 ||
        staticPiece.currentIndex == currentIndex + game.side ||
        staticPiece.currentIndex == currentIndex - game.side) {
      gameRef.SwapPieces(this, staticPiece);
    }
  }

}

class Puzzle extends StatelessWidget {
  final UserModel user;
  const Puzzle({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget.controlled(
        gameFactory: () => PuzzleGame(
          user: user,
        ),
        overlayBuilderMap: {
          'SidePanel': (_, game) =>
              SidePanel(user: user, game: game as PuzzleGame, imageUrl: game.imageUrl,),
          'QuitButton': (_, game) => QuitButton(),
          'WinMenu': (_, game) => WinMenu(game: game as PuzzleGame),
        },
        initialActiveOverlays:  ['SidePanel', 'QuitButton'],
      ),
    );
  }
}
