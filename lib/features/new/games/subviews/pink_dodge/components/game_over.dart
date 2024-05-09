import 'package:flutter/material.dart';
import 'package:test1/data/repo/game_repository.dart';
import 'package:test1/features/new/games/subviews/pink_dodge/components/tree.dart';
import 'package:test1/features/new/games/subviews/pink_dodge/pink_dodge.dart';

class GameOver extends StatefulWidget {
  final PinkDodgeGame game;
  

  const GameOver({super.key, required this.game});

  @override
  State<GameOver> createState() => _GameOverState();
}

class _GameOverState extends State<GameOver> {
   final pauseOverlayIdentifier = 'GameOver';
      bool isNewRecord = false;


  @override
  Widget build(BuildContext context) {

      if (widget.game.score > widget.game.highScore) {
        widget.game.highScore = widget.game.score;
        isNewRecord = true;
        GameRepository().updateScore(
         {'pinkDodgeScore': widget.game.score}
          , widget.game.user.id

        );
        
      }
     


    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          const Text(
            'Game Over',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'ValMore',
              fontSize: 24,
            ),
          ),

          if (isNewRecord)
            const Text(
              'New Record!',
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'ValMore',
                fontSize: 24,
              ),
            ),

             Text(
            'Score: ${widget.game.score}  High Score: ${widget.game.highScore}',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'ValMore',
              fontSize: 24,
            ),
          ),

          const SizedBox(height: 40),
                SizedBox(
                  width: 200,
                  height: 75,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.game.overlays.remove('GameOver');
                       widget.game.level.mainCharacter.reset();
                       widget.game.resumeEngine();
                       widget.game.score = 0;
                       widget.game.level.children.whereType().where((element) => element is Tree).forEach((element) {
                         element.removeFromParent();
                       });

                          
                         
                        
                     
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Play',
                      
                      style: TextStyle(
                          fontFamily: 'ValMore',
                        fontSize: 40.0,
                        color: Colors.black,
                      
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}