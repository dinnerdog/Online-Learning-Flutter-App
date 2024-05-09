import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/auth_repository.dart';
import 'package:test1/features/new/home/bloc/bloc/menu_bloc.dart';
import 'package:test1/features/new/profile/bloc/profile_bloc.dart';
import 'package:test1/features/new/profile/subviews/my_trophies/ui/my_trophies.dart';
import 'package:test1/features/new/profile/subviews/profile_edit.dart/ui/profile_edit.dart';
import 'package:test1/features/new/welcome/ui/welcome.dart';
import 'package:test1/global/common/image_picker_uploader.dart';
import 'package:test1/main.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  ProfileBloc profileBloc = ProfileBloc();
  GlobalKey<SliderDrawerState> _key = GlobalKey<SliderDrawerState>();

  @override
  void initState() {
    super.initState();
    profileBloc.add(UserSubscriptionRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      bloc: profileBloc,
      listenWhen: (previous, current) => current is ProfileActionState,
      buildWhen: (previous, current) => current is! ProfileActionState,
      listener: (context, state) {
        // Listener implementation
      },
      builder: (context, state) {
        if (state is ProfileSuccessState) {
          final user = state.user;
          final stars = state.stars;

          return SliderDrawer(
            appBar: null,
            key: _key,

              slider: slider(user, stars, context),

            
            child: Scaffold(
              backgroundColor: AppColors.secondaryColor,
              appBar: AppBar(
                toolbarHeight: 80,
                automaticallyImplyLeading: false,
                leading:  IconButton(
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all(AppColors.secondaryColor),
                      backgroundColor:
            
                          MaterialStateProperty.all(AppColors.accentColor),
                    ),
                      onPressed: () {
                        _key.currentState!.toggle();
                      },
                      icon: Icon(
                        Icons.menu,
                      )),
                title: Text('Profile'),
                foregroundColor: AppColors.mainColor,
                backgroundColor: AppColors.secondaryColor,
                actions: [
                 
                  IconButton(
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all(AppColors.secondaryColor),
                      backgroundColor:
                          MaterialStateProperty.all(AppColors.accentColor),
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

              body: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    basicInfo(user),
                    
                    trophyWall(state),
                    ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileEdit(
                                  user: state.user,

                                )));
                        
                      },


                      textColor: AppColors.mainColor,
                      iconColor: AppColors.mainColor,
                      title: Text('Edit Profile'),
                      subtitle: Text('Edit your profile information'),
                      leading: Icon(Icons.edit),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyTrophies(
                                  courseUsers: state.courseUsers,
                                  incentiveModel: state.incentiveModel,
                                  user: state.user,
                                )));
                      },
                      textColor: AppColors.mainColor,
                      iconColor: AppColors.mainColor,
                      title: Text('Print my trophies'),
                      subtitle: Text('Tap to print your trophies'),
                      leading: Icon(Icons.print),
                    ),
                
                   
                   
                  ],
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: AppColors.secondaryColor,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Container basicInfo(UserModel user) {
    return Container(
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CachedNetworkImage(
                          imageUrl: user!.avatarUrl!,
                          imageBuilder: (context, imageProvider) =>
                              Container(
                                width: 150,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )),
                      SizedBox(width: 50),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mainColor),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                                fontSize: 16, color: AppColors.mainColor),
                          ),
                          SizedBox(height: 5),
                          Text(
                              user.role.name[0].toUpperCase() +
                                  user.role.name.substring(1),
                              style: TextStyle(
                                  fontSize: 16, color: AppColors.mainColor))
                        ],
                      ),
                    ],
                  ),
                  );
  }

  Row trophyWall(ProfileSuccessState state) {
    return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                '🌟',
                                style: TextStyle(fontSize: 24),
                              ),
                              Text(
                                '${state.stars}',
                                style: TextStyle(color: AppColors.mainColor),
                              ),
                            ],
                          ),
                          Text('stars',
                              style: TextStyle(color: AppColors.mainColor)),
                        ],
                      ),
                      Container(
                        width: 2,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.accentColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                '🎖️',
                                style: TextStyle(fontSize: 24),
                              ),
                              Text(
                                '${state.incentiveModel.badges.length}',
                                style: TextStyle(color: AppColors.mainColor),
                              ),
                            ],
                          ),
                          Text('badges',
                              style: TextStyle(color: AppColors.mainColor)),
                        ],
                      ),
                      Container(
                        width: 2,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.accentColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                '🎓',
                                style: TextStyle(fontSize: 24),
                              ),
                              Text(
                                '${state.incentiveModel.certificates.length}',
                                style: TextStyle(color: AppColors.mainColor),
                              ),
                            ],
                          ),
                          Text('certificates',
                              style: TextStyle(color: AppColors.mainColor)),
                        ],
                      ),
                    ],
                  );
  }



  SingleChildScrollView slider(UserModel user, int stars, BuildContext context) {
    return SingleChildScrollView(
              child: Container(
                color: AppColors.accentColor,
                height: MediaQuery.of(context).size.height,
                child: Column(


                  children: [
                    SizedBox(height: 20),
                   Container(

                      color: AppColors.secondaryColor,
                     child: ListTile(
                      onTap: () async {

                        await   AuthRepository().signOut();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Welcome()));
                     
                      },

                      leading: Icon(Icons.cancel_presentation_outlined, color: AppColors.accentColor),
                      subtitle: Text('Tap to sign out', style: TextStyle(color: AppColors.accentColor)),

                      tileColor: AppColors.secondaryColor,
                      title: Text('Sign Out', style: TextStyle(color: AppColors.accentColor)),
                     
                     ),
                   )
                  
                  ],
                ),
              ),
            );
  }
}
