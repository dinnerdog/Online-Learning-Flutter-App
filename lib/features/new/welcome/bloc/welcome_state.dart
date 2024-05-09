part of 'welcome_bloc.dart';

@immutable
abstract class WelcomeState {}

abstract class WelcomeActionState extends WelcomeState {}


class WelcomeInitial extends WelcomeState {}

class WelcomeLoadingState extends WelcomeState {}

class WelcomeLoadedwithUserState extends WelcomeState {
  final UserModel userModel;

  WelcomeLoadedwithUserState({required this.userModel});
}

class WelcomeLoadedWithoutUserState extends WelcomeState {}

class WelcomeErrorState extends WelcomeState {}

class WelcomeNavigateToSignInActionState extends WelcomeActionState {}

class WelcomeNavigateToSignUpActionState extends WelcomeActionState {}

class WelcomeSignOutActionState extends WelcomeActionState {}

class WelcomeNameUpdateActionState extends WelcomeActionState {}

class WelcomeNavigateToHomeActionState extends WelcomeActionState {
   final UserModel userModel;

  WelcomeNavigateToHomeActionState({required this.userModel});
}
