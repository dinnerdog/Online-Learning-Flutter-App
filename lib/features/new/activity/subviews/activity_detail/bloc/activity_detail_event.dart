part of 'activity_detail_bloc.dart';

abstract class ActivityDetailEvent extends Equatable {


  @override
  List<Object> get props => [];
}


class ActivityDetailInitialEvent extends ActivityDetailEvent {
 final ActivityModel activity;

  ActivityDetailInitialEvent({required this.activity});

}

class ActivityDetailEditClickEvent extends ActivityDetailEvent {
  final ActivityModel activity;

  ActivityDetailEditClickEvent({required this.activity});
  
}

class ActivityDetailEditQuitClickEvent extends ActivityDetailEvent {
}

class ActivityDetailEditSaveClickEvent extends ActivityDetailEvent {
  final ActivityModel activityModel;

  ActivityDetailEditSaveClickEvent({required this.activityModel});
}

class ActivityDetailEditRefreshEvent extends ActivityDetailEvent {
}

class ActivitysSubscriptionRequested extends ActivityDetailEvent {
  final String activityId;
  ActivitysSubscriptionRequested({required this.activityId});

}

class ActivityUpdated extends ActivityDetailEvent {
  final ActivityModel activity;
  ActivityUpdated(this.activity);
}

class ActivityDetailEditDeleteEvent extends ActivityDetailEvent {

}

class ActivityDetailEditDeleteCancelEvent extends ActivityDetailEvent {
    final ActivityModel activity;
  ActivityDetailEditDeleteCancelEvent(this.activity);
}

class ActivityDetailEditDeleteConfirmEvent extends ActivityDetailEvent {
  final String activityId;

  ActivityDetailEditDeleteConfirmEvent({required this.activityId});
}
