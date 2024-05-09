import 'package:flutter/material.dart';
import 'package:test1/features/new/games/subviews/pink_dodge/pink_dodge.dart';

class PauseButton extends StatefulWidget {
  final PinkDodgeGame game;

  const PauseButton({super.key, required this.game});

  @override
  State<PauseButton> createState() => _PauseButtonState();
}

class _PauseButtonState extends State<PauseButton> {

    bool isPasued = false;

  final pauseOverlayIdentifier = 'PauseButton';

  @override
  Widget build(BuildContext context) {
    
    return Container(
      alignment: Alignment.topRight,
      child: IconButton(
        
        icon:  isPasued ? Icon(Icons.play_arrow, size: 52,) : Icon(Icons.pause, size: 52,),
        onPressed: () {
          if (isPasued) {
              widget.game.resumeEngine();
              setState(() {
                isPasued = false;
              });
           

            
          } else {
             widget.game.pauseEngine();
              setState(() {
                isPasued = true;
              });
          
          }

          
        },
      ),
    );
  }
}