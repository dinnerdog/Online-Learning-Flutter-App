import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/data/repo/auth_repository.dart';
import 'package:test1/features/new/home/ui/home.dart';
import 'package:test1/features/new/login/bloc/login_bloc.dart';
import 'package:test1/features/new/router.dart';
import 'package:test1/main.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final LoginBloc loginBloc = LoginBloc(authRepository: AuthRepository());
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        foregroundColor: AppColors.secondaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: BlocConsumer<LoginBloc, LoginState>(
            bloc: loginBloc,
            listenWhen: (previous, current) => current is LoginActionState,
            buildWhen: (previous, current) => current is! LoginActionState,
            listener: (context, state) {
              if (state is LoginSubmitSuccessState) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => Home(
                              user: state.user,
                            )),
                   (route) => false);
              }
            },
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Text("Login",
                          style: TextStyle(
                              fontSize: 46,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mainColor)),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        helperText: "Enter your email address",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.mainColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.mainColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.mainColor),
                        ),
                        counterStyle: TextStyle(color: AppColors.mainColor),
                        labelStyle: TextStyle(color: AppColors.mainColor),
                        labelText: 'Email',
                      ),
                      controller: _emailController,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextField(
                        obscureText: true,
                           decoration: InputDecoration(
                          
                        
                        helperText: "Enter your password",
                        
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.mainColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.mainColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.mainColor),
                        ),
                        counterStyle: TextStyle(color: AppColors.mainColor),
                        labelStyle: TextStyle(color: AppColors.mainColor),
                        labelText: 'Password',
                      ),
                      controller: _passwordController,
                     
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: double.infinity,
                           
                      child:  TextButton.icon(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              AppColors.mainColor),
                          foregroundColor: MaterialStateProperty.all<Color>(
                              AppColors.secondaryColor),
                        ),
                        onPressed: () async {
                          if (state is LoginSubmitLoadingState) return;
                
                          loginBloc.add(LoginSubmitEvent(
                            email: _emailController.text,
                            password: _passwordController.text,
                          ));
                        },
                        icon: const Icon(Icons.login),
                        label: state is LoginSubmitLoadingState
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text('Login'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

void _showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.mainColor),
            ),
            SizedBox(height: 20),
            Text("Saving...", style: TextStyle(color: AppColors.mainColor)),
          ],
        ),
      );
    },
  );
}
