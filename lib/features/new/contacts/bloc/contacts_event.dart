part of 'contacts_bloc.dart';

abstract class ContactsEvent extends Equatable {
  const ContactsEvent();

  @override
  List<Object> get props => [];
}


class ContactsInitialEvent extends ContactsEvent {

}

class UsersSubscriptionRequested extends ContactsEvent {


}


class ContactsFilterChangedEvent extends ContactsEvent {


}

class ContactsSearchEvent extends ContactsEvent {


}

class UsersUpdated extends ContactsEvent {
  final List<UserModel> users;
  UsersUpdated(this.users);
}

class ContactsClickChatroomEvent extends ContactsEvent {
  final String uid1;
  final String uid2;

  ContactsClickChatroomEvent({ 
    required this.uid1, required this.uid2});
  

}
