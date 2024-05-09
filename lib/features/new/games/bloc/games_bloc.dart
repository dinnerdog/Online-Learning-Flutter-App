import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test1/data/model/game_model.dart';
import 'package:test1/data/repo/game_repository.dart';

part 'games_event.dart';
part 'games_state.dart';

class GamesBloc extends Bloc<GamesEvent, GamesState> {
  GamesBloc() : super(GamesInitial()) {
  on<GamesInitialEvent>(gamesInitialEvent);
   on<GetGames>(getGames);
  }

  FutureOr<void> getGames(GetGames event, Emitter<GamesState> emit) async {
    try {
      final games = await GameRepository().getScores();
      emit(GameSucessState(games: games));
    } catch (e) {
      emit(GameErrorState(message: e.toString()));
    }
  }

  FutureOr<void> gamesInitialEvent(GamesInitialEvent event, Emitter<GamesState> emit) {
    

    emit(GameLoadingState());

    add(GetGames(userId: event.userId));

  }
}
