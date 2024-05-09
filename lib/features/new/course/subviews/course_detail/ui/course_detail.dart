import 'package:cached_network_image/cached_network_image.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:test1/data/model/assignment_model.dart';
import 'package:test1/data/model/assignment_user_model.dart';
import 'package:test1/data/model/course_model.dart'; // 假设的课程模型
import 'package:test1/data/model/course_user_model.dart';
import 'package:test1/data/model/user_model.dart'; // 假设的用户模型
import 'package:test1/data/repo/assignment_repository.dart';
import 'package:test1/data/repo/assignment_user_repository.dart';
import 'package:test1/data/repo/course_user_repository.dart';
import 'package:test1/data/repo/incentives_repository.dart';
import 'package:test1/data/repo/user_repository.dart'; // 假设的数据仓库
import 'package:test1/features/new/contacts/subviews/chatroom/ui/chatroom.dart';
import 'package:test1/features/new/course/subviews/course_detail/bloc/course_detail_bloc.dart';
import 'package:test1/features/new/course/subviews/course_detail/subviews/add_assignment/ui/add_assignment.dart';
import 'package:test1/features/new/course/subviews/course_detail/subviews/assignment_completion_detail/ui/assignment_completion.dart';
import 'package:test1/features/new/course/subviews/course_detail/subviews/assignment_portal/ui/assignment_portal.dart';
import 'package:test1/features/new/course/subviews/course_detail/subviews/assignment_resources/assignment_resources.dart';
import 'package:test1/features/new/course/subviews/course_detail/subviews/course_progress/ui/course_progress.dart';
import 'package:test1/features/new/course/subviews/course_detail/ui/widgets/invite_dialog.dart';
import 'package:test1/global/common/build_badge.dart';
import 'package:test1/global/common/image_picker_uploader.dart';
import 'package:test1/global/common/toast.dart';
import 'package:test1/global/extension/date_time.dart';
import 'package:test1/main.dart';

part 'widgets/detail_mode.dart';

class CourseDetail extends StatefulWidget {
  final UserModel user;
  final CourseModel course;

  const CourseDetail({Key? key, required this.user, required this.course})
      : super(key: key);

  @override
  State<CourseDetail> createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail>
    with SingleTickerProviderStateMixin {
  CourseDetailBloc courseDetailBloc = CourseDetailBloc();

  @override
  void initState() {
    super.initState();
    
    courseDetailBloc.myRole =   widget.user.role;


    courseDetailBloc.add(CourseDetailInitialEvent(courseId: widget.course.id));
    final editingCourse = widget.course;
    _nameController.text = editingCourse.name;
    _descriptionController.text = editingCourse.description ?? '';
    _endDate = editingCourse.endDate;
    _startDate = editingCourse.startDate;
    _imageUrl = editingCourse.imageUrl ?? '';
  }

  String _imageUrl = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CourseDetailBloc, CourseDetailState>(
        listener: (context, state) {
          if (state is CourseDetailEditSuccessState) {
            Navigator.pop(context);
            showToast(message: 'Course edited successfully');
          } else if (state is CourseDetailEditErrorState) {
            Navigator.pop(context);

            showToast(message: 'Failed to edit course');
          }
        },
        bloc: courseDetailBloc,
        listenWhen: (previous, current) => current is CourseDetailActionState,
        buildWhen: (previous, current) => current is! CourseDetailActionState,
        builder: (context, state) {
          switch (state.runtimeType) {
            case CourseDetailEditingState:
              return Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      courseDetailBloc.add(
                          CourseDetailInitialEvent(courseId: widget.course.id));
                    },
                  ),
                  foregroundColor: AppColors.secondaryColor,
                  backgroundColor: AppColors.mainColor,
                  title: Text(
                    'Edit Course',
                    style: TextStyle(color: AppColors.secondaryColor),
                  ),
                  actions: [],
                ),
                body: editMode(context, state),
              );

