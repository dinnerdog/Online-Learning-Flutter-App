import 'package:cloud_firestore/cloud_firestore.dart';

class GameModel {
  final String userId;
  final int? pinkDodgeScore;
  final int? puzzleScore;
  final int? wordsJuiceScore;

  GameModel( {required this.userId,  this.pinkDodgeScore, this.puzzleScore, this.wordsJuiceScore});


  factory GameModel.fromFirestore(DocumentSnapshot doc) {
      Map data = doc.data() as Map;
      return GameModel(
        userId: doc.id,
        pinkDodgeScore: data['pinkDodgeScore'] ?? 0,
        puzzleScore: data['puzzleScore'] ?? 0,
        wordsJuiceScore: data['wordsJuiceScore'] ?? 0,
      );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'pinkDodgeScore': pinkDodgeScore ?? 0,
        'puzzleScore': puzzleScore ?? 0,
        'wordsJuiceScore': wordsJuiceScore ?? 0,
      };


  CopyWith({
    String? userId,
    int? pinkDodgeScore,
    int? puzzleScore,
    int? wordsJuiceScore,
  }) {
    return GameModel(
      userId: userId ?? this.userId,
      pinkDodgeScore: pinkDodgeScore ?? this.pinkDodgeScore,
      puzzleScore: puzzleScore ?? this.puzzleScore,
      wordsJuiceScore: wordsJuiceScore ?? this.wordsJuiceScore,
    );
  }
  
  
}