import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:rxdart/rxdart.dart';
import 'package:searchbar_animation/searchbar_animation.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:test1/data/model/chat_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/chat_repository.dart';
import 'package:test1/features/new/contacts/bloc/contacts_bloc.dart';
import 'package:test1/features/new/contacts/subviews/chatroom/ui/chatroom.dart';
import 'package:test1/features/new/contacts/ui/contact_tile.dart';
import 'package:test1/features/new/home/bloc/bloc/menu_bloc.dart';
import 'package:test1/global/common/filter_dropdown.dart';
import 'package:test1/main.dart';
import 'package:alphabet_scroll_view/alphabet_scroll_view.dart';

class Contacts extends StatefulWidget {
  final String currentUserId;
  const Contacts({super.key, required this.currentUserId});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  ContactsBloc contactsBloc = ContactsBloc();
  final TextEditingController queryController = TextEditingController();
  GlobalKey<SliderDrawerState> _contactsFilterKey =
      GlobalKey<SliderDrawerState>();
  // bool isAscending = true;
  // String filterCondition = 'name';

  @override
  void initState() {
    super.initState();

    contactsBloc.add(ContactsInitialEvent());
  }

  @override
  void dispose() {
    contactsBloc.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         automaticallyImplyLeading : false,
        backgroundColor: AppColors.secondaryColor,
        title: searchBar(),

        toolbarHeight: 80,
        actions: [
          IconButton(
            style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all(AppColors.secondaryColor),
              backgroundColor: MaterialStateProperty.all(AppColors.accentColor),
            ),
            onPressed: () {
              _contactsFilterKey.currentState!.toggle();
            },
            icon: Icon(
              Icons.filter_alt_outlined,
            ),
          ),
          IconButton(
            style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all(AppColors.secondaryColor),
              backgroundColor: MaterialStateProperty.all(AppColors.accentColor),
            ),
            onPressed: () {
              BlocProvider.of<MenuBloc>(context).add(MenuToggleEvent());
            },
            icon: Icon(
              Icons.expand_outlined,
            ),
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: SliderDrawer(
        key: _contactsFilterKey,
        slideDirection: SlideDirection.TOP_TO_BOTTOM,
        appBar: null,
        sliderOpenSize: 70,
        slider: Container(
          color: AppColors.accentColor,
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 20),
                  Expanded(
                    flex: 5,
                    child: Row(
                      children: [
                        Icon(Icons.sort, color: AppColors.secondaryColor),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: FilterDropdown(
                              onFilterApplied: (value) {
                                setState(() {
                                  contactsBloc.filterCondition =
                                      filterConditionToField(
                                          value);
                                });

                                contactsBloc.add(ContactsFilterChangedEvent());
                              },
                              filterConditions: [
                                'name',
                                'role',
                              ],
                              currentFilterCondition:
                                  contactsBloc.filterCondition,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        AnimatedToggleSwitch<bool>.dual(
                          borderWidth: 2,
                          onChanged: (b) {
                            setState(() {
                              contactsBloc.isAscending = b;
                            });

                            contactsBloc.add(ContactsFilterChangedEvent());
                          },
                          styleBuilder: (b) => ToggleStyle(
                            indicatorColor: b
                                ? AppColors.accentColor
                                : AppColors.secondaryColor,
                            backgroundColor: b
                                ? AppColors.secondaryColor
                                : AppColors.accentColor,
                            borderColor: b
                                ? AppColors.secondaryColor
                                : AppColors.secondaryColor,
                          ),
                          textBuilder: (value) => value
                              ? Center(
                                  child: Text('Descending',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.accentColor)))
                              : Center(
                                  child: Text('Ascending',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.secondaryColor))),
                          style: ToggleStyle(
                            indicatorColor: AppColors.accentColor,
                            backgroundColor: AppColors.secondaryColor,
                          ),
                          first: true,
                          second: false,
                          current: contactsBloc.isAscending,
                          iconBuilder: (b) => b
                              ? Icon(Icons.sort_rounded,
                                  color: AppColors.secondaryColor)
                              : Icon(Icons.sort_rounded,
                                  color: AppColors.accentColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        child: Container(
          color: AppColors.secondaryColor,
          child: BlocConsumer<ContactsBloc, ContactsState>(
            bloc: contactsBloc,
            listenWhen: (previous, current) => current is ContactsActionState,
            buildWhen: (previous, current) => current is! ContactsActionState,
            listener: (context, state) {
              if (state is ContactsClickChatroomActionState) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Chatroom(
                    currentUserId: widget.currentUserId,
                    anotherUserId: state.anotherUserId,
                    contactsBloc: contactsBloc,
                  ),
                ));
              }
            },
            builder: (context, state) {
              switch (state.runtimeType) {
                case ContactsLoadingState:
                  return Skeletion();

                case ContactsSuccessState:
                  final contacts = (state as ContactsSuccessState).users;
                  if (contacts.length == 0 && queryController.text.isNotEmpty) {
                    return Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(
                          color: AppColors.accentColor,
                          fontSize: 16,
                        ),
                      ),
                    );
                  } else if (contacts.length == 0) {
                    return Center(
                      child: Text(
                        'No contacts yet',
                        style: TextStyle(
                          color: AppColors.accentColor,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  if (contactsBloc.filterCondition == 'name' &&
                      contactsBloc.isAscending) {
                    return AlphabetScrollView(
                      overlayWidget: (value) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              value,
                              style: TextStyle(
                                color: AppColors.accentColor,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        );
                      },
                      selectedTextStyle: TextStyle(
                        color: AppColors.darkMainColor,
                        fontSize: 16,
                      ),
                      unselectedTextStyle: TextStyle(
                        color: AppColors.accentColor,
                        fontSize: 16,
                      ),
                      list: contacts.map((e) => AlphaModel(e.name)).toList(),
                      itemExtent: 100,
                      itemBuilder: (BuildContext, index, String) {
                        return GestureDetector(
                          onTap: () {
                            if (contacts[index].id == widget.currentUserId) {
                              return;
                            }
                            contactsBloc.add(ContactsClickChatroomEvent(
                              uid1: widget.currentUserId,
                              uid2: contacts[index].id,
                            ));
                          },
                          child: StreamBuilder(
                              stream: Rx.combineLatest2(
                                  ChatRepository().getChatMemberStream(
                                      widget.currentUserId, contacts[index].id),
                                  ChatRepository().getChatroomStream(
                                      widget.currentUserId, contacts[index].id),
                                  (ChatMemberModel? chatMemberModel,
                                      ChatroomModel? chatroomModel) {
                                return [chatMemberModel, chatroomModel];
                              }),
                              builder: (context, snapshot) {
                                var chatMemberModel =
                                    snapshot.data?[0] as ChatMemberModel?;
                                var chatroomModel =
                                    snapshot.data?[1] as ChatroomModel?;

                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ContactTile(
                                    myId: widget.currentUserId,
                                    userModel: contacts[index],
                                    chatMemberModel: chatMemberModel,
                                    chatroomModel: chatroomModel,
                                  ),
                                );
                              }),
                        );
                      },
                    );
                  } else {
                    return ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            if (contacts[index].id == widget.currentUserId) {
                              return;
                            }
                            contactsBloc.add(ContactsClickChatroomEvent(
                              uid1: widget.currentUserId,
                              uid2: contacts[index].id,
                            ));
                          },
                          child: StreamBuilder(
                              stream: Rx.combineLatest2(
                                  ChatRepository().getChatMemberStream(
                                      widget.currentUserId, contacts[index].id),
                                  ChatRepository().getChatroomStream(
                                      widget.currentUserId, contacts[index].id),
                                  (ChatMemberModel? chatMemberModel,
                                      ChatroomModel? chatroomModel) {
                                return [chatMemberModel, chatroomModel];
                              }),
                              builder: (context, snapshot) {
                                var chatMemberModel =
                                    snapshot.data?[0] as ChatMemberModel?;
                                var chatroomModel =
                                    snapshot.data?[1] as ChatroomModel?;

                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ContactTile(
                                    myId: widget.currentUserId,
                                    userModel: contacts[index],
                                    chatMemberModel: chatMemberModel,
                                    chatroomModel: chatroomModel,
                                  ),
                                );
                              }),
                        );
                      },
                    );
                  }

                default:
                  return Skeletion();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget searchBar() {
    return SizedBox(

      child: SearchBarAnimation(
        textEditingController: queryController,
        durationInMilliSeconds: 300,
        isSearchBoxOnRightSide: true,
        isOriginalAnimation: false,
        enableKeyboardFocus: true,
        buttonBorderColour: AppColors.accentColor,
        searchBoxBorderColour: AppColors.accentColor,
        buttonColour: AppColors.accentColor,
        hintTextColour: AppColors.accentColor,
        hintText: 'Search...',
        enteredTextStyle: TextStyle(
          color: AppColors.accentColor,
        ),
        onChanged: (value) {
          contactsBloc.query = value;
          contactsBloc.add(ContactsSearchEvent(
            
          ));
        },
        
        onCollapseComplete: () {
          if (!queryController.text.isEmpty) {
            queryController.clear();
            setState(() {
              contactsBloc.query = '';
            });
            contactsBloc.add(ContactsInitialEvent());
          }
        },
        trailingWidget: const Icon(Icons.search, color: AppColors.accentColor),
        secondaryButtonWidget: const Icon(
          Icons.close,
          color: AppColors.secondaryColor,
        ),
        buttonWidget: const Icon(
          Icons.search,
          color: AppColors.secondaryColor,
        ),
      ),
    );
  }
}

Skeletonizer Skeletion() {
  return Skeletonizer(
    enabled: true,
    child: ListView.builder(
      itemCount: 15,
      itemBuilder: (context, index) {
        return FakeContactTile(
          UserModel(
            id: BoneMock.country,
            name: BoneMock.name,
            avatarUrl: BoneMock.address,
            email: BoneMock.email,
            birthday: DateTime.now(),
            role: Role.student,
            gender: Gender.female,
          ),
        );
      },
    ),
  );
}

Widget FakeContactTile(UserModel userModel) {
  return Container(
    child: ListTile(
      leading: Container(
        width: 50,
        height: 50,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Skeleton.shade(
              child: Container(
            color: Colors.black.withOpacity(0.3),
          )),
        ),
      ),
      title: Text(
        userModel.name,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black.withOpacity(0.3),
        ),
      ),
      subtitle: Text(
        userModel.role.name,
        style: TextStyle(
          fontSize: 12,
          color: Colors.black.withOpacity(0.3),
        ),
      ),
      trailing: SizedBox(
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '2 hours ago',
              style:
                  TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 12),
            ),
            Text(
              'Hello, how are you?',
              maxLines: 1,
              style:
                  TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}

String filterConditionToField(String filterCondition) {
  switch (filterCondition) {
    case 'name':
      return 'name';
    case 'role':
      return 'role';
    default:
      return 'name';
  }
}




