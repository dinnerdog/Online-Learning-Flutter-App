import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:test1/data/model/activity_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/features/new/activity/bloc/activity_bloc.dart';
import 'package:test1/features/new/activity/subviews/activity_add/bloc/activity_add_bloc.dart';
import 'package:test1/global/common/activity_category_dropdown.dart';
import 'package:test1/global/common/image_picker_uploader.dart';
import 'package:test1/global/common/toast.dart';
import 'package:test1/main.dart';

class ActivityAdd extends StatefulWidget {
  final UserModel user;
  final ActivityBloc activityBloc;
  ActivityAdd({super.key, required this.activityBloc, required this.user});

  @override
  State<ActivityAdd> createState() => _ActivityAddState();
}

// -36.85088270000001, 174.7644881
class _ActivityAddState extends State<ActivityAdd> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  LocationModel _location =
      LocationModel('', latitude: -36.85088270000001, longitude: 174.7644881);

  ActivityCategory? _selectedCategory;
  String? _imageUrl;
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  ActivityAddBloc activityAddBloc = ActivityAddBloc();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    activityAddBloc.close();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityAddBloc, ActivityAddState>(
      bloc: activityAddBloc,
      listenWhen: (previous, current) => current is ActivityAddActionState,
      buildWhen: (previous, current) => current is! ActivityAddActionState,
      listener: (context, state) {
        if (state is ActivityAddSubmitSuccessState) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return editState(context);
      },
    );
  }

  Scaffold editState(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        centerTitle: false,
        foregroundColor: AppColors.secondaryColor,
        backgroundColor: AppColors.mainColor,
        title: Text('Edit Activity'),
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
            title: Text('Cover for Activity',

                style: TextStyle(color: AppColors.mainColor)),
            subtitle: Text(
                'Pick an image to be the cover image for the activity.',
               ),
          ),
          Container(
                    width: double.maxFinite,
                    height: 300,
                    child: ImagePickerUploader(
                        category: 'activity_cover',
                        initialImageUrl: _imageUrl,
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
      controller: _titleController,
      style: TextStyle(color: AppColors.mainColor),
      maxLength: 30,
      decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.mainColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.mainColor),
          ),
          labelText: 'Title',
          helperText:
              "Enter the title of the activity, please try to keep it short and sweet.",
          counterStyle: TextStyle(color: AppColors.mainColor),
          labelStyle: TextStyle(color: AppColors.mainColor)),
    ),
              SizedBox(height: 10),
              TextField(
      style: TextStyle(color: AppColors.mainColor),
      keyboardType: TextInputType.multiline,
      maxLength: 2000,
      controller: _descriptionController,
      decoration: InputDecoration(
        helperText:
            "Enter the description of the activity, please provide as much detail as possible.",
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
        labelText: 'Description',
      ),
      maxLines: null,
    ),
              SizedBox(height: 10),
              Container(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Row(
        children: [
          Flexible(
      flex: 2,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.mainColor),
          color: AppColors.mainColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            ListTile(
              title: Text('Location',
                  style: TextStyle(color: AppColors.secondaryColor)),
              subtitle: Text(
                _location.formattedAddress == ''
                    ? 'Pick a location where the activity will take place.'
                    : '${_location.formattedAddress}',
                style: TextStyle(color: AppColors.secondaryColor),
              ),
              leading: Icon(Icons.location_on, color: AppColors.secondaryColor),
            ),
            Expanded(
              child: PlacePicker(
                enableMapTypeButton: false,
                hintText: 'Pick a location where the activity will take place',
                automaticallyImplyAppBarLeading: false,
                apiKey: 'AIzaSyDtDHVEe1pphOf40l1Dm0vhUFsZYkxAsqw',
                initialPosition:
                    LatLng(_location.latitude, _location.longitude),
                onPlacePicked: (PickResult result) {
                  setState(() {
                    _location = LocationModel(
                        result.formattedAddress ?? 'unknown',
                        latitude: result.geometry!.location.lat,
                        longitude: result.geometry!.location.lng);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    ),
          SizedBox(width: 30),
          Flexible(
      flex: 2,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.mainColor,
          border: Border.all(color: AppColors.mainColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            ListTile(
              title: Text('Detail Date and Time',
                  style: TextStyle(color: AppColors.secondaryColor)),
              subtitle: Text(
                  'Pick a date and time for the activity to take place.',
                  style: TextStyle(color: AppColors.secondaryColor)),
              leading: Icon(Icons.date_range, color: AppColors.secondaryColor),
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
                      datePicker(context),
                      startTimePicker(context),
                      endTimePicker(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
        ],
      ),
    ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.mainColor,
                  border: Border.all(color: AppColors.mainColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Category',
                          style: TextStyle(color: AppColors.secondaryColor)),
                      subtitle: Text(
                          _selectedCategory == null
                              ? 'Select a category for the activity'
                              : 'Category: ${_selectedCategory!.name}',
                          style: TextStyle(color: AppColors.secondaryColor)),
                      leading:
                          Icon(Icons.category, color: AppColors.secondaryColor),
                    ),
                    ActivityCategoryDropdown(onCategorySelected: (category) {
                      setState(() {
                        
                          _selectedCategory = category;
                      });
                    }),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(
                            AppColors.secondaryColor),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            AppColors.accentColor),
                      ),
                      onPressed: () async {
                        if (_titleController.text.isEmpty ||
                            _descriptionController.text.isEmpty ||
                            _selectedCategory == null ||
                            _selectedDate == null ||
                            _selectedStartTime == null ||
                            _selectedEndTime == null ||
                            _imageUrl == null ||
                            _location.formattedAddress == '') {
                          showToast(message: 'Please fill in all fields.');
                          return;
                        }
                        _showLoadingDialog(context);

                        activityAddBloc.add(ActivityAddSubmitEvent(
                          activityModel: ActivityModel(
                              id: '',
                              title: _titleController.text,
                              description: _descriptionController.text,
                              createdBy: widget.user.id,
                              image: _imageUrl!,
                              location: _location,
                              category: _selectedCategory!,
                              date: _selectedDate!,
                              startTime: _selectedStartTime!,
                              endTime: _selectedEndTime!,
                              createdAt: DateTime.now(),
                              status: ActivityStatus.active,
                              ratings: [],
                              reviews: [],
                           ),
                        ));
                      },
                      label: Text('Submit'),
                      icon: Icon(Icons.save),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
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
            title: Text('Cover for Activity',

                style: TextStyle(color: AppColors.mainColor)),
            subtitle: Text(
                'Pick an image to be the cover image for the activity.',
               ),
          ),
          Container(
                    width: double.maxFinite,
                    height: 300,
                    child: ImagePickerUploader(
                        category: 'activity_cover',
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

  Container mapAndDateEditer(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Row(
        children: [
          mapEditer(),
          SizedBox(width: 30),
          dateEditer(context),
        ],
      ),
    );
  }

  TextField descriptionEditer() {
    return TextField(
      style: TextStyle(color: AppColors.mainColor),
      keyboardType: TextInputType.multiline,
      maxLength: 2000,
      controller: _descriptionController,
      decoration: InputDecoration(
        helperText:
            "Enter the description of the activity, please provide as much detail as possible.",
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
        labelText: 'Description',
      ),
      maxLines: null,
    );
  }

  TextField titleEditer() {
    return TextField(
      controller: _titleController,
      style: TextStyle(color: AppColors.mainColor),
      maxLength: 30,
      decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.mainColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.mainColor),
          ),
          labelText: 'Title',
          helperText:
              "Enter the title of the activity, please try to keep it short and sweet.",
          counterStyle: TextStyle(color: AppColors.mainColor),
          labelStyle: TextStyle(color: AppColors.mainColor)),
    );
  }

  Flexible dateEditer(BuildContext context) {
    return Flexible(
      flex: 2,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.mainColor,
          border: Border.all(color: AppColors.mainColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            ListTile(
              title: Text('Detail Date and Time',
                  style: TextStyle(color: AppColors.secondaryColor)),
              subtitle: Text(
                  'Pick a date and time for the activity to take place.',
                  style: TextStyle(color: AppColors.secondaryColor)),
              leading: Icon(Icons.date_range, color: AppColors.secondaryColor),
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
                      datePicker(context),
                      startTimePicker(context),
                      endTimePicker(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile endTimePicker(BuildContext context) {
    return ListTile(
      enabled: _selectedStartTime != null,
      title: Text(
          _selectedEndTime == null
              ? 'Pick an End Time'
              : 'Time: ${_selectedEndTime!.format(context)}',
          style: TextStyle(color: AppColors.mainColor)),
      subtitle: Text('Tap to change time of when the activity ends'),
      trailing: Icon(Icons.access_time_filled, color: AppColors.mainColor),
      onTap: () async {
        final initialTime = _selectedStartTime ?? TimeOfDay.now();

        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: initialTime,
        );
        if (picked != null) {
          if (_selectedStartTime != null &&
              (picked.hour < _selectedStartTime!.hour ||
                  (picked.hour == _selectedStartTime!.hour &&
                      picked.minute <= _selectedStartTime!.minute))) {
            showToast(message: 'End time must be after start time.');
          } else {
            setState(() {
              _selectedEndTime = picked;
            });
          }
        }
      },
    );
  }

  ListTile startTimePicker(BuildContext context) {
    return ListTile(
        title: Text(
            _selectedStartTime == null
                ? 'Pick a Start Time'
                : 'Time: ${_selectedStartTime!.format(context)}',
            style: TextStyle(color: AppColors.mainColor)),
        subtitle: Text('Tap to change time of when the activity starts'),
        trailing: Icon(Icons.access_time, color: AppColors.mainColor),
        onTap: () async {
          final TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked != null && picked != _selectedStartTime) {
            if (_selectedEndTime != null &&
                (picked.hour > _selectedEndTime!.hour ||
                    (picked.hour == _selectedEndTime!.hour &&
                        picked.minute >= _selectedEndTime!.minute))) {
              showToast(message: 'Start time must be before end time.');
            } else {
              setState(() {
                _selectedStartTime = picked;
              });
            }
          }
        });
  }

  ListTile datePicker(BuildContext context) {
    return ListTile(
      title: Text(
          _selectedDate == null
              ? 'Pick a Date'
              : 'Date: ${_selectedDate!.toIso8601String().split('T')[0]}',
          style: TextStyle(color: AppColors.mainColor)),
      subtitle: Text(
        'Tap to change date of the activity.',
      ),
      trailing: Icon(Icons.calendar_today, color: AppColors.mainColor),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime(2025),
        );
        if (picked != null && picked != _selectedDate) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
    );
  }

  Flexible mapEditer() {
    return Flexible(
      flex: 2,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.mainColor),
          color: AppColors.mainColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            ListTile(
              title: Text('Location',
                  style: TextStyle(color: AppColors.secondaryColor)),
              subtitle: Text(
                _location.formattedAddress == ''
                    ? 'Pick a location where the activity will take place.'
                    : '${_location.formattedAddress}',
                style: TextStyle(color: AppColors.secondaryColor),
              ),
              leading: Icon(Icons.location_on, color: AppColors.secondaryColor),
            ),
            Expanded(
              child: PlacePicker(
                enableMapTypeButton: false,
                hintText: 'Pick a location where the activity will take place',
                automaticallyImplyAppBarLeading: false,
                apiKey: 'AIzaSyDtDHVEe1pphOf40l1Dm0vhUFsZYkxAsqw',
                initialPosition:
                    LatLng(_location.latitude, _location.longitude),
                onPlacePicked: (PickResult result) {
                  setState(() {
                    _location = LocationModel(
                        result.formattedAddress ?? 'unknown',
                        latitude: result.geometry!.location.lat,
                        longitude: result.geometry!.location.lng);
                  });
                },
              ),
            ),
          ],
        ),
      ),
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
}


