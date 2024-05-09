import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/auth_repository.dart';
import 'package:test1/data/repo/user_repository.dart';
import 'package:test1/global/common/toast.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}): super(LoginInitial()) {
    on<LoginInitialEvent>(loginInitialEvent);
    on<LoginSubmitEvent>(loginSubmitEvent);
  }

  void loginInitialEvent(LoginInitialEvent event, Emitter<LoginState> emit) {
    emit(LoginInitial());
  }


  
  void loginSubmitEvent(LoginSubmitEvent event, Emitter<LoginState> emit) async{
    emit(LoginSubmitLoadingState());
    try {
      final user = await authRepository.signInWithCredentials(event.email, event.password);
    
      if (user != null) {
        final userModel = await UserRepository().getUserById(user.uid);
        emit(LoginSubmitSuccessState(
          user: userModel,
        ));
      } else {
        emit(LoginInitial());
      }
    } on FirebaseAuthException catch (e) {
      
       emit(LoginInitial());
        showToast(message: e.message.toString());
    }
  }
}

