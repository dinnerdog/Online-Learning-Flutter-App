part of 'home_bloc.dart';

abstract class HomeState extends Equatable {


  @override
  List<Object> get props => [];
}

abstract class HomeActionState extends HomeState {}

class HomeInitial extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeSuccessState extends HomeState {
  final UserModel user;
  HomeSuccessState(this.user);

   List<Object> get props => [user];
}

class HomeErrorState extends HomeState {}

class HomeNavigateToCourseActionState extends HomeActionState {
    final String userId;
  HomeNavigateToCourseActionState(this.userId);
}

class HomeNavigateToActivityActionState extends HomeActionState {}

class HomeNavigateToGamesActionState extends HomeActionState {}

class HomeNavigateToContactsActionState extends HomeActionState {
  final String userId;
  HomeNavigateToContactsActionState(this.userId);
}

class HomeNavigateToProfileActionState extends HomeActionState {}
