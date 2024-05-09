import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/data/repo/auth_repository.dart';
import 'package:test1/data/repo/user_repository.dart';
import 'package:test1/features/new/home/ui/home.dart';
import 'package:test1/features/new/router.dart';
import 'package:test1/features/new/welcome/bloc/welcome_bloc.dart';
import 'package:test1/main.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final WelcomeBloc welcomeBloc = WelcomeBloc(
      userRepository: UserRepository(), authRepository: AuthRepository());

  @override
  void initState() {
    super.initState();
    welcomeBloc.add(WelcomeInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WelcomeBloc, WelcomeState>(
      bloc: welcomeBloc,
      listenWhen: (previous, current) => current is WelcomeActionState,
      buildWhen: (previous, current) => current is! WelcomeActionState,
      listener: (context, state) {
        if (state is WelcomeNavigateToSignInActionState) {
          Navigator.of(context).pushNamed(AppRouter.signIn);
        } else if (state is WelcomeNavigateToSignUpActionState) {
          Navigator.of(context).pushNamed(AppRouter.signUp);
        } else if (state is WelcomeNavigateToHomeActionState) {
          Navigator.of(context).pushReplacement(PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 500), // 动画时长为1秒
            pageBuilder: (context, animation, secondaryAnimation) => Home(
              user: state.userModel,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ));
        }
      },
      builder: (context, state) {
        switch (state.runtimeType) {
          case WelcomeLoadingState:
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );

          case WelcomeLoadedwithUserState:
            final userModel = (state as WelcomeLoadedwithUserState).userModel;
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Welcome ${userModel.name}",
                        style: TextStyle(
                            fontSize: 46, fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 200,
                    ),
                  ],
                ),
              ),
            );

          case WelcomeLoadedWithoutUserState:
            return Scaffold(

              body: Stack(
                children: [


                    
                  
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                     color:AppColors.secondaryColor,
                      ),

                  ),

                 
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      
                          SizedBox(
                            height: 100,
                          ),
                                        
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                               shape: BoxShape.circle,
                                color: AppColors.mainColor),
                            child: Image.asset('assets/app_images/kind_hearts.png')),
                          Text("Welcome",
                              style: TextStyle(
                                  fontSize: 46, fontWeight: FontWeight.bold, color: AppColors.mainColor)),
                          SizedBox(
                            height: 200,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width ,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                  foregroundColor: AppColors.secondaryColor,
                                  backgroundColor: AppColors.mainColor),
                              onPressed: () {
                                welcomeBloc.add(ClickSignInNavigatonEvent());
                              },
                              label: Text('Sign In'),
                              icon: Icon(Icons.login),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: TextButton.icon(
                               style: TextButton.styleFrom(
                                  foregroundColor: AppColors.secondaryColor,
                                  backgroundColor: AppColors.mainColor),
                              onPressed: () {
                                welcomeBloc.add(ClickSignUpNavigationEvent());
                              },
                              label: Text('Sign Up'),
                              icon: Icon(Icons.person_add),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            );

          default:
            return Center(
              child: Text('Welcome default'),
            );
        }
      },
    );
  }
}
