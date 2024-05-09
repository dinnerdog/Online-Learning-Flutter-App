import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/data/model/assignment_model.dart';
import 'package:test1/data/repo/assignment_repository.dart';
import 'package:test1/features/new/course/subviews/course_detail/subviews/add_assignment/bloc/add_assignment_bloc.dart';
import 'package:test1/global/common/image_picker_uploader.dart';
import 'package:test1/global/common/toast.dart';
import 'package:test1/global/helper/image_picker_uploader_helper.dart';
import 'package:test1/main.dart';

class AddAssignment extends StatefulWidget {
  final String courseId;
  final AssignmentModel? assignment;

  const AddAssignment({super.key, required this.courseId, this.assignment});

  @override
  State<AddAssignment> createState() => _AddAssignmentState();
}

class _AddAssignmentState extends State<AddAssignment> {
  AddAssignmentBloc addAssignmentBloc = AddAssignmentBloc();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _submissionInstructionsController =
      TextEditingController();
  var isLoading = false;
  var isQuiz = false;
  String? _imageUrl;
  DateTime _deadline = DateTime.now();


  

  @override
  void initState() {
    if (widget.assignment != null) {
      _nameController.text = widget.assignment!.name;
      _descriptionController.text = widget.assignment!.description ?? '';
      _submissionInstructionsController.text =
          widget.assignment!.submissionInstructions;
      _imageUrl = widget.assignment!.imageUrl;
      _deadline = widget.assignment!.deadLine;
    }
    super.initState();
  }

