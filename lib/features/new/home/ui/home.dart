import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/features/new/activity/ui/activity.dart';
import 'package:test1/features/new/contacts/ui/contacts.dart';
import 'package:test1/features/new/course/ui/course.dart';
import 'package:test1/features/new/games/ui/games.dart';
import 'package:test1/features/new/home/bloc/bloc/home_bloc.dart';
import 'package:test1/features/new/home/bloc/bloc/menu_bloc.dart';
import 'package:test1/features/new/profile/ui/profile.dart';
import 'package:test1/global/common/split_view.dart';
import 'package:test1/main.dart';

class Home extends StatefulWidget {
  final UserModel user;

  const Home({super.key, required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  HomeBloc homeBloc = HomeBloc();
  MenuBloc menuBloc = MenuBloc();
  String _selectedMenuItem = 'Activity';

  @override
  void initState() {
    super.initState();

    homeBloc.add(HomeInitialEvent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => menuBloc,
      child: BlocConsumer<HomeBloc, HomeState>(
        bloc: homeBloc,
        listenWhen: (previous, current) => current != previous,
        buildWhen: (previous, current) => current != previous,
        listener: (context, state) {},
        builder: (context, state) {
          return SplitView(
            
              menu: appMenu(widget.user, homeBloc, _selectedMenuItem, menuBloc),
              content: appContent(state, widget.user));
        },
      ),
    );
  }

  Widget menuTile(String title, IconData icon, Color iconColor, Function onTap,
      bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMenuItem = title;
          onTap();
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin:
            isSelected ? EdgeInsets.symmetric(horizontal: 10) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondaryColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor,
                      Color.lerp(iconColor, Colors.white, 0.3)!
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              SizedBox(width: 10),
              SizedBox(
                width: double.maxFinite,
                child: Text(
                  title,
                  style: TextStyle(
                      color: AppColors.secondaryColor,
                      fontWeight: FontWeight.w300),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget appMenu(
      UserModel user, HomeBloc homebloc, _selectedMenuItem, MenuBloc menuBloc) {
    return BlocBuilder<MenuBloc, MenuState>(
      bloc: menuBloc,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.mainColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('Kind Hearts',
                style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.mainColor,
            foregroundColor: Colors.white,
          ),
          body: ListView(
                  children: [
                    menuTile('Course', Icons.class_, Colors.orange, () {
                      _selectedMenuItem = 'Course';
                      homebloc.add(HomeNavigateToCourseEvent(user.id));
                    }, _selectedMenuItem == 'Course'),
                    menuTile('Profile', Icons.person, Colors.blue, () {
                      _selectedMenuItem = 'Profile';
                      homebloc.add(HomeNavigateToProfileEvent());
                    }, _selectedMenuItem == 'Profile'),
                    menuTile('Contacts', Icons.contacts, Colors.green, () {
                      _selectedMenuItem == 'Contacts';
                      homebloc.add(HomeNavigateToContactsEvent(user.id));
                    }, _selectedMenuItem == 'Contacts'),
                    menuTile('Games', Icons.gamepad, Colors.red, () {
                      _selectedMenuItem = 'Games';
                      homebloc.add(HomeNavigateToGamesEvent());
                    }, _selectedMenuItem == 'Games'),
                    menuTile(
                      'Activity',
                      Icons.event,
                      Colors.pink,
                      () {
                        _selectedMenuItem == 'Activity';
                        homebloc.add(HomeNavigateToActivityEvent());
                      },
                      _selectedMenuItem == 'Activity',
                    ),
                  ],
                )
            
        );
      },
    );
  }
}

Widget appContent(HomeState state, UserModel user) {
  Widget? currentWidget;
  switch (state) {
    case HomeNavigateToProfileActionState():
      currentWidget = Profile();
      break;
    case HomeNavigateToActivityActionState():
      currentWidget = Activity(
        user: user,
      );
      break;
    case HomeNavigateToContactsActionState():
      currentWidget = Contacts(currentUserId: user.id);
      break;
    case HomeNavigateToCourseActionState():
      currentWidget = Course(user: user);
      break;
    case HomeNavigateToGamesActionState():
      currentWidget = Games(user: user,);
      break;
    default:
      currentWidget = Activity(
        user: user,
      );
  }

  return currentWidget;
}
