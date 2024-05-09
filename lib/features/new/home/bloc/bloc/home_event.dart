part of 'home_bloc.dart';

abstract class HomeEvent {}

class HomeInitialEvent extends HomeEvent {}

class UserSubscriptionRequested extends HomeEvent {
}

class UserUpdated extends HomeEvent {
  final UserModel user;
  UserUpdated(this.user);
}

class HomeNavigateToCourseEvent extends HomeEvent {
  final String userId;
  HomeNavigateToCourseEvent(this.userId);
}

class HomeNavigateToActivityEvent extends HomeEvent {}

class HomeNavigateToGamesEvent extends HomeEvent {}

class HomeNavigateToContactsEvent extends HomeEvent {
  final String userId;
  HomeNavigateToContactsEvent(this.userId);
}

class HomeNavigateToProfileEvent extends HomeEvent {}
