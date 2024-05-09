part of 'welcome_bloc.dart';

@immutable
abstract class WelcomeEvent {}

class WelcomeInitialEvent extends WelcomeEvent {}

class ClickSignInNavigatonEvent extends WelcomeEvent {}

class ClickSignUpNavigationEvent extends WelcomeEvent {}

class ClickSignOutEvent extends WelcomeEvent {}

class ClickNameEvent extends WelcomeEvent {}

class NavigateToHomeEvent extends WelcomeEvent {
  final UserModel userModel;

  NavigateToHomeEvent({required this.userModel});
}