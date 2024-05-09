import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:test1/data/model/activity_model.dart';
import 'package:test1/data/model/activity_user_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/activity_user_repository.dart';
import 'package:test1/data/repo/user_repository.dart';
import 'package:test1/features/new/activity/bloc/activity_bloc.dart';
import 'package:test1/features/new/activity/subviews/activity_add/ui/activity_add.dart';
import 'package:test1/features/new/activity/subviews/activity_detail/ui/activity_detail.dart';
import 'package:test1/features/new/home/bloc/bloc/menu_bloc.dart';
import 'package:test1/global/common/filter_dropdown.dart';
import 'package:test1/global/common/search_bar.dart';
import 'package:test1/main.dart';

class Activity extends StatefulWidget {
  final UserModel user;
  const Activity({super.key, required this.user});

  @override
  State<Activity> createState() => _ActivityState();
}

final formattedDate = DateFormat('dd/MM/yyyy');

class _ActivityState extends State<Activity> {
  ActivityBloc activityBloc = ActivityBloc();
  GlobalKey<SliderDrawerState> _key = GlobalKey<SliderDrawerState>();
  GlobalKey<SliderDrawerState> _filterKey = GlobalKey<SliderDrawerState>();
  ActivityState _previousState = ActivityInitial();
  bool isAscending = false;
  String filterCondition = 'date';
  @override
  void initState() {
    super.initState();

    activityBloc.add(ActivitiesSubscriptionRequested(
        sortCondition: filterConditionToField(filterCondition),
        isAscending: isAscending));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SliderDrawer(
        key: _key,
        appBar: SliderAppBar(
          
          
          appBarHeight: 105,
            
          drawerIcon: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: IconButton(
              
              style: ButtonStyle(
             
                backgroundColor:
                    MaterialStateProperty.all<Color>(AppColors.accentColor),
                foregroundColor:
                    MaterialStateProperty.all<Color>(AppColors.secondaryColor),
              ),
              onPressed: () {
                _key.currentState!.toggle();
              },
              icon: Icon(Icons.event, ),
            ),
          ),
          isTitleCenter: false,
          title: Text('Activities',
              style: TextStyle(color: AppColors.mainColor, fontSize: 20)),
          appBarColor: AppColors.secondaryColor,
          drawerIconColor: AppColors.mainColor,
          trailing: Row(
            children: [
              if (widget.user.role == Role.teacher || widget.user.role == Role.admin)
         
              IconButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(AppColors.accentColor),
                  foregroundColor: MaterialStateProperty.all<Color>(
                      AppColors.secondaryColor),
                ),
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ActivityAdd(
                      activityBloc: activityBloc,
                      user: widget.user,
                    ),
                  ));
                },
              ),
              IconButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(AppColors.accentColor),
                  foregroundColor: MaterialStateProperty.all<Color>(
                      AppColors.secondaryColor),
                ),
                icon: Icon(Icons.filter_alt),
                onPressed: () {
                  _filterKey.currentState!.toggle();
                },
              ),
              IconButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(AppColors.accentColor),
                  foregroundColor: MaterialStateProperty.all<Color>(
                      AppColors.secondaryColor),
                ),
                icon: Icon(Icons.expand_outlined),
                onPressed: () {
                 BlocProvider.of<MenuBloc>(context).add(MenuToggleEvent());
                },
              ),
              SizedBox(width: 10)
            ],
          ),
        ),
        slider: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            color: AppColors.accentColor,
            child: Column(
              children: [
                BlocBuilder<ActivityBloc, ActivityState>(
                  bloc: activityBloc,
                  builder: (context, state) {
                    if (state is ActivityFilterActionState) {
                      return Container(
                        height: MediaQuery.of(context).size.height,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.secondaryColor,
                          ),
                        ),
                      );
                    }
                    return ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        secondaryMenuTile('Activities', 'All', Icons.event,
                            activityBloc.state is ActivitySuccessState,
                            onTap: () {
                          activityBloc.add(ActivityInitialEvent(
                              sortCondition:
                                  filterConditionToField(filterCondition),
                              isAscending: isAscending));
                        }),
                        secondaryMenuTile(
                            'Activities',
                            'Interested',
                            Icons.favorite,
                            activityBloc.state is MyActivityState, onTap: () {
                          activityBloc.add(SwitchToMyActivityEvent(
                              userId: widget.user.id,
                              sortCondition: filterCondition,
                              isAscending: isAscending));
                        }),
                        if (widget.user.role == Role.teacher || widget.user.role == Role.admin)    secondaryMenuTile(
                            'Activities',
                            'Created By Me',
                            Icons.create,
                            activityBloc.state is CreatedActivityState,
                            onTap: () {
                          activityBloc.add(SwitchToCreatedActivityEvent(
                              userId: widget.user.id,
                              sortCondition: filterCondition,
                              isAscending: isAscending));
                        }),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        child: SliderDrawer(
          appBar: null,
          key: _filterKey,
          slideDirection: SlideDirection.TOP_TO_BOTTOM,
          sliderOpenSize: 70,
          slider: Container(
            decoration: BoxDecoration(
              color: AppColors.accentColor,
            ),
            
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 20),
                    Expanded(
                      flex: 5,
                      child: Row(
                        children: [
                          Icon(Icons.sort, color: AppColors.secondaryColor),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: FilterDropdown(
                                onFilterApplied: (value) {
                                  setState(() {
                                    filterCondition = value;
                                  });
                                  activityBloc.add(ActivityFilterClickEvent(
                                      sortCondition: filterConditionToField(
                                          filterCondition),
                                      isAscending: isAscending));
                                },
                                filterConditions: [
                                  'date',
                                  'created time',
                                  'name'
                                ],
                                currentFilterCondition: filterCondition,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          AnimatedToggleSwitch<bool>.dual(
                            borderWidth: 2,
                            onChanged: (b) {
                              setState(() => isAscending = b);
                              activityBloc.add(ActivityFilterClickEvent(
                                  sortCondition:
                                      filterConditionToField(filterCondition),
                                  isAscending: isAscending));
                            },
                            styleBuilder: (b) => ToggleStyle(
                              indicatorColor: b
                                  ? AppColors.accentColor
                                  : AppColors.secondaryColor,
                              backgroundColor: b
                                  ? AppColors.secondaryColor
                                  : AppColors.accentColor,
                              borderColor: b
                                  ? AppColors.secondaryColor
                                  : AppColors.secondaryColor,
                            ),
                            textBuilder: (value) => value
                                ? Center(
                                    child: Text('Descending',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.accentColor)))
                                : Center(
                                    child: Text('Ascending',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.secondaryColor))),
                            style: ToggleStyle(
                              indicatorColor: AppColors.accentColor,
                              backgroundColor: AppColors.secondaryColor,
                            ),
                            first: true,
                            second: false,
                            current: isAscending,
                            iconBuilder: (b) => b
                                ? Icon(Icons.sort_rounded,
                                    color: AppColors.secondaryColor)
                                : Icon(Icons.sort_rounded,
                                    color: AppColors.accentColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          child: CustomSearchBar(

            onSearch: (query) async {
              if (query.isEmpty) {
                return List<SearchResult<ActivityModel>>.empty();
              }

              if (activityBloc.state is ActivitySuccessState) {
                final activities =
                    (activityBloc.state as ActivitySuccessState).activityList;
                return activities.where((activity) {
                  final result = activity.title
                      .toLowerCase()
                      .contains(query.toLowerCase());

                  return result;
                }).map((activity) {
                  return SearchResult(
                      title: activity.title,
                      subtitle: activity.date.toString(),
                      data: activity);
                }).toList();

                
              } else if (activityBloc.state is MyActivityState) {
                final activities =
                    (activityBloc.state as MyActivityState).activityList;
                return activities.where((activity) {
                  final result = activity.title
                      .toLowerCase()
                      .contains(query.toLowerCase());

                  return result;
                }).map((activity) {
                  return SearchResult(
                      title: activity.title,
                      subtitle: activity.date.toString(),
                      data: activity);
                }).toList();
              } else if (activityBloc.state is CreatedActivityState) {
                final activities =
                    (activityBloc.state as CreatedActivityState).activityList;
                return activities.where((activity) {
                  final result = activity.title
                      .toLowerCase()
                      .contains(query.toLowerCase());

                  return result;
                }).map((activity) {
                  return SearchResult(
                      title: activity.title,
                      subtitle: activity.date.toString(),
                      data: activity);
                }).toList();
              }

              
 
            

              return List<SearchResult<ActivityModel>>.empty();
            },
            onSelect: (result) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ActivityDetail(
                  activityModel: result.data,
                  userModel: widget.user,
                ),
              ));
            },
            hintText: "Search for activities...",
            body: Container(
              padding: EdgeInsets.only(top: 60),
              color: AppColors.secondaryColor,
              child: BlocConsumer<ActivityBloc, ActivityState>(
                bloc: activityBloc,
                listenWhen: (previous, current) {
                  _previousState = previous;
                  return current is ActivityActionState;
                },
                buildWhen: (previous, current) =>
                    current is! ActivityActionState,
                listener: (context, state) {
                  if (state is ActivityFilterActionState) {
                    if (_previousState is ActivitySuccessState) {
                      activityBloc.add(ActivityInitialEvent(
                          sortCondition:
                              filterConditionToField(filterCondition),
                          isAscending: isAscending));
                    } else if (_previousState is MyActivityState) {
                      activityBloc.add(SwitchToMyActivityEvent(
                          userId: widget.user.id,
                          sortCondition:
                              filterConditionToField(filterCondition),
                          isAscending: isAscending));
                    } else if (_previousState is CreatedActivityState) {
                      activityBloc.add(SwitchToCreatedActivityEvent(
                          userId: widget.user.id,
                          sortCondition:
                              filterConditionToField(filterCondition),
                          isAscending: isAscending));
                    }
                  }
                },
                builder: (context, state) {
                  switch (state.runtimeType) {
                    case ActivityLoadingState:
                      return Scaffold(body: Skeletion());

                    case MyActivityState:
                      final activities =
                          (state as MyActivityState).activityList;

                      return myActivityList(activities);

                    case CreatedActivityState:
                      final activities =
                          (state as CreatedActivityState).activityList;

                      return createdActivityList(activities);

                    case ActivitySuccessState:
                      final activities =
                          (state as ActivitySuccessState).activityList;

                      return ListView.builder(
                        itemCount: activities.length,
                        itemBuilder: (context, index) {
                          return ActivityItems(
                              context, activities[index], index, state);
                        },
                      );

                    case ActivityErrorState:
                      return Scaffold(
                        body: Center(
                          child: Text('Error'),
                        ),
                      );

                    default:
                      return Scaffold(body: Skeletion());
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  ListView myActivityList(List<ActivityModel> activities) {
    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            ExpansionTileCard(
              trailing: Icon(Icons.arrow_drop_down_circle,
                  color: AppColors.secondaryColor),
              initialPadding: EdgeInsets.all(8),
              finalPadding: EdgeInsets.all(10),
              baseColor: AppColors.mainColor,
              expandedColor: AppColors.accentColor,
              expandedTextColor: AppColors.accentColor,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 300,
                            child: ListView(
                              children: [
                                ListTile(
                                  title: Text('How much days left',
                                      style: TextStyle(
                                          color: AppColors.accentColor)),
                                  subtitle: Text(
                                      activities[index]
                                                  .date
                                                  .difference(DateTime.now())
                                                  .inDays <
                                              0
                                          ? 'Expired'
                                          : activities[index]
                                                  .date
                                                  .difference(DateTime.now())
                                                  .inDays
                                                  .toString() +
                                              ' days left',
                                      style: TextStyle(
                                          color: AppColors.accentColor)),
                                  leading: Icon(Icons.calendar_today,
                                      color: AppColors.accentColor),
                                ),
                                ListTile(
                                  title: Text('Start Time',
                                      style: TextStyle(
                                          color: AppColors.accentColor)),
                                  subtitle: Text(
                                      activities[index]
                                          .startTime
                                          .format(context),
                                      style: TextStyle(
                                          color: AppColors.accentColor)),
                                  leading: Icon(Icons.timer,
                                      color: AppColors.accentColor),
                                ),
                                ListTile(
                                  title: Text('End Time',
                                      style: TextStyle(
                                          color: AppColors.accentColor)),
                                  subtitle: Text(
                                      activities[index].endTime.format(context),
                                      style: TextStyle(
                                          color: AppColors.accentColor)),
                                  leading: Icon(Icons.timer_off,
                                      color: AppColors.accentColor),
                                ),
                              ],
                            )),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                  '${activities[index].location.formattedAddress}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style:
                                      TextStyle(color: AppColors.accentColor)),
                              Flexible(
                                flex: 3,
                                child: Container(
                                  width: 400,
                                  child: GoogleMap(
                                    markers: {
                                      Marker(
                                          markerId: MarkerId(activities[index]
                                              .location
                                              .formattedAddress),
                                          position: LatLng(
                                              activities[index]
                                                  .location
                                                  .latitude,
                                              activities[index]
                                                  .location
                                                  .longitude))
                                    },
                                    myLocationButtonEnabled: false,
                                    initialCameraPosition: CameraPosition(
                                        target: LatLng(
                                            activities[index].location.latitude,
                                            activities[index]
                                                .location
                                                .longitude),
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
                                        foregroundColor:
                                            AppColors.secondaryColor),
                                    onPressed: () async {
                                      final coords = Coords(
                                          activities[index].location.latitude,
                                          activities[index].location.longitude);
                                      final title = activities[index]
                                          .location
                                          .formattedAddress
                                          .split(',')[0];

                                      final availableMaps =
                                          await MapLauncher.installedMaps;

                                      mapsSheet(context, availableMaps, coords,
                                          title);
                                    },
                                    icon: Icon(Icons.card_travel),
                                    label: Text('Go now')),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ButtonBar(alignment: MainAxisAlignment.spaceEvenly, children: [
                  TextButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryColor,
                        foregroundColor: AppColors.accentColor),
                    icon: Icon(
                      Icons.view_agenda,
                    ),
                    label: Text(
                      'View Details',
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ActivityDetail(
                            activityModel: activities[index],
                            userModel: widget.user),
                      ));
                    },
                  ),
                  TextButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryColor,
                        foregroundColor: AppColors.accentColor),
                    icon: Icon(Icons.heart_broken),
                    label: Text('Uninterest'),
                    onPressed: () async {
                      _showUninterestedDialog(context, () {
                        activityBloc.add(ActivityUninterestEvent(
                            activities[index].id, widget.user.id));
                      });
                    },
                  ),
                ])
              ],
              animateTrailing: true,
              leading: Icon(Icons.event, color: AppColors.secondaryColor),
              title: Text(activities[index].title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: AppColors.secondaryColor)),
              subtitle: Text(formattedDate.format(activities[index].date),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: AppColors.secondaryColor)),
            ),
          ],
        );
      },
    );
  }

  Widget createdActivityList(List<ActivityModel> activities) {
    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            ExpansionTileCard(
              trailing: Icon(Icons.arrow_drop_down_circle,
                  color: AppColors.secondaryColor),
              initialPadding: EdgeInsets.all(8),
              finalPadding: EdgeInsets.all(10),
              baseColor: AppColors.mainColor,
              expandedColor: AppColors.accentColor,
              expandedTextColor: AppColors.accentColor,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 300,
                          child: StreamBuilder<List<ActivityUserModel>>(
                            stream: ActivityUserRepository()
                                .getActivityUsersByActivity(
                                    activities[index].id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator(
                                        color: AppColors.accentColor));
                              }
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(
                                    child: Text('No participants yet',
                                        style: TextStyle(
                                            color: AppColors.accentColor)));
                              }

                              final userIds = snapshot.data!
                                  .map((activityUser) => activityUser.userId)
                                  .toList();

                              return FutureBuilder<List<UserModel>>(
                                future: Future.wait(userIds.map((userId) async {
                                  return await UserRepository()
                                      .getUserById(userId);
                                })),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (!userSnapshot.hasData ||
                                      userSnapshot.data!.isEmpty) {
                                    return Center(
                                        child: Text(
                                            'No participant details available'));
                                  }

                                  final participants = userSnapshot.data!;
                                  return Column(
                                    children: [
                                      Text(
                                          '${participants.length} Participants',
                                          style: TextStyle(
                                              color: AppColors.accentColor)),
                                      Expanded(
                                        child: ListView.builder(
                                          prototypeItem: ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      participants[0]
                                                          .avatarUrl!),
                                            ),
                                            title: Text(participants[0].name,
                                                style: TextStyle(
                                                    color:
                                                        AppColors.accentColor)),
                                          ),
                                          itemCount: participants.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              leading: CircleAvatar(
                                                backgroundImage:
                                                    CachedNetworkImageProvider(
                                                        participants[index]
                                                            .avatarUrl!),
                                              ),
                                              title: Text(
                                                  participants[index].name,
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .accentColor)),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                  '${activities[index].location.formattedAddress}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style:
                                      TextStyle(color: AppColors.accentColor)),
                              Flexible(
                                flex: 3,
                                child: Container(
                                  width: 400,
                                  child: GoogleMap(
                                    markers: {
                                      Marker(
                                          markerId: MarkerId(activities[index]
                                              .location
                                              .formattedAddress),
                                          position: LatLng(
                                              activities[index]
                                                  .location
                                                  .latitude,
                                              activities[index]
                                                  .location
                                                  .longitude))
                                    },
                                    myLocationButtonEnabled: false,
                                    initialCameraPosition: CameraPosition(
                                        target: LatLng(
                                            activities[index].location.latitude,
                                            activities[index]
                                                .location
                                                .longitude),
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
                                        foregroundColor:
                                            AppColors.secondaryColor),
                                    onPressed: () async {
                                      final coords = Coords(
                                          activities[index].location.latitude,
                                          activities[index].location.longitude);
                                      final title = activities[index]
                                          .location
                                          .formattedAddress
                                          .split(',')[0];

                                      final availableMaps =
                                          await MapLauncher.installedMaps;

                                      mapsSheet(context, availableMaps, coords,
                                          title);
                                    },
                                    icon: Icon(Icons.card_travel),
                                    label: Text('Go now')),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ButtonBar(alignment: MainAxisAlignment.spaceEvenly, children: [
                  TextButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryColor,
                        foregroundColor: AppColors.accentColor),
                    icon: Icon(
                      Icons.view_agenda,
                    ),
                    label: Text(
                      'View Details',
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ActivityDetail(
                            activityModel: activities[index],
                            userModel: widget.user),
                      ));
                    },
                  ),
                  TextButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryColor,
                        foregroundColor: AppColors.accentColor),
                    icon: Icon(Icons.delete),
                    label: Text('Delete'),
                    onPressed: () async {
                      _showDeleteDialog(context, () {
                        activityBloc
                            .add(ActivityDeleteEvent(activities[index].id));
                      });
                    },
                  ),
                ])
              ],
              animateTrailing: true,
              leading:
                  Icon(Icons.event_available, color: AppColors.secondaryColor),
              title: Text(activities[index].title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: AppColors.secondaryColor)),
              subtitle: Text(formattedDate.format(activities[index].date),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: AppColors.secondaryColor)),
            ),
          ],
        );
      },
    );
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

  Widget secondaryMenuTile(
      String title, String subTitle, IconData icon, bool isSelected,
      {required Function onTap}) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.secondaryColor : AppColors.accentColor,
      ),
      child: ListTile(
        title: Text(title,
            style: TextStyle(
                color: isSelected
                    ? AppColors.accentColor
                    : AppColors.secondaryColor),
            overflow: TextOverflow.ellipsis,
            maxLines: 1),
        subtitle: Text(subTitle,
            style: TextStyle(
                color: isSelected
                    ? AppColors.accentColor
                    : AppColors.secondaryColor),
            overflow: TextOverflow.ellipsis,
            maxLines: 1),
        leading: Icon(icon,
            color:
                isSelected ? AppColors.accentColor : AppColors.secondaryColor),
        trailing: Icon(Icons.arrow_forward_ios,
            color:
                isSelected ? AppColors.accentColor : AppColors.secondaryColor),
        onTap: () {
          onTap();
        },
      ),
    );
  }

  Skeletonizer Skeletion() {
    final activitySkeletionItem = ActivityModel(
        id: '',
        title: BoneMock.name,
        description: BoneMock.longParagraph,
        image: '',
        date: DateTime.now(),
        startTime: TimeOfDay.now(),
        endTime: TimeOfDay.now(),
        location: LocationModel(BoneMock.address, latitude: 0, longitude: 0),
        category: ActivityCategory.art,
        createdBy: '',
        createdAt: DateTime.now(),
        ratings: [],
        reviews: [],
        status: ActivityStatus.active);

    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        itemCount: 7,
        itemBuilder: (context, index) {
          return fakeActivityItems(
              context,
              [
                activitySkeletionItem,
                activitySkeletionItem,
                activitySkeletionItem,
                activitySkeletionItem,
                activitySkeletionItem,
                activitySkeletionItem,
                activitySkeletionItem
              ],
              index);
        },
      ),
    );
  }

  Column ActivityItems(BuildContext context, ActivityModel activity, int index,
      ActivitySuccessState state) {
    return Column(children: [
      GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ActivityDetail(
              activityModel: activity,
              userModel: widget.user,
            ),
          ));
        },
        child: ActivityTile(activity),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        SizedBox(width: 10),
        Expanded(child: interestButton(activity)),
      
        
        SizedBox(width: 10),
      ]),
      Divider()
    ]);
  }

  Container interestButton(ActivityModel activity) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.accentColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: StreamBuilder<ActivityUserModel?>(
          stream: ActivityUserRepository()
              .getActivityUser(activity.id, widget.user.id),
          builder: (context, snapshot) {
            final isInterested = snapshot.data != null;

            final activityUserModel = ActivityUserModel(
                activityUserId: widget.user.id.compareTo(activity.id) < 0
                    ? "${widget.user.id}${activity.id}"
                    : "${activity.id}${widget.user.id}",
                activityId: activity.id,
                userId: widget.user.id,
                joinedAt: DateTime.now());

            return LikeButton(
              mainAxisAlignment: MainAxisAlignment.center,
              likeBuilder: (isLiked) {
                return isLiked
                    ? Icon(Icons.favorite, color: AppColors.secondaryColor)
                    : Icon(Icons.favorite_border,
                        color: AppColors.secondaryColor);
              },
              countBuilder: (count, isLiked, text) {
                var color = AppColors.secondaryColor;
                Widget result;
                if (isLiked) {
                  result = Text(
                    'Interested',
                    style: TextStyle(color: color),
                  );
                  return result;
                } else {
                  result = Text(
                    'Interest',
                    style: TextStyle(color: color),
                  );
                  return result;
                }
              },
              likeCount: 5,
              likeCountAnimationType: LikeCountAnimationType.part,
              isLiked: isInterested,
              countPostion: CountPostion.right,
              onTap: (isLiked) async {
                if (isLiked) {
                  _showUninterestedDialog(context, () {
                    activityBloc.add(ActivityUninterestEvent(
                        activityUserModel.activityId,
                        activityUserModel.userId));
                  });
                } else {
                  activityBloc.add(ActivityInterestEvent(
                      activityUserModel: activityUserModel));

                  return !isLiked;
                }
              },
            );
          }),
    );
  }
}

