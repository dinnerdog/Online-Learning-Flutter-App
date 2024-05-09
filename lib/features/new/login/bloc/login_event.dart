part of 'login_bloc.dart';

abstract class LoginEvent {}



class LoginInitialEvent extends LoginEvent {}



class LoginSubmitEvent extends LoginEvent {
  final String email;
  final String password;

  LoginSubmitEvent({required this.email, required this.password});
}

