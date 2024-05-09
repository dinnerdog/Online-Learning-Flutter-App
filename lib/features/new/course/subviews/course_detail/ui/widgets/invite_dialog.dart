import 'package:flutter/material.dart';
import 'package:test1/data/model/course_user_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/course_user_repository.dart';
import 'package:test1/global/common/toast.dart';
import 'package:test1/main.dart';


class UserSelection {
  UserModel user;
  bool isSelected;


  UserSelection({required this.user, this.isSelected = false});
}



class InviteDialog extends StatefulWidget {
  final List<UserModel> allUsers;
  final List<CourseUserModel> courseUsers;
  final String courseId;

  InviteDialog({super.key, required this.allUsers, required this.courseUsers, required this.courseId});

  @override
  State<InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<InviteDialog> {
  final TextEditingController _searchController = TextEditingController();
 late List<UserSelection> userSelections;

  @override
  void initState() {
     userSelections = widget.allUsers
        .map((user) => UserSelection(user: user))
        .toList();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {  

    return AlertDialog(
      backgroundColor: AppColors.mainColor,
      iconColor: AppColors.mainColor,
      titleTextStyle: TextStyle(color: AppColors.secondaryColor),
      contentTextStyle: TextStyle(color: AppColors.mainColor),
      title: Column(
        children: [
          Align(
              alignment: Alignment.topLeft,
              child:
                  Text("Invite the students", style: TextStyle(fontSize: 24))),
          SizedBox(height: 10),
          Container(
            width: double.maxFinite,
            height: 50,
            child: SearchBar(
              leading: Icon(Icons.search),
              autoFocus: true,
              hintText: 'Search students and invite them',
              controller: _searchController,
            onChanged: (query) async {
  setState(() {
    userSelections = widget.allUsers
        .where((user) {
        
         return   user.name.toLowerCase().contains(query.toLowerCase()) ||
          user.email.toLowerCase().contains(query.toLowerCase()) ||
          user.classId!.toLowerCase().contains(query.toLowerCase());

        
        })
        .map((user) => UserSelection(user: user, isSelected: userSelections.firstWhere((selection) => selection.user.id == user.id, orElse: () => UserSelection(user: user)).isSelected))
        .toList();

 
    
  });
}

            ),
          )
        ],
      ),
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          
          itemCount: userSelections.length,
          itemBuilder: (context, index) {
            final userSelection = userSelections[index];
            bool isInvited = widget.courseUsers
                .any((courseUser) => courseUser.userId == userSelection.user.id);


            return Container(
              decoration: BoxDecoration(
      
               border: Border(bottom: BorderSide(color: AppColors.secondaryColor, width: 0.5))
              ),
              
              child: ListTile(
                selected: isInvited,
                selectedColor: AppColors.secondaryColor,
                // selectedTileColor: AppColors.accentColor,
                
                textColor: AppColors.secondaryColor,
                title: Text(userSelection.user.name),
                subtitle: Text(userSelection.user.classId == '' ? userSelection.user.email : userSelection.user.classId!),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(userSelection.user.avatarUrl!),
                ),
                enabled: !isInvited,
                trailing: isInvited ? Text('Already Enrolled') :
                 Checkbox(
                  fillColor: MaterialStateProperty.all(AppColors.secondaryColor),
                  checkColor: AppColors.mainColor,
                  activeColor: AppColors.secondaryColor,
                  side: BorderSide(color: AppColors.secondaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  value: userSelection.isSelected
                  
                , onChanged: (value){
                  setState(() {
                    userSelection.isSelected = value!;
                  });
              
                }),
                onTap: () {
                  if (isInvited) {
                    return;
                  }
                  setState(() {
                    userSelection.isSelected = !userSelection.isSelected;
                  });

                  //To Do
                  // Invite the user
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton.icon(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () {
            // TO DO
            _showConfrimDialog(context, userSelections, widget.courseId);
          },
          icon: Icon(Icons.person_add),
          label: Text('Invite'),
        ),
        TextButton.icon(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.close),
          label: Text('Cancel'),
        ),
      ],
    );
  }
}



void _showConfrimDialog(BuildContext context, List<UserSelection> selectedUsers, String courseId) {
  showDialog(
    context: context,
    builder: (context) {
      selectedUsers = selectedUsers.where((user) => user.isSelected).toList();

      return  AlertDialog(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to invite the selected students?', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text('${selectedUsers.length} students selected', style: TextStyle(fontSize: 18)),

          ],
        ),
          backgroundColor: AppColors.mainColor,
      iconColor: AppColors.mainColor,
      titleTextStyle: TextStyle(color: AppColors.secondaryColor),
      contentTextStyle: TextStyle(color: AppColors.mainColor),
      content: Container(
        decoration: BoxDecoration(
          // color: AppColors.accentColor,
          borderRadius: BorderRadius.circular(10)
        ),
        width: MediaQuery.of(context).size.width * 0.6,
        child: ListView.builder(
          itemCount: selectedUsers.length,
          itemBuilder: (context, index) {
            final user = selectedUsers[index].user;
            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.secondaryColor, width: 0.5))
              ),
              child: ListTile(
                
                textColor: AppColors.secondaryColor,
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.avatarUrl!),
                ),
                title: Text(user.name),
                subtitle: Text(user.classId == '' ? user.email : user.classId!),
                
              ),
            );
          },
        ),
      ),
        actions: [
          TextButton(
             style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
             style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
            onPressed: () async {
              _showLoadingDialog(context);
            try {
              
            
               await  CourseUserRepository().addCourseUserByCourseIdAndUserIds(
               courseId,
                selectedUsers.map((user) => user.user.id).toList()
              );
              


       

              showToast(message: 'Students invited successfully');  
              Navigator.of(context).pop();
              Navigator.of(context).pop();
                Navigator.of(context).pop();
            } catch (e) {
              Navigator.of(context).pop();
              showToast(message: e.toString());
            }
            },
            child: Text('Invite'),
          ),
        ],
      );
    },
  );
}


void _showLoadingDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.mainColor,
      iconColor: AppColors.mainColor,
      titleTextStyle: TextStyle(color: AppColors.secondaryColor),
      contentTextStyle: TextStyle(color: AppColors.mainColor),

        title: Text('Inviting students...'),
        content: SizedBox(
          height: 100,
        
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),
            ),
          ),
        ),
      );
    },
  );
}
