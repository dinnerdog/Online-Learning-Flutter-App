part of 'chatroom_bloc.dart';

abstract class ChatroomState extends Equatable {
  const ChatroomState();
  
  @override
  List<Object> get props => [];
}

abstract class ChatroomActionState extends ChatroomState {

}




class ChatroomInitial extends ChatroomState {}

class ChatroomLoadingState extends ChatroomState {}



class ChatroomSuccessState extends ChatroomState {
  final List<MessageModel> messages;


ChatroomSuccessState({required this.messages});

    List<Object> get props => [messages];
}

class ChatroomClickSendActionState extends ChatroomActionState {
}

class ChatroomClickUploadImageActionState extends ChatroomActionState {
  final List<String> imageUrls;


  ChatroomClickUploadImageActionState({ required this.imageUrls });

  List<Object> get props => [ imageUrls];

}