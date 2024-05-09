import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/chat_repository.dart';
import 'package:test1/data/repo/user_repository.dart';

part 'contacts_event.dart';
part 'contacts_state.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  StreamSubscription? _usersSubscription;
  String filterCondition = 'name';
  bool isAscending = true;
  String query = '';
  List<UserModel> allUsers = []; 

  ContactsBloc() : super(ContactsInitial()) {
    on<ContactsInitialEvent>(contactsInitialEvent);
    on<ContactsClickChatroomEvent>(contactsClickChatroomEvent);
    on<ContactsSearchEvent>(contactsSearchEvent);
    on<ContactsFilterChangedEvent>(contactsFilterChangedEvent);
    //subscribe to the event
    on<UsersSubscriptionRequested>(_onSubscriptionRequested);
    on<UsersUpdated>(_onUserUpdated);
  }

  FutureOr<void> contactsInitialEvent(
      ContactsInitialEvent event, Emitter<ContactsState> emit) {

    
    add(UsersSubscriptionRequested(
    ));
  }

  void _onSubscriptionRequested(
      UsersSubscriptionRequested event, Emitter<ContactsState> emit) {
    _usersSubscription?.cancel();

    emit(ContactsLoadingState());

    _usersSubscription = UserRepository().getAllUsersStream().listen(
      (users) {
        // if (event.query.isNotEmpty) {
        //   users = users
        //       .where((user) =>
        //           user.name.toLowerCase().contains(event.query.toLowerCase()))
        //       .toList();
        // }

        // switch (event.filterCondition) {
        //   case 'name':
        //     users.sort((a, b) => a.name.compareTo(b.name));
        //     break;

        //   case 'role':
        //     users.sort((a, b) => a.role.name.compareTo(b.role.name));
        //     break;
        //   default:
        //     break;
        // }

        // if (!event.isAscending) {
        //   users = users.reversed.toList();
        // }

      
          allUsers = users;
        add(UsersUpdated(users));
      },
      onError: (error) {
        print(error);
      },
    );
  }

  FutureOr<void> _onUserUpdated(
      UsersUpdated event, Emitter<ContactsState> emit) {
    emit(ContactsSuccessState(event.users));
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    return super.close();
  }

  FutureOr<void> contactsClickChatroomEvent(
      ContactsClickChatroomEvent event, Emitter<ContactsState> emit) async {
    try {
      final chatroomId =
          await ChatRepository().createOrJoinChatroom(event.uid1, event.uid2);
      emit(
          ContactsClickChatroomActionState(chatroomId, event.uid1, event.uid2));
    } catch (e) {
      print(e);
    }
  }

  FutureOr<void> contactsSearchEvent(
      ContactsSearchEvent event, Emitter<ContactsState> emit) {
        emit(ContactsLoadingState());

  var users = allUsers;
   if (query.isNotEmpty) {
          users = users
              .where((user) =>
                  user.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }

        switch (filterCondition) {
          case 'name':
            users.sort((a, b) => a.name.compareTo(b.name));
            break;

          case 'role':
            users.sort((a, b) => a.role.name.compareTo(b.role.name));
            break;
          default:
            break;
        }

        if (!isAscending) {
          users = users.reversed.toList();
        }

        emit(ContactsSuccessState(users));

  
  }

  FutureOr<void> contactsFilterChangedEvent(
      ContactsFilterChangedEvent event, Emitter<ContactsState> emit) {


        emit(ContactsLoadingState());

  var users = allUsers;
    if (query.isNotEmpty) {
            users = users
                .where((user) =>
                    user.name.toLowerCase().contains(query.toLowerCase()))
                .toList();
          }
  
          switch (filterCondition) {
            case 'name':
              users.sort((a, b) => a.name.compareTo(b.name));
              break;
  
            case 'role':
              users.sort((a, b) => a.role.name.compareTo(b.role.name));
              break;
            default:
              break;
          }
  
          if (!isAscending) {
            users = users.reversed.toList();
          }
  
          emit(ContactsSuccessState(users));

          
  
  }
}
