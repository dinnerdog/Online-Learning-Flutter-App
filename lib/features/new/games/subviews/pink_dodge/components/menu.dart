import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:test1/features/new/games/subviews/pink_dodge/pink_dodge.dart';



class MainMenu extends StatelessWidget {
  final PinkDodgeGame game;

  // Reference to parent game.


  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
       
          decoration: const BoxDecoration(
            color: blackTextColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [


                 Text(
                  'highest score: ${game.highScore}',

                  style: TextStyle(
                      fontFamily: 'ValMore',
                    color: whiteTextColor,
                    fontSize: 24,
                  ),
                ),
                const Text(
                  'Pink Dodge',

                  style: TextStyle(
                      fontFamily: 'ValMore',
                    color: whiteTextColor,
                    fontSize: 48,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 200,
                  height: 75,
                  child: ElevatedButton(
                    onPressed: () {
                      game.overlays.remove('MainMenu');
                      game.overlays.add('PauseButton');                      
                      game.start();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: whiteTextColor,
                    ),
                    child: const Text(
                      'Play',
                      
                      style: TextStyle(
                          fontFamily: 'ValMore',
                        fontSize: 40.0,
                        color: blackTextColor,
                      
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'How to play',
                  style: TextStyle(
                    fontFamily: 'ValMore',
                    color: whiteTextColor,
                    fontSize: 24,
                  ),
                ),
                const Text(
            'Pink Dodge is a game where you have to dodge the trees, \n you can jump by tapping the screen. The game is over when you hit a tree. \n So, how long can you survive, let us find out!',
            
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'ValMore',
                    
                    color: whiteTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}