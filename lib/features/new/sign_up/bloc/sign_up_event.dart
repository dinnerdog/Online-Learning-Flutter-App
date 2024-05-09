part of 'sign_up_bloc.dart';

abstract class SignUpEvent {}

class SignUpInitialEvent extends SignUpEvent {}

class SignUpSubmitEvent extends SignUpEvent {

  UserModel user;
  String password;

  SignUpSubmitEvent(
      {required this.user, required this.password});
}

class DatePickingEvent extends SignUpEvent {}
