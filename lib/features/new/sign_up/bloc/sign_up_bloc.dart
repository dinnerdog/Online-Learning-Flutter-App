import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/auth_repository.dart';
import 'package:test1/data/repo/user_repository.dart';
import 'package:test1/global/common/toast.dart';
import 'package:test1/global/helper/image_picker_uploader_helper.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  SignUpBloc({required this.authRepository, required this.userRepository}) : super(SignUpInitial()) {
    on<SignUpInitialEvent>(signUpInitialEvent);
    on<SignUpSubmitEvent>(signUpSubmitEvent);
    on<DatePickingEvent>(datePickingEvent);
}

  FutureOr<void> signUpInitialEvent(SignUpInitialEvent event, Emitter<SignUpState> emit) {
  }

  FutureOr<void> signUpSubmitEvent(SignUpSubmitEvent event, Emitter<SignUpState> emit) async{


    emit(SignUpSubmitLoadingState());
    try {

      final resultUser = await userRepository.signUpWithEmailAndPassword(event.user, event.password);

      if (resultUser != null) {
        emit(SignUpSubmitSuccessState(
          user: resultUser,
        ));
      } else {
        emit(SignUpInitial());
      }
    } catch (e) {
      emit(SignUpInitial());
      showToast(message: e.toString());
    }
  

  }
  

  FutureOr<void> datePickingEvent(DatePickingEvent event, Emitter<SignUpState> emit) {
  }
}

