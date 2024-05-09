import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/user_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  StreamSubscription? _userSubscription;

  HomeBloc() : super(HomeInitial()) {
    on<HomeInitialEvent>(homeInitialEvent);
    on<HomeNavigateToCourseEvent>(homeNavigateToCourseEvent);
    on<HomeNavigateToActivityEvent>(homeNavigateToActivityEvent);
    on<HomeNavigateToGamesEvent>(homeNavigateToGamesEvent);
    on<HomeNavigateToContactsEvent>(homeNavigateToContactsEvent);
    on<HomeNavigateToProfileEvent>(homeNavigateToProfileEvent);
    //subsciption
    on<UserSubscriptionRequested>(_onSubscriptionRequested);
    on<UserUpdated>(_onUserUpdated);
  }

  FutureOr<void> homeInitialEvent(
      HomeInitialEvent event, Emitter<HomeState> emit) {
    add(UserSubscriptionRequested());
  }

  FutureOr<void> homeNavigateToCourseEvent(
      HomeNavigateToCourseEvent event, Emitter<HomeState> emit) {
    emit(HomeNavigateToCourseActionState(event.userId));
  }

  FutureOr<void> homeNavigateToActivityEvent(
      HomeNavigateToActivityEvent event, Emitter<HomeState> emit) {
    emit(HomeNavigateToActivityActionState());
  }

  FutureOr<void> homeNavigateToGamesEvent(
      HomeNavigateToGamesEvent event, Emitter<HomeState> emit) {
    emit(HomeNavigateToGamesActionState());
  }

  FutureOr<void> homeNavigateToContactsEvent(
      HomeNavigateToContactsEvent event, Emitter<HomeState> emit) {
    emit(HomeNavigateToContactsActionState(event.userId));
  }

  FutureOr<void> homeNavigateToProfileEvent(
      HomeNavigateToProfileEvent event, Emitter<HomeState> emit) {
    emit(HomeNavigateToProfileActionState());
  }

  void _onSubscriptionRequested(
      UserSubscriptionRequested event, Emitter<HomeState> emit) {
    _userSubscription?.cancel();
    _userSubscription = UserRepository().getCurrentUserStream().listen(
      (user) {
        add(UserUpdated(user!));
      },
      onError: (error) {
        // 处理错误
        print(error);
      },
    );
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }

  FutureOr<void> _onUserUpdated(UserUpdated event, Emitter<HomeState> emit) {
    emit(HomeSuccessState(event.user));
  }
}
