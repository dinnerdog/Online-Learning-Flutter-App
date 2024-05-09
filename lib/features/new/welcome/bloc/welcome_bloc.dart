import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/auth_repository.dart';
import 'package:test1/data/repo/user_repository.dart';
import 'package:test1/global/common/toast.dart';

part 'welcome_event.dart';
part 'welcome_state.dart';

class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  final UserRepository userRepository;
  final AuthRepository authRepository;

  WelcomeBloc({required this.userRepository, required this.authRepository}) : super(WelcomeInitial()) {
    on<WelcomeInitialEvent>(welcomeInitialEvent);

    on<ClickSignInNavigatonEvent>(clickSignInNavigatonEvent);

    on<ClickSignUpNavigationEvent>(clickSignUpNavigationEvent);

    on<ClickSignOutEvent>(clickSignOutEvent);


    on<NavigateToHomeEvent>(navigateToHomeEvent);
  }

  FutureOr<void> welcomeInitialEvent(
      WelcomeInitialEvent event, Emitter<WelcomeState> emit) async {
    emit(WelcomeLoadingState());

    try {
      final userModel = await userRepository.getCurrentUser();

      if (userModel != null) {
        
        emit(WelcomeLoadedwithUserState(userModel: userModel));
        Future.delayed(Duration(seconds: 2), () {
            add(NavigateToHomeEvent(
              userModel: userModel,

            ));
          
        });
      } else {
        emit(WelcomeLoadedWithoutUserState());
      }
    } catch (e) {
      emit(WelcomeErrorState());
      showToast(message: e.toString());
   
    }
  }

  FutureOr<void> clickSignInNavigatonEvent(
      ClickSignInNavigatonEvent event, Emitter<WelcomeState> emit)  {
    emit(WelcomeNavigateToSignInActionState());
  }

  FutureOr<void> clickSignUpNavigationEvent(
      ClickSignUpNavigationEvent event, Emitter<WelcomeState> emit) {
    emit(WelcomeNavigateToSignUpActionState());
  }

  FutureOr<void> clickSignOutEvent(
      ClickSignOutEvent event, Emitter<WelcomeState> emit) {
    try {
      authRepository.signOut();
      emit(WelcomeLoadedWithoutUserState());
      showToast(message: 'Sign out successfully');
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  

  FutureOr<void> navigateToHomeEvent(NavigateToHomeEvent event, Emitter<WelcomeState> emit) {
    emit(WelcomeNavigateToHomeActionState(
      userModel: event.userModel,
    ));
  }
}
