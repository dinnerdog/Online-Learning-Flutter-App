part of 'activity_bloc.dart';

abstract class ActivityState extends Equatable {
  @override
  List<Object> get props => [];
}

abstract class ActivityActionState extends ActivityState {

}

class ActivityInitial extends ActivityState {}

class ActivityLoadingState extends ActivityState {}

class ActivityRefreshActionState extends ActivityActionState {

    final DateTime lastUpdated;

  ActivityRefreshActionState({required this.lastUpdated});



  @override
  List<Object> get props => [lastUpdated];
}

class ActivityRefreshingState extends ActivityState {
  
}

class ActivitySuccessState extends ActivityState {
  
  final List<ActivityModel> activityList;
  

  ActivitySuccessState(this.activityList);

  List<Object> get props => [activityList];
}


class ActivityFilterActionState extends ActivityActionState {

    final String sortCondition;
    final bool isAscending;

  ActivityFilterActionState({required this.sortCondition, required this.isAscending});

  List<Object> get props => [sortCondition, isAscending];
}


class ActivityErrorState extends ActivityState {}

class MyActivityState extends ActivityState {

    final List<ActivityModel> activityList;

  MyActivityState(this.activityList);

  List<Object> get props => [activityList];

}

class CreatedActivityState extends ActivityState {

    
    final List<ActivityModel> activityList;


  CreatedActivityState(this.activityList);

  List<Object> get props => [activityList];
}

class ActivityNavigateToAddActionState extends ActivityActionState {}

class ActivityInterestClickActionState extends ActivityActionState {
}

