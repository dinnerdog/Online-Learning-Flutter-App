import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/data/model/course_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/features/new/course/subviews/course_add/bloc/course_add_bloc.dart';
import 'package:test1/global/common/image_picker_uploader.dart';
import 'package:test1/global/common/toast.dart';
import 'package:test1/main.dart';

class CourseAdd extends StatefulWidget {
  final UserModel user;
  final String? name;
  final String? description;
  final String? imageUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? resourceUrls;
  final DateTime? createdAt;
  final String? createdBy;

  CourseAdd({
    Key? key,
    required this.user,
    this.name,
    this.description,
    this.imageUrl,
    this.startDate,
    this.endDate,
    this.resourceUrls,
    this.createdAt,
    this.createdBy,
  }) : super(key: key);

  @override
  _CourseAddState createState() => _CourseAddState();
}

class _CourseAddState extends State<CourseAdd> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _imageUrl;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name ?? '';
    _descriptionController.text = widget.description ?? '';
    _imageUrl = widget.imageUrl ?? '';
    _startDate = widget.startDate ?? null;
    _endDate = widget.endDate ?? null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
 
  
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

    CourseAddBloc courseAddBloc = CourseAddBloc();

    return BlocListener<CourseAddBloc, CourseAddState>(
      bloc: courseAddBloc,
      listener: (context, state) {
        if (state is CourseAddClickSubmitSuccessActionState) {
          Navigator.pop(context);
          Navigator.pop(context);
          showToast(message: 'Course added successfully');
        } else if (state is CourseAddClickSubmitErrorState) {
          Navigator.pop(context);
          showToast(message: 'Failed to add course');
        }

      },
      child: Scaffold(
        backgroundColor: AppColors.secondaryColor,
        appBar: AppBar(
          centerTitle: false,
          title: Text('Add a Course'),
          foregroundColor: AppColors.secondaryColor,
          backgroundColor: AppColors.mainColor,
        ),
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
                        _descriptionController.text.isNotEmpty &&
                        _startDate != null &&
                        _endDate != null &&
                        _imageUrl != null) {
                      _showLoadingDialog(context);

                      final CourseModel newCourse = CourseModel(
                          stars:  [],
                          id: '',
                          name: _nameController.text,
                          startDate: _startDate!,
                          endDate: _endDate!,
                          description: _descriptionController.text,
                          createdAt: DateTime.now(),
                          createdBy: widget.user.id,
                          resourceUrls: [],
                          imageUrl: _imageUrl!);

                      courseAddBloc.add(CourseAddClickSubmitEvent(newCourse));
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