  TextField textEditer(TextEditingController controller, String labelText,
      String helperText, int maxLength) {
    return TextField(
      controller: controller,
      maxLines: null,
      style: TextStyle(color: AppColors.mainColor),
      maxLength: maxLength,
      decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.mainColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.mainColor),
          ),
          labelText: labelText,
          helperText: helperText,
          counterStyle: TextStyle(color: AppColors.mainColor),
          labelStyle: TextStyle(color: AppColors.mainColor)),
    );
  }

  Widget DatePicker(BuildContext context, DateTime? date, String description,
      Function(DateTime) onChange) {
    return ListTile(
      title: Text(
          date == null
              ? 'Pick a due for the assignment'
              : 'Due: ${date.toIso8601String().split('T')[0]}',
          style: TextStyle(color: AppColors.mainColor)),
      subtitle: Text(
        description,
      ),
      trailing: Icon(Icons.calendar_today, color: AppColors.mainColor),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime(2026),
        );

        if (picked != null && picked != date) {
          onChange(
            picked,
          );
        }
      },
    );
  }

  Widget coverEditer() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.mainColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.image, color: AppColors.mainColor),
            title: Text('Cover for Assignment',
                style: TextStyle(color: AppColors.mainColor)),
            subtitle: Text(
              'Pick an image to be the cover image for the assignment.',
            ),
          ),
          Container(
            width: double.maxFinite,
            height: 300,
            child: ImagePickerUploader(
                category: 'assignment_cover',
                initialImageUrl: _imageUrl,
                onUrlUploaded: (url) {
                  setState(() {
                    _imageUrl = url;
                  });
                }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        foregroundColor: AppColors.secondaryColor,
        title: Text('Add Assignment'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              coverEditer(),
              SizedBox(height: 20),
              textEditer(_nameController, 'Please enter the name of assignment',
                  'Enter name', 50),
              SizedBox(height: 20),
              textEditer(
                  _descriptionController,
                  'Please enter the description of assignment',
                  'Enter description',
                  2000),
              SizedBox(height: 20),
              textEditer(
                  _submissionInstructionsController,
                  'Please enter the submission instructions of assignment',
                  'Enter submission Instructions',
                  1000),
              SizedBox(height: 20),
              DatePicker(
                  context, _deadline, 'Pick a due date for the assignment',
                  (date) {
                setState(() {
                  _deadline = date;
                });
              }),

              // ListTile(
              //   title: Text('Is this a Quiz?'),
              //   subtitle: Text('Toggle to set if this is a quiz or not '),
              //   trailing:

              // AnimatedToggleSwitch<bool>.dual(
              //    borderWidth: 2,
              //             onChanged: (b) {
              //               setState(() {
              //                 isQuiz = b;
              //               });
              //             },
              //   current: isQuiz,
              //   styleBuilder: (b) => ToggleStyle(
              //     indicatorColor:
              //         b ? AppColors.accentColor : AppColors.secondaryColor,
              //     backgroundColor:
              //         b ? AppColors.secondaryColor : AppColors.accentColor,
              //     borderColor:
              //         b ? AppColors.secondaryColor : AppColors.secondaryColor,
              //   ),
              //   textBuilder: (value) => value
              //       ? Center(
              //           child: Text('Quiz',
              //               style: TextStyle(
              //                   fontSize: 12, color: AppColors.accentColor)))
              //       : Center(
              //           child: Text('not a Quiz',
              //               style: TextStyle(
              //                   fontSize: 12,
              //                   color: AppColors.secondaryColor))),
              //   style: ToggleStyle(
              //     indicatorColor: AppColors.accentColor,
              //     backgroundColor: AppColors.secondaryColor,
              //   ),
              //   first: true,
              //   second: false,
                
              //   iconBuilder: (b) => b
              //       ? Icon(Icons.sort_rounded, color: AppColors.secondaryColor)
              //       : Icon(Icons.sort_rounded, color: AppColors.accentColor),
              // ),

              // ),


              // if (isQuiz)
              //   Container(
              //     color:  AppColors.secondaryColor,
              //     child: Column(
              //       children: [
              //         TextButton.icon(onPressed: (){}, icon: Icon(Icons.add),
              //         label: Text('Add Question'),
              //         style: ButtonStyle(
              //           backgroundColor: MaterialStateProperty.all(AppColors.mainColor),
              //           foregroundColor: MaterialStateProperty.all(AppColors.secondaryColor),
              //         ),

              //         ),
                      
                  
                      
                      
              //       ],
              //     ),
              //   ),

              BlocListener<AddAssignmentBloc, AddAssignmentState>(
                listener: (context, state) {
                  if (state is AddAssignmentSubmitLoadingState) {
                    setState(() {
                      isLoading = true;
                    });
                  } else if (state is AddAssignmentSubmitSuccessState) {
                    setState(() {
                      isLoading = false;
                      Navigator.of(context).pop();
                    });
                  } else {
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                bloc: addAssignmentBloc,
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(AppColors.mainColor),
                      foregroundColor:
                          MaterialStateProperty.all(AppColors.secondaryColor),
                    ),
                    onPressed: () async {
                      if (isLoading) {
                        return;
                      }

                      if (_nameController.text.isNotEmpty &&
                          _descriptionController.text.isNotEmpty &&
                          _submissionInstructionsController.text.isNotEmpty &&
                          _imageUrl != null &&
                          _deadline != null) {
                        if (widget.assignment == null) {
                          addAssignmentBloc.add(
                            AddAssignmentSubmitEvent(
                                courseId: widget.courseId,
                                assignment: AssignmentModel(
                                  id: '',
                                  courseId: widget.courseId,
                                  name: _nameController.text,
                                  description: _descriptionController.text,
                                  imageUrl: _imageUrl,
                                  deadLine: _deadline,
                                  assignedDate: DateTime.now(),
                                  submissionInstructions:
                                      _submissionInstructionsController.text,
                                )),
                          );
                        } else {
                          addAssignmentBloc.add(
                            UpdateAssignmentSubmitEvent(
                                courseId: widget.courseId,
                                assignment: AssignmentModel(
                                  id: widget.assignment!.id,
                                  courseId: widget.courseId,
                                  name: _nameController.text,
                                  description: _descriptionController.text,
                                  imageUrl: _imageUrl,
                                  deadLine: _deadline,
                                  assignedDate: widget.assignment!.assignedDate,
                                  submissionInstructions:
                                      _submissionInstructionsController.text,
                                )),
                          );
                        }
                      } else {
                        showToast(message: 'please fill all fields');
                      }
                    },
                    child: isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.secondaryColor))
                        : Text('submit')),
              )
            ],
          ),
        ),
      ),
    );
  }
}
