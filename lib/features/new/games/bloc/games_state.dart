part of 'games_bloc.dart';

abstract class GamesState extends Equatable {
  const GamesState();
  
  @override
  List<Object> get props => [];
}

final class GamesInitial extends GamesState {}


final class GameLoadingState extends GamesState {}


final class GameSucessState extends GamesState {
  final List<GameModel> games;

  GameSucessState({required this.games});


}


final class GameErrorState extends GamesState {
  final String message;

  GameErrorState({required this.message});
}