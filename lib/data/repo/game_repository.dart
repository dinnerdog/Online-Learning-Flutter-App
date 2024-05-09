import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test1/data/model/course_model.dart';
import 'package:test1/data/model/game_model.dart';

class GameRepository {
  final gameCollection = FirebaseFirestore.instance.collection('games');

  Future<void> addScore(GameModel gameModel, String userId) async {
    await gameCollection.doc(userId).set(gameModel.toMap());

  }

  Stream<GameModel?> getScoreStream(String userId) {
    return gameCollection.doc(userId).snapshots().map((event) => GameModel.fromFirestore(event));
  }


  Future<List<GameModel>> getScores() async {
    final snapshot = await gameCollection.get();
    return snapshot.docs.map((doc) => GameModel.fromFirestore(doc)).toList();
  }

  Future<void> updateScore(Map<String, dynamic> field , String userId) async {

    
    try {
      await gameCollection.doc(userId).update(field);
    } catch (e) {
      await gameCollection.doc(userId).set(field);
    }

  }

  Future<void> deleteScore(String userId) async {
    await gameCollection.doc(userId).delete();
  }

  Future<GameModel?> getScore(String userId) async {
    final snapshot = await gameCollection.doc(userId).get();
    if (!snapshot.exists) {
       addScore(GameModel(userId: userId), userId);
       return GameModel(userId: userId);
    }
    return GameModel.fromFirestore(snapshot);
  }


}