import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test1/data/model/chat_model.dart';
import 'package:test1/data/repo/chat_repository.dart';
import 'package:test1/global/common/toast.dart';

part 'chatroom_event.dart';
part 'chatroom_state.dart';

class ChatroomBloc extends Bloc<ChatroomEvent, ChatroomState> {
  StreamSubscription? _Subscription;
  


  ChatroomBloc() : super(ChatroomInitial()) {
    on<ChatroomInitialEvent>(chatroomInitialEvent);
    on<ChatroomSubscriptionRequested>(_onSubscriptionRequested);
    on<ChatroomUpdated>(_onChatroomUpdated);
    on<ChatroomClickSendEvent>(chatroomClickSendEvent);
    on<ChatroomUpdatedLastReadEvent>(chatroomUpdatedLastReadEvent);
    on<ChatroomClickSendImageEvent>(chatroomClickSendImageEvent);
    on<ChatroomClickAddImageEvent>(chatroomClickAddImageEvent);



  }

  void _onSubscriptionRequested(event, Emitter<ChatroomState> emit) {
    _Subscription?.cancel();

    final String chatroomId =
        (event.currentUserId.compareTo(event.anotherUserId) < 0)
            ? "${event.currentUserId}${event.anotherUserId}"
            : "${event.anotherUserId}${event.currentUserId}";

   _Subscription =      ChatRepository().getChatroomMessagesStream(chatroomId)
   .listen((messages) {
      add(ChatroomUpdated(messages: messages));
    });

    
  }

  FutureOr<void> _onChatroomUpdated(event, Emitter<ChatroomState> emit) {
    try {
       emit(ChatroomSuccessState(messages: event.messages));
      
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  FutureOr<void> chatroomClickSendEvent(
      ChatroomClickSendEvent event, Emitter<ChatroomState> emit) {
    emit(ChatroomClickSendActionState());
    try {
      ChatRepository().sendMessage(event.chatroomId, event.message);
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  FutureOr<void> chatroomInitialEvent(
      ChatroomInitialEvent event, Emitter<ChatroomState> emit) {
    emit(ChatroomLoadingState());
  }

  FutureOr<void> chatroomUpdatedLastReadEvent(
      ChatroomUpdatedLastReadEvent event, Emitter<ChatroomState> emit) {
    final String chatroomId =
        (event.currentUserId.compareTo(event.anotherUserId) < 0)
            ? "${event.currentUserId}${event.anotherUserId}"
            : "${event.anotherUserId}${event.currentUserId}";
    try {
      ChatRepository().updateLastRead(chatroomId, event.currentUserId);
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  FutureOr<void> chatroomClickSendImageEvent(ChatroomClickSendImageEvent event, Emitter<ChatroomState> emit) {
    emit(ChatroomClickSendActionState());
    try {
      ChatRepository().sendMessage(event.chatroomId, event.message);
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  FutureOr<void> chatroomClickAddImageEvent(ChatroomClickAddImageEvent event, Emitter<ChatroomState> emit) {
    emit(ChatroomClickUploadImageActionState(
      imageUrls: event.imageUrls,
    ));
  }
}
