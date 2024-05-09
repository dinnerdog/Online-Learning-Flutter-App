import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/game_repository.dart';
import 'package:test1/features/new/games/subviews/puzzle/puzzle.dart';
import 'package:test1/features/new/profile/subviews/my_trophies/ui/my_trophies.dart';

class SidePanel extends StatefulWidget {
   SidePanel({
    super.key,
    required this.user, required this.game,  this.imageUrl,
  });


   String? imageUrl;

  final PuzzleGame game;

  final UserModel user;





  @override
  State<SidePanel> createState() => _SidePanelState();
}

class _SidePanelState extends State<SidePanel> {

  bool isChangeingImage = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          width: 300,
    
          child: Column(
            children: [
    
               
              
              ListTile(
                title: Text('Puzzle'),
                subtitle: Text('Solve the puzzle!'),
            
              ),


              StreamBuilder(stream: GameRepository().getScoreStream(widget.user.id), builder: 
              (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Skeletonizer(child: ListTile(
                    title: Text('Score: 0'),
                  )
                  );
                }
                return ListTile(
               
                  title: Text('Score: ${snapshot.data?.puzzleScore ?? 0}'),
                );
              }),
              
              Image.asset('assets/images/${widget.imageUrl}'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.maxFinite,
                       
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      foregroundColor: MaterialStateProperty.all(Colors.white)
                    ),
                    onPressed: () {
                      widget.game.shuffleTiles();
                    
                    },
                    child: Text('Reset'),
                  
                  ),
                ),
              ),


        // ElevatedButton(onPressed: (){
        //   widget.game.oneStepToWin();
        // }, child: 
        // Text('One step to win')),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                  
                  
                  
                    onPressed: () async {
                    
                      if(isChangeingImage){
                        return;
                      }
                      isChangeingImage = true;
                      
                  
                     
                  
                      
                      final puzzleImageNumber = random.nextInt(3)+1;

                     widget.game.changeImage(
                        'backgrounds/puzzle/puzzle_$puzzleImageNumber.jpg',
                      );
                  
                      setState(() {
                        widget.imageUrl = 'backgrounds/puzzle/puzzle_$puzzleImageNumber.jpg';
                      });
                  
                     
                     await Future.delayed(Duration(seconds: 1));
                      isChangeingImage = false;
                  
                      
                    },
                    child: Text('Change Image'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      foregroundColor: MaterialStateProperty.all(Colors.white)
                    ),
                  ),
                ),
              ),
            
            
            ],
          ),
        ),
      ),
    );
  }
}