Column fakeActivityItems(
    BuildContext context, List<ActivityModel> activities, int index) {
  return Column(children: [
    GestureDetector(onTap: () {}, child: FakeActivityTile(activities[index])),
    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      SizedBox(width: 10),
      Expanded(
        child: TextButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentColor,
              foregroundColor: AppColors.secondaryColor),
          onPressed: () {},
          label: Text('Interested'),
          icon: LikeButton(),
        ),
      ),
      SizedBox(width: 10),
    ]),
    Divider()
  ]);
}

Widget ActivityTile(ActivityModel activity) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.maxFinite,
        height: 300,
        child: Stack(
          children: [
            ClipRect(
              child: Hero(
                tag: activity.id,
                child: Container(
                  width: double.maxFinite,
                  height: 300,
                  child: CachedNetworkImage(
                    imageUrl: activity.image,
                    fit: BoxFit.cover,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            ClipRect(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                ),
                alignment: Alignment.topLeft,
                child: ListTile(
                  isThreeLine: true,
                  title: Text(
                    activity.title,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    activity.description,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white, size: 20),
                      Text(formattedDate.format(activity.date),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: 10,
              child: Container(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 20),
                    SizedBox(width: 5),
                    Text(activity.location.formattedAddress.split(',')[0],
                        style: TextStyle(color: Colors.white)),
                    SizedBox(width: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget FakeActivityTile(ActivityModel activity) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.maxFinite,
        height: 300,
        child: Stack(
          children: [
            ClipRect(
              child: Container(
                width: double.maxFinite,
                height: 300,
                child: CachedNetworkImage(
                  imageUrl: activity.image,
                  fit: BoxFit.cover,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            ClipRect(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
               
                ),
                alignment: Alignment.topLeft,
                child: ListTile(
                  isThreeLine: true,
                  title: Text(
                    activity.title,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    activity.description,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white, size: 20),
                      Text(formattedDate.format(activity.date),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: 10,
              child: Container(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 20),
                    SizedBox(width: 5),
                    Text(activity.location.formattedAddress.split(',')[0],
                        style: TextStyle(color: Colors.white)),
                    SizedBox(width: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showUninterestedDialog(
    BuildContext context, VoidCallback onConfirmUninterest) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm', style: TextStyle(color: AppColors.mainColor)),
        content: Text(
            'Are you sure you want to remove this from your activities?',
            style: TextStyle(color: AppColors.mainColor)),
        actions: <Widget>[
          TextButton(
            child: Text('No', style: TextStyle(color: AppColors.mainColor)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Yes', style: TextStyle(color: AppColors.mainColor)),
            onPressed: () {
              onConfirmUninterest();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void _showDeleteDialog(BuildContext context, VoidCallback onConfirmUninterest) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm', style: TextStyle(color: AppColors.mainColor)),
        content: Text('Are you sure you want to delete this activity?',
            style: TextStyle(color: AppColors.mainColor)),
        actions: <Widget>[
          TextButton(
            child: Text('No', style: TextStyle(color: AppColors.mainColor)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Yes', style: TextStyle(color: AppColors.mainColor)),
            onPressed: () {
              onConfirmUninterest();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

String filterConditionToField(String filterCondition) {
  switch (filterCondition) {
    case 'date':
      return 'date';
    case 'created time':
      return 'createdAt';
    case 'name':
      return 'title';
    default:
      return 'date';
  }
}
