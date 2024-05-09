part of 'login_bloc.dart';

@immutable
abstract class LoginState {}

abstract class LoginActionState extends LoginState {}

class LoginInitial extends LoginState {}

class LoginSubmitLoadingState extends LoginState {}

class LoginSubmitSuccessState extends LoginActionState {
  final UserModel user;

  LoginSubmitSuccessState({required this.user});
}

class LoginSubmitActionState extends LoginActionState {} 
