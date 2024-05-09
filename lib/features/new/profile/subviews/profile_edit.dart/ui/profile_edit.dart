import 'package:flutter/material.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/user_repository.dart';
import 'package:test1/global/common/image_picker_uploader.dart';
import 'package:test1/global/common/toast.dart';
import 'package:test1/global/helper/image_picker_uploader_helper.dart';
import 'package:test1/main.dart';

class ProfileEdit extends StatefulWidget {
  final UserModel user;
  const ProfileEdit({super.key, required this.user});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  String? _selectedAvatarUrl;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mottoController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _classController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _selectedAvatarUrl = widget.user.avatarUrl;

    _nameController.text = widget.user.name;
    _mottoController.text = widget.user.motto ?? '';
    _phoneNumberController.text = widget.user.phoneNumber ?? '';
    _classController.text = widget.user.classId ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        foregroundColor: AppColors.secondaryColor,
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Text("Edit your Profile here:",
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
                            initialImageUrl: _selectedAvatarUrl,
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
                height: 20,
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
                    backgroundColor:
                        MaterialStateProperty.all<Color>(AppColors.mainColor),
                    foregroundColor: MaterialStateProperty.all<Color>(
                        AppColors.secondaryColor),
                  ),
                  onPressed: ()  async {
                    if (_nameController.text.isNotEmpty) {

                       _showLoadingDialog(context);

                      try {

                        if (!_selectedAvatarUrl!.startsWith('http')) {
                         _selectedAvatarUrl =  await ImagePickerUploaderHelper.uploadImage(
                            category: 'avatar',
                            id: widget.user.id,
                            imageUrl: _selectedAvatarUrl!,
                          );

                        }
                    await     UserRepository().updateUserDynamicField(
                          {
                            'name': _nameController.text,
                            'motto': _mottoController.text,
                            'phoneNumber': _phoneNumberController.text,
                            'classId': _classController.text,
                            'avatarUrl': _selectedAvatarUrl,
                          },
                        );
                      } catch (e) {
                        showToast(message: e.toString());
                      }
  Navigator.of(context).pop();
                    
                    } else {
                      showToast(message: 'You cannot have no name!');
                    }
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Submit'),
                ),
              ),
            ],
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