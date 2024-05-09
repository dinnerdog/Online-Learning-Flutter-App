part of 'games_bloc.dart';

abstract class GamesEvent extends Equatable {
  const GamesEvent();

  @override
  List<Object> get props => [];
}


final class GamesInitialEvent extends GamesEvent {
  final String userId;
  
GamesInitialEvent({required this.userId});
}


final class GetGames extends GamesEvent {
  final String userId;

  GetGames({required this.userId});
}
