part of 'chatroom_bloc.dart';

abstract class ChatroomEvent extends Equatable {
  const ChatroomEvent();

  @override
  List<Object> get props => [];
}

class ChatroomInitialEvent extends ChatroomEvent {
  
}

class ChatroomSubscriptionRequested extends ChatroomEvent {
  final String currentUserId;
  final String anotherUserId;

  ChatroomSubscriptionRequested({required this.currentUserId, required this.anotherUserId});



}




class ChatroomUpdatedLastReadEvent extends ChatroomEvent {
  final String currentUserId;
  final String anotherUserId;

  ChatroomUpdatedLastReadEvent({required this.currentUserId, required this.anotherUserId});

}


class ChatroomUpdated extends ChatroomEvent {
  final List<MessageModel> messages;
 
ChatroomUpdated({required this.messages,});
}

class ChatroomClickAddImageEvent extends ChatroomEvent {
  final List<String> imageUrls;



ChatroomClickAddImageEvent({required this.imageUrls});
}



class ChatroomClickSendImageEvent extends ChatroomEvent {
  final String chatroomId;
  final MessageModel message;
  ChatroomClickSendImageEvent(this.chatroomId, this.message);
}

class ChatroomClickSendEvent extends ChatroomEvent {
  final String chatroomId;
  final MessageModel message;
  ChatroomClickSendEvent(this.chatroomId, this.message);
}