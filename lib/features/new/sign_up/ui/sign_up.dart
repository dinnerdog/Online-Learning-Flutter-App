import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/auth_repository.dart';
import 'package:test1/data/repo/user_repository.dart';
import 'package:test1/features/new/home/ui/home.dart';
import 'package:test1/features/new/router.dart';
import 'package:test1/features/new/sign_up/bloc/sign_up_bloc.dart';
import 'package:test1/global/common/image_picker_uploader.dart';
import 'package:test1/global/common/toast.dart';
import 'package:test1/global/extension/string.dart';
import 'package:test1/main.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String? _selectedGender;
  String? _selectedRole;
  String? _selectedAvatarUrl;

  DateTime? _selectedDate;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mottoController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _classController = TextEditingController();

  SignUpBloc signUpBloc = SignUpBloc(
      authRepository: AuthRepository(), userRepository: UserRepository());

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        foregroundColor: AppColors.secondaryColor,
      ),
      body: BlocConsumer<SignUpBloc, SignUpState>(
        bloc: signUpBloc,
        listenWhen: (previous, current) => current is SignUpActionState,
        buildWhen: (previous, current) => current is! SignUpActionState,
        listener: (context, state) {
          if (state is SignUpSubmitSuccessState) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Home(user: state.user )),
              (Route<dynamic> route) => false, 
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Text("Sign Up",
                          style: TextStyle(
                              fontSize: 46,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mainColor)),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: Column(
                        children: [
                          Text(
                            'Select your Avatar here: (*)',
                            style: TextStyle(color: AppColors.mainColor),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: ImagePickerUploader(
                                  category: 'avatar',
                                  onUrlUploaded: (url) {
                                    setState(() {
                                      _selectedAvatarUrl = url;
                                    });
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),

                    TextField(
                      controller: _nameController,
                      maxLength: 20,
                      decoration: InputDecoration(
                        helperText: "Enter your preferred name (required*)",
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
                        labelText: 'Name',
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        helperText: "Enter your email address (required*)",
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
                    ),

                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        helperText:
                            "Enter your password, at least 6 characters (required*)",
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
                    ),

                    // String id;
                    // String name;
                    // String email;
                    // Role role;
                    // Gender gender;
                    // DateTime birthday;
                    // String? phoneNumber;
                    // String? address;
                    // String? motto;
                    // String? classId;
                    // String? avatarUrl;
                    // List<String>? createdActivityIds;

                    SizedBox(
                      height: 30,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select your Gender here: (*)',
                              style: TextStyle(color: AppColors.mainColor),
                            ),
                            DropdownButton<String>(
                              value: _selectedGender,
                              hint: Text("Select Gender"),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedGender = newValue;
                                });
                              },
                              items: ['male', 'female', 'non-binary']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select your Role here: (*)',
                              style: TextStyle(color: AppColors.mainColor),
                            ),
                            DropdownButton<String>(
                              value: _selectedRole,
                              hint: Text("Select Role"),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedRole = newValue;
                                });
                              },
                              items: ['student', 'teacher'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select your Birthday here: (*)',
                              style: TextStyle(color: AppColors.mainColor),
                            ),
                            TextButton.icon(
                              onPressed: () => _selectDate(context),
                              icon: Icon(Icons.calendar_today),
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        AppColors.secondaryColor),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        AppColors.mainColor),
                              ),
                              label: Text(_selectedDate == null
                                  ? 'Select Your Birthday'
                                  : 'Birthday: ${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}'),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 30,
                    ),

                    TextField(
                      controller: _mottoController,
                      maxLength: 500,
                      decoration: InputDecoration(
                        helperText: "Enter your motto for kindness (optional)",
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
                        labelText: 'Motto',
                      ),
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    TextField(
                      controller: _phoneNumberController,
                      maxLength: 20,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        helperText: "Enter your phone number (optional)",
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
                        labelText: 'Phone number',
                      ),
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    TextField(
                      controller: _classController,
                      maxLength: 100,
                      decoration: InputDecoration(
                        helperText:
                            "Enter the class you belong to, if you had one (optional)",
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
                        labelText: 'class',
                      ),
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: TextButton.icon(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              AppColors.mainColor),
                          foregroundColor: MaterialStateProperty.all<Color>(
                              AppColors.secondaryColor),
                        ),
                        onPressed: () {
                          if (state is SignUpSubmitLoadingState) return;

                          if (_selectedGender != null &&
                              _selectedRole != null &&
                              _selectedDate != null) {

                            signUpBloc.add(SignUpSubmitEvent(
                              user: UserModel(
                                  id: '',
                                  avatarUrl: _selectedAvatarUrl,
                                  phoneNumber: _phoneNumberController.text,
                                  motto: _mottoController.text,
                                  classId: _classController.text,
                                  name: _nameController.text,
                                  email: _emailController.text,
                                  role: _selectedRole!.toRole(),
                                  birthday: _selectedDate!,
                                  gender: _selectedGender!.toGender()),
                              password: _passwordController.text,
                            ));
                          } else {
                            showToast(message: 'Please fill all the fields');
                          }
                        },
                        icon: const Icon(Icons.person_add),
                        label: state is SignUpSubmitLoadingState
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text('Sign Up'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
