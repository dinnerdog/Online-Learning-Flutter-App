part of 'activity_add_bloc.dart';

abstract class ActivityAddEvent {}

class ActivityAddInitialEvent extends ActivityAddEvent {}

class ActivityAddSubmitEvent extends ActivityAddEvent {
  final ActivityModel activityModel;

  ActivityAddSubmitEvent({required this.activityModel});
}
