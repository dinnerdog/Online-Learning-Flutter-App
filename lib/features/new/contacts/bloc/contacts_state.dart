part of 'contacts_bloc.dart';

abstract class ContactsState extends Equatable {
  const ContactsState();
  
  @override
  List<Object> get props => [];
}

abstract class ContactsActionState extends ContactsState {}

final class ContactsInitial extends ContactsState {}

final class ContactsLoadingState extends ContactsState {}

final class ContactsSuccessState extends ContactsState {
  final List<UserModel> users;
  ContactsSuccessState(this.users);

  List<Object> get props => [users];
}



final class ContactsClickChatroomActionState extends ContactsActionState {
  final String chatRoomId;
  final String currentUserId;
  final String anotherUserId;
  ContactsClickChatroomActionState(this.chatRoomId, this.currentUserId, this.anotherUserId);
}
