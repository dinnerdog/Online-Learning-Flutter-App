import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:test1/data/model/activity_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/user_repository.dart';
import 'package:test1/features/new/activity/subviews/activity_detail/bloc/activity_detail_bloc.dart';
import 'package:test1/features/new/contacts/subviews/chatroom/ui/chatroom.dart';
import 'package:test1/global/common/activity_category_dropdown.dart';
import 'package:test1/global/common/image_picker_uploader.dart';
import 'package:test1/global/common/toast.dart';
import 'package:test1/global/extension/date_time.dart';
import 'package:test1/main.dart';

TimeOfDay parseTime(String timeStr) {
  final parts = timeStr.split(' ');
  final timeParts = parts[0].split(':');

  int hour = int.parse(timeParts[0], radix: 10);
  int minute = int.parse(timeParts[1], radix: 10);

  // 根据AM/PM调整小时数
  if (parts[1].toUpperCase() == 'PM' && hour != 12) {
    hour = hour + 12;
  } else if (parts[1].toUpperCase() == 'AM' && hour == 12) {
    hour = 0; // 午夜12点应当转换为0小时
  }

  // 创建并返回TimeOfDay对象
  return TimeOfDay(hour: hour, minute: minute);
}

class ActivityDetail extends StatefulWidget {
  final ActivityModel activityModel;
  final UserModel userModel;
  const ActivityDetail(
      {super.key, required this.activityModel, required this.userModel});

  @override
  State<ActivityDetail> createState() => _ActivityDetailState();
}

class _ActivityDetailState extends State<ActivityDetail> {
  ActivityDetailBloc activityDetailBloc = ActivityDetailBloc();


  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  LocationModel _location =
      LocationModel('', latitude: -36.85088270000001, longitude: 174.7644881);

