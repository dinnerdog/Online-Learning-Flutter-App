part of 'activity_bloc.dart';

abstract class ActivityEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ActivityInitialEvent extends ActivityEvent {
  final String sortCondition;
  final bool isAscending;

  ActivityInitialEvent({required this.sortCondition, required this.isAscending});

  @override
  List<Object> get props => [sortCondition, isAscending];
}

class ActivityAddEvent extends ActivityEvent {
}

class MyActivityEvent extends ActivityEvent {
}


class ActivityRefreshEvent extends ActivityEvent {
  final DateTime lastUpdated;


  ActivityRefreshEvent({required this.lastUpdated});

 @override
  List<Object> get props => [lastUpdated];
}

class ActivitiesSubscriptionRequested extends ActivityEvent {
  final String sortCondition;
  final  bool isAscending;

  ActivitiesSubscriptionRequested({ required this.sortCondition, required this.isAscending});

  @override
  List<Object> get props => [sortCondition, isAscending];
}

class ActivitiesUpdated extends ActivityEvent {
  final List<ActivityModel> activities;

  ActivitiesUpdated(this.activities);
}

class ActivityInterestEvent extends ActivityEvent {

  final ActivityUserModel activityUserModel;
  ActivityInterestEvent({required this.activityUserModel});

}


class ActivityUninterestEvent extends ActivityEvent {

  final String activityId;
  final String userId;
  ActivityUninterestEvent(this.activityId, this.userId);

}

class ActivityDeleteEvent extends ActivityEvent {
  final String activityId;

  ActivityDeleteEvent(this.activityId);
}


class SwitchToMyActivityEvent extends ActivityEvent {
     final String sortCondition;
  final  bool isAscending;
  final String userId;

  SwitchToMyActivityEvent({required this.sortCondition, required this.isAscending, required this.userId});


}

class SwitchToCreatedActivityEvent extends ActivityEvent {
     final String sortCondition;
  final  bool isAscending;
  final String userId;

  SwitchToCreatedActivityEvent({required this.sortCondition, required this.isAscending, required this.userId});


}


class ActivityFilterClickEvent extends ActivityEvent {
  final String sortCondition;
  final bool isAscending;

  ActivityFilterClickEvent({required this.sortCondition, required this.isAscending});

  @override
  List<Object> get props => [sortCondition, isAscending];
}

class MyActivitiesSubscriptionRequested extends ActivityEvent {
   final String sortCondition;
  final  bool isAscending;
  final String userId;
  
  MyActivitiesSubscriptionRequested({required this.userId, required this.sortCondition, required this.isAscending});
}

class MyActivitiesUpdated extends ActivityEvent {
  final List<ActivityModel> activities;

  MyActivitiesUpdated(this.activities);
}

class CreatedActivitiesSubscriptionRequested extends ActivityEvent {
   final String sortCondition;
  final  bool isAscending;
  final String userId;
  
  CreatedActivitiesSubscriptionRequested({required this.userId, required this.sortCondition, required this.isAscending});
}

class CreatedActivitiesUpdated extends ActivityEvent {
  final List<ActivityModel> activities;

  CreatedActivitiesUpdated(this.activities);
}
