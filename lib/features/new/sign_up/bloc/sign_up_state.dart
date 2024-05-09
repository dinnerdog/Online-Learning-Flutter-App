part of 'sign_up_bloc.dart';

abstract class SignUpState {}

abstract class SignUpActionState extends SignUpState {}

class SignUpInitial extends SignUpState {}

class SignUpSubmitLoadingState extends SignUpState {}

class SignUpSubmitSuccessState extends SignUpActionState {
  final UserModel user;

  SignUpSubmitSuccessState({required this.user});
}

class SignUpSubmitActionState extends SignUpActionState {}

class DatePickingActionState extends SignUpActionState {}