            case CourseDetailSuccessState:
              final course = (state as CourseDetailSuccessState).course;
              return Scaffold(
                backgroundColor: AppColors.secondaryColor,
                appBar: AppBar(
                  foregroundColor: AppColors.secondaryColor,
                  backgroundColor: AppColors.mainColor,
                  title: Text('Course Detail',
                      style: TextStyle(color: AppColors.secondaryColor)),
                  actions: [
                  if (courseDetailBloc.myRole == Role.teacher ||
              courseDetailBloc.myRole == Role.admin)   IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: AppColors.secondaryColor,
                        ),
                        onPressed: () async {
                          courseDetailBloc
                              .add(CourseEditClickEvent(state.course.id));
                        }),
                  ],
                ),
                body: SingleChildScrollView(
                  child: detailMode(
                      course, context, state, courseDetailBloc, widget.user.id, widget.user),
                ),
              );

            default:
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
          }
        });
  }

  Widget editMode(BuildContext context, CourseDetailState state) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.mainColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.image, color: AppColors.mainColor),
                      title: Text('Cover for Course',
                          style: TextStyle(color: AppColors.mainColor)),
                      subtitle: Text(
                          'Pick an image to be the cover image for the course.'),
                    ),
                    Container(
                      width: double.maxFinite,
                      height: 300,
                      child: ImagePickerUploader(
                          initialImageUrl: _imageUrl,
                          category: 'course_cover',
                          onUrlUploaded: (url) {
                            setState(() {
                              _imageUrl = url;
                            });
                          }),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _nameController,
                maxLength: 20,
                style: TextStyle(color: AppColors.mainColor),
                decoration: InputDecoration(
                    counterStyle: TextStyle(color: AppColors.mainColor),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.mainColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.mainColor),
                    ),
                    labelText: 'Course Name',
                    helperText:
                        'Enter the name of the course, please keep it at 20 characters or less',
                    labelStyle: TextStyle(color: AppColors.mainColor)),
              ),
              SizedBox(height: 10),
              TextField(
                maxLength: 2000,
                style: TextStyle(color: AppColors.mainColor),
                keyboardType: TextInputType.multiline,
                controller: _descriptionController,
                decoration: InputDecoration(
                  counterStyle: TextStyle(color: AppColors.mainColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.mainColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.mainColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.mainColor),
                  ),
                  labelStyle: TextStyle(color: AppColors.mainColor),
                  labelText: 'Description',
                  helperText:
                      'Enter the description of the course, details about the course and what it is about.',
                ),
                maxLines: null,
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                width: double.maxFinite,
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.mainColor,
                  border: Border.all(color: AppColors.mainColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Detail Date of Course',
                          style: TextStyle(color: AppColors.secondaryColor)),
                      subtitle: Text(
                          'Pick a start and end date for the course, usually a semester or a month.',
                          style: TextStyle(color: AppColors.secondaryColor)),
                      leading: Icon(Icons.date_range,
                          color: AppColors.secondaryColor),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.mainColor),
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.secondaryColor,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              DatePicker(context, _startDate,
                                  'Select the date where the course starts',
                                  (date) {
                                setState(() {
                                  if (_endDate != null &&
                                      date.isAfter(_endDate!)) {
                                    showToast(
                                        message:
                                            'The start date cannot be after the end date');
                                    return;
                                  }

                                  _startDate = date;
                                });
                              }),
                              DatePicker(context, _endDate,
                                  'Select the date where the course ends',
                                  (date) {
                                if (_startDate != null &&
                                    date.isBefore(_startDate!)) {
                                  showToast(
                                      message:
                                          'The end date cannot be before the start date');
                                  return;
                                }
                                setState(() {
                                  _endDate = date;
                                });
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainColor, // Button color
                  foregroundColor: AppColors.secondaryColor, // Text color
                ),
                onPressed: () async {
                  if (_nameController.text.isNotEmpty &&
                      _descriptionController.text.isNotEmpty 
                   ) {
                    _showLoadingDialog(context);

                    final CourseModel newCourse = CourseModel(
                      stars: widget.course.stars,
                        id: widget.course.id,
                        name: _nameController.text,
                        startDate: _startDate,
                        endDate: _endDate,
                        description: _descriptionController.text,
                        createdAt: DateTime.now(),
                        createdBy: widget.user.id,
                        resourceUrls: widget.course.resourceUrls,
                        imageUrl: _imageUrl);

                    courseDetailBloc
                        .add(CourseEditSaveClickEvent(course: newCourse));
                  } else {
                    showToast(message: 'Please fill in all the fields');
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Reference>> listFiles(String path) async {
    final storageRef = FirebaseStorage.instance.ref(path);
    final result = await storageRef.listAll();

    return result.items;
  }
}

Widget DatePicker(BuildContext context, DateTime? date, String description,
    Function(DateTime) onChange) {
  return ListTile(
    title: Text(
        date == null
            ? 'Pick a Date'
            : 'Date: ${date.toIso8601String().split('T')[0]}',
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