  ActivityCategory? _selectedCategory;
  String? _imageUrl;
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  @override
  void dispose() {
    activityDetailBloc.close();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget activityInfo(ActivityDetailLoadSuccessState state) {
    return Expanded(
      flex: 7,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              'Activity Details',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainColor),
            ),
            dateAndTime(state),
            activityLocation(state),
            activityCategory(state),
            activityDescription(state),
          ],
        ),
      ),
    );
  }

  ListTile activityCategory(ActivityDetailLoadSuccessState state) {
    return ListTile(
      dense: true,
      leading: Icon(Icons.category, color: AppColors.mainColor),
      title: Text(
        'Category',
        style: TextStyle(color: AppColors.mainColor),
      ),
      subtitle: Text(
        state.activity.category.name,
        style: TextStyle(color: AppColors.mainColor),
      ),
    );
  }

  ListTile activityLocation(ActivityDetailLoadSuccessState state) {
    return ListTile(
      dense: true,
      leading: Icon(Icons.location_on, color: AppColors.mainColor),
      title: Text(
        'Location',
        style: TextStyle(color: AppColors.mainColor),
      ),
      subtitle: Text(
        state.activity.location.formattedAddress,
        style: TextStyle(color: AppColors.mainColor),
      ),
    );
  }

  Widget activityDescription(ActivityDetailLoadSuccessState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mainColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
          dense: true,
          leading: Icon(Icons.description, color: AppColors.secondaryColor),
          title: Text(
            'Description',
            style: TextStyle(color: AppColors.secondaryColor),
          ),
          subtitle: Text(
            state.activity.description,
            style: TextStyle(color: AppColors.secondaryColor),
          )),
    );
  }

  Row dateAndTime(ActivityDetailLoadSuccessState state) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Expanded(
        child: ListTile(
          dense: true,
          leading: Icon(Icons.date_range, color: AppColors.mainColor),
          title: Text(
            'Date',
            style: TextStyle(color: AppColors.mainColor),
          ),
          subtitle: Text(
            state.activity.date.informalTime(),
            style: TextStyle(color: AppColors.mainColor),
          ),
        ),
      ),
      Container(
        height: 50,
        width: 1,
        color: AppColors.mainColor,
      ),
      Expanded(
        child: ListTile(
          dense: true,
          leading: Icon(Icons.access_time, color: AppColors.mainColor),
          title: Text(
            'Time',
            style: TextStyle(color: AppColors.mainColor),
          ),
          subtitle: Text(
            state.activity.startTime.format(context) +
                ' - ' +
                state.activity.endTime.format(context),
            style: TextStyle(color: AppColors.mainColor),
          ),
        ),
      ),
    ]);
  }

  Row locationAndCategory(ActivityDetailLoadSuccessState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ListTile(
            dense: true,
            leading: Icon(Icons.location_on, color: AppColors.mainColor),
            title: Text(
              'Location',
              style: TextStyle(color: AppColors.mainColor),
            ),
            subtitle: Text(
              state.activity.location.formattedAddress,
              style: TextStyle(color: AppColors.mainColor),
            ),
          ),
        ),
        Container(
          height: 50,
          width: 1,
          color: AppColors.mainColor,
        ),
        Expanded(
          child: ListTile(
            dense: true,
            leading: Icon(Icons.category, color: AppColors.mainColor),
            title: Text(
              'Category',
              style: TextStyle(color: AppColors.mainColor),
            ),
            subtitle: Text(
              state.activity.category.toString(),
              style: TextStyle(color: AppColors.mainColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget activityTitle(ActivityDetailLoadSuccessState state) {
    return Container(
      child: ListTile(
        leading: Icon(Icons.event, color: AppColors.mainColor),
        title: Text(
          'Activity',
          style: TextStyle(color: AppColors.mainColor),
        ),
        subtitle: Text(
          state.activity.title,
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.mainColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityDetailBloc, ActivityDetailState>(
      bloc: activityDetailBloc,
      listenWhen:(previous, current) => current is ActivityDetailActionState,
      buildWhen: (previous, current) => current is! ActivityDetailActionState,
      listener: (context, state) {
        print(state);
        if (state is ActivityDetailEditQuitActionState) {
          activityDetailBloc.add(
              ActivitysSubscriptionRequested(activityId: widget.activityModel.id));
        } else if (state is ActivityDetailEditDeleteConfirmSuccessState) {
         Navigator.of(context).pop();
        } else if (state is ActivityDetailEditSaveSuccessState) {
         Navigator.of(context).pop();
   
        } else if (state is ActivityDetailEditSaveErrorState) {
         Navigator.of(context).pop();
          showToast(message: 'Error saving activity details');
        }
      },
      builder: (context, state) {
        switch (state) {
          case ActivityDetailLoadInProgressState():
            return Center(child: CircularProgressIndicator());
          case ActivityDetailLoadSuccessState():
            return detailState(state, context);

          case ActivityDetailEditState():
  

            return editState(context, state);

          case ActivityDetailLoadErrorState():
            return Center(child: Text('Error loading activity details'));
          default:
            return Container();
        }
      },
    );
  }

  Scaffold detailState(
      ActivityDetailLoadSuccessState state, BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        foregroundColor: AppColors.secondaryColor,
        backgroundColor: AppColors.mainColor,
        title: Text(
          state.activity.title,
          style: TextStyle(color: AppColors.secondaryColor),
        ),
        actions: [
        if (widget.userModel.role == Role.teacher || widget.userModel.role == Role.admin)  IconButton(
            onPressed: () {
              activityDetailBloc
                  .add(ActivityDetailEditClickEvent(activity: state.activity));
            },
            icon: Icon(Icons.edit, color: AppColors.secondaryColor),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                child: Image.asset(
                  'assets/app_images/activity_background.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.mainColor.withOpacity(0.8),
                ),
              ),
            ),
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  activityCover(state),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 20),
                      activityInfo(state),
                      SizedBox(width: 20),
                      mapInfo(state, context, state.activity),
                      SizedBox(width: 20),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Who hosts this activity?",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.mainColor,
                                ),
                              ),
                              SizedBox(height: 10),
                              StreamBuilder(
                                stream: UserRepository().getUserByIdStream(
                                    state.activity.createdBy),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final user = snapshot.data!;
                                    return Row(
                                      children: [
                                        Container(
                                          width: 150,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: CachedNetworkImageProvider(
                                                
                                                user.avatarUrl!,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ListTile(
                                                        leading: Icon(
                                                            Icons.person,
                                                            color: AppColors
                                                                .mainColor),
                                                        title: Text(
                                                          user.name,
                                                          style: TextStyle(
                                                            fontSize: 24,
                                                            color: AppColors
                                                                .mainColor,
                                                          ),
                                                        ),
                                                        subtitle: Text(
                                                            user.motto ??
                                                                'This user forgot to set a motto.',
                                                            style: TextStyle(
                                                                color: AppColors
                                                                    .mainColor))),
                                                    SizedBox(height: 10),
                                                    ListTile(
                                                      dense: true,
                                                      leading: Icon(
                                                          Icons.date_range,
                                                          color: AppColors
                                                              .mainColor),
                                                      title: Text(
                                                          'Created this event at',
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .mainColor)),
                                                      subtitle: Text(
                                                         state.activity.createdAt.informalTime(),
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .mainColor)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: AppColors.mainColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      ListTile(
                                                          title: Text(
                                                              'Contact details',
                                                              style: TextStyle(
                                                                  color: AppColors
                                                                      .secondaryColor))),
                                                      ListTile(
                                                        leading: Icon(
                                                            Icons.email,
                                                            color: AppColors
                                                                .secondaryColor),
                                                        title: Text(user.email,
                                                            style: TextStyle(
                                                                color: AppColors
                                                                    .secondaryColor)),
                                                      ),
                                                      ListTile(
                                                        leading: Icon(
                                                            Icons.phone,
                                                            color: AppColors
                                                                .secondaryColor),
                                                        title: Text(
                                                            user.phoneNumber ??
                                                                'user did not set it',
                                                            style: TextStyle(
                                                                color: AppColors
                                                                    .secondaryColor)),
                                                      ),
                                                      ListTile(),
                                                      TextButton.icon(
                                                          style: ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStateProperty.all<
                                                                        Color>(
                                                                    AppColors
                                                                        .secondaryColor),
                                                            foregroundColor:
                                                                MaterialStateProperty.all<
                                                                        Color>(
                                                                    AppColors
                                                                        .accentColor),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(context).push(
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            Chatroom(

                                                                              anotherUserId: state.activity.createdBy,
                                                                              currentUserId: widget.userModel.id,
                                                                            )));
                                                          },
                                                          icon:
                                                              Icon(Icons.chat),
                                                          label: Text(
                                                              'Chat with host')),
                                                      SizedBox(height: 10),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget mapInfo(ActivityDetailLoadSuccessState state, BuildContext context,
      ActivityModel activity) {
    return Expanded(
      flex: 6,
      child: Container(
        height: 400,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Text('${activity.location.formattedAddress}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(color: AppColors.accentColor)),
            Flexible(
              flex: 3,
              child: Container(
                child: GoogleMap(
                  markers: {
                    Marker(
                        markerId: MarkerId(activity.location.formattedAddress),
                        position: LatLng(activity.location.latitude,
                            activity.location.longitude))
                  },
                  myLocationButtonEnabled: false,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(activity.location.latitude,
                          activity.location.longitude),
                      zoom: 15),
                ),
              ),
            ),
            Container(
              width: double.maxFinite,
              padding: EdgeInsets.all(8),
              child: TextButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentColor,
                      foregroundColor: AppColors.secondaryColor),
                  onPressed: () async {
                    final coords = Coords(activity.location.latitude,
                        activity.location.longitude);
                    final title =
                        activity.location.formattedAddress.split(',')[0];

                    final availableMaps = await MapLauncher.installedMaps;

                    mapsSheet(context, availableMaps, coords, title);
                  },
                  icon: Icon(Icons.card_travel),
                  label: Text('Go now')),
            )
          ],
        ),
      ),
    );
  }

  Scaffold editState(BuildContext context, ActivityDetailEditState state) {
   

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
                                  style: TextStyle(
                                      color: AppColors.secondaryColor)),
                              subtitle: Text(
                                _location.formattedAddress == ''
                                    ? 'Pick a location where the activity will take place.'
                                    : '${_location.formattedAddress}',
                                style:
                                    TextStyle(color: AppColors.secondaryColor),
                              ),
                              leading: Icon(Icons.location_on,
                                  color: AppColors.secondaryColor),
                            ),
                            Expanded(
                              child: PlacePicker(
                                enableMapTypeButton: false,
                                hintText:
                                    'Pick a location where the activity will take place',
                                automaticallyImplyAppBarLeading: false,
                                apiKey:'your-api-key-here',
                                initialPosition: LatLng(
                                    _location.latitude, _location.longitude),
                                onPlacePicked: (PickResult result) {
                                  setState(() {
                                    _location = LocationModel(
                                        result.formattedAddress ?? 'unknown',
                                        latitude: result.geometry!.location.lat,
                                        longitude:
                                            result.geometry!.location.lng);
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
                                  style: TextStyle(
                                      color: AppColors.secondaryColor)),
                              subtitle: Text(
                                  'Pick a date and time for the activity to take place.',
                                  style: TextStyle(
                                      color: AppColors.secondaryColor)),
                              leading: Icon(Icons.date_range,
                                  color: AppColors.secondaryColor),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: AppColors.mainColor),
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppColors.secondaryColor,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      datePicker(context),
                                      ListTile(
                                        enabled: _selectedStartTime != null,
                                        title: Text(
                                            _selectedEndTime == null
                                                ? 'Pick an End Time'
                                                : 'Time: ${_selectedEndTime!.format(context)}',
                                            style: TextStyle(
                                                color: AppColors.mainColor)),
                                        subtitle: Text(
                                            'Tap to change time of when the activity ends'),
                                        trailing: Icon(Icons.access_time_filled,
                                            color: AppColors.mainColor),
                                        onTap: () async {
                                          final initialTime =
                                              _selectedStartTime ??
                                                  TimeOfDay.now();

                                          final TimeOfDay? picked =
                                              await showTimePicker(
                                            context: context,
                                            initialTime: initialTime,
                                          );
                                          if (picked != null) {
                                            if (_selectedStartTime != null &&
                                                (picked.hour <
                                                        _selectedStartTime!
                                                            .hour ||
                                                    (picked.hour ==
                                                            _selectedStartTime!
                                                                .hour &&
                                                        picked.minute <=
                                                            _selectedStartTime!
                                                                .minute))) {
                                              showToast(
                                                  message:
                                                      'End time must be after start time.');
                                            } else {
                                              setState(() {
                                                _selectedEndTime = picked;
                                              });
                                            }
                                          }
                                        },
                                      ),
                                      ListTile(
                                          title: Text(
                                              _selectedStartTime == null
                                                  ? 'Pick a Start Time'
                                                  : 'Time: ${_selectedStartTime!.format(context)}',
                                              style: TextStyle(
                                                  color: AppColors.mainColor)),
                                          subtitle: Text(
                                              'Tap to change time of when the activity starts'),
                                          trailing: Icon(Icons.access_time,
                                              color: AppColors.mainColor),
                                          onTap: () async {
                                            final TimeOfDay? picked =
                                                await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                            );
                                            if (picked != null &&
                                                picked != _selectedStartTime) {
                                              if (_selectedEndTime != null &&
                                                  (picked.hour >
                                                          _selectedEndTime!
                                                              .hour ||
                                                      (picked.hour ==
                                                              _selectedEndTime!
                                                                  .hour &&
                                                          picked.minute >=
                                                              _selectedEndTime!
                                                                  .minute))) {
                                                showToast(
                                                    message:
                                                        'Start time must be before end time.');
                                              } else {
                                                setState(() {
                                                  _selectedStartTime = picked;
                                                });
                                              }
                                            }
                                          })
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
                    ActivityCategoryDropdown(
                      onCategorySelected: (category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      selectedCategory: _selectedCategory,
                    ),
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

                        activityDetailBloc.add(ActivityDetailEditSaveClickEvent(
                          activityModel: ActivityModel(
                            id: state.activity.id,
                            title: _titleController.text,
                            description: _descriptionController.text,
                            createdBy: state.activity.createdBy,
                            image: _imageUrl!,
                            location: _location,
                            category: _selectedCategory!,
                            date: _selectedDate!,
                            startTime: _selectedStartTime!,
                            endTime: _selectedEndTime!,
                            createdAt: state.activity.createdAt,
                            status: ActivityStatus.active,
                            ratings: state.activity.ratings,
                            reviews: state.activity.reviews,
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

  Widget activityCover(ActivityDetailLoadSuccessState state) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.mainColor,
              Colors.black87.withOpacity(0.8),
            ],
          )),
          child: Hero(
            tag: state.activity.id,
            child: Container(
              padding: EdgeInsets.only(
                bottom: 100,
                left: 50,
                right: 50,
              ),
              width: MediaQuery.of(context).size.width,
              height: 500,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
                child: Container(
                  child: CachedNetworkImage(
                     progressIndicatorBuilder:(context, url, progress) {
                      return Center(
                                    child:
                                        LoadingAnimationWidget.twistingDots(
                                      size: 10,
                                      leftDotColor: AppColors.mainColor,
                                      rightDotColor: AppColors.darkMainColor,
                                    ),
                                  );
                      
                    },
                    imageUrl: state.activity.image,
                 
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 20,
          child: Text(
            state.activity.title,
            style: TextStyle(color: AppColors.secondaryColor, fontSize: 50),
          ),
        )
      ],
    );
  }

  ListTile datePicker(BuildContext context) {
    return ListTile(
      title: Text('Date: ${_selectedDate!.toIso8601String().split('T')[0]}',
          style: TextStyle(color: AppColors.accentColor)),
      subtitle: Text(
        'Tap to change date.',
      ),
      leading: Icon(Icons.calendar_today, color: AppColors.accentColor),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: _selectedDate!,
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

  TextField descriptionField() {
    return TextField(
      style: TextStyle(color: AppColors.mainColor),
      keyboardType: TextInputType.multiline,
      maxLength: 2000,
      controller: _descriptionController,
      decoration: InputDecoration(
        helperText:
            "Enter the description of the activity, please provide as much detail as possible.",
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.accentColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.accentColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.mainColor),
        ),
        counterStyle: TextStyle(color: AppColors.accentColor),
        labelStyle: TextStyle(color: AppColors.accentColor),
        labelText: 'Description',
      ),
      maxLines: null,
    );
  }

  @override
  void initState() {
    super.initState();
    activityDetailBloc
        .add(ActivitysSubscriptionRequested(activityId: widget.activityModel.id));
                 _titleController.text = widget.activityModel.title;
    _descriptionController.text = widget.activityModel.description;
    _location = widget.activityModel.location;
    _selectedCategory = widget.activityModel.category;
    _imageUrl = widget.activityModel.image;
    _selectedDate = widget.activityModel.date;
    _selectedStartTime = widget.activityModel.startTime;
    _selectedEndTime = widget.activityModel.endTime;
  }

  TextField titleField() {
    return TextField(
      controller: _titleController,
      style: TextStyle(color: AppColors.mainColor),
      maxLength: 30,
      decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.accentColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.mainColor),
          ),
          labelText: 'Title',
          helperText:
              "Enter the title of the activity, please try to keep it short and sweet.",
          counterStyle: TextStyle(color: AppColors.accentColor),
          labelStyle: TextStyle(color: AppColors.accentColor)),
    );
  }
}

class infoDivider extends StatelessWidget {
  const infoDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      indent: 20,
      endIndent: 20,
      color: AppColors.mainColor,
      thickness: 1,
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

String timeOfDayToString(TimeOfDay time) {
  final hours = time.hour.toString().padLeft(2, '0');
  final minutes = time.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}

Future<dynamic> mapsSheet(BuildContext context,
    List<AvailableMap> availableMaps, Coords coords, String title) {
  return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Wrap(
                children: [
                  ListTile(
                    title: Text('Open with',
                        style: TextStyle(
                            fontSize: 20, color: AppColors.mainColor)),
                    leading: Icon(Icons.map, color: AppColors.mainColor),
                  ),
                  Divider(),
                  for (var map in availableMaps)
                    ListTile(
                      onTap: () => map.showMarker(
                        coords: coords,
                        title: title,
                      ),
                      title: Text(map.mapName,
                          style: TextStyle(color: AppColors.mainColor)),
                      leading: SvgPicture.asset(
                        map.icon,
                        height: 30.0,
                        width: 30.0,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      });
}
