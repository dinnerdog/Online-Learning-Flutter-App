part of 'activity_detail_bloc.dart';

abstract class ActivityDetailState extends Equatable {
 

  
  @override
  List<Object> get props => [];
}
abstract class ActivityDetailActionState extends ActivityDetailState {
  
}

class ActivityDetailInitial extends ActivityDetailState {}

class ActivityDetailLoadInProgressState extends ActivityDetailState {}

class ActivityDetailLoadSuccessState extends ActivityDetailState {
    final ActivityModel activity;

  ActivityDetailLoadSuccessState({required this.activity});
}

class ActivityDetailLoadErrorState extends ActivityDetailState {


}

class ActivityDetailEditClickActionState extends ActivityDetailActionState {
}



class ActivityDetailEditState extends ActivityDetailState {
   final ActivityModel activity;

  ActivityDetailEditState({required this.activity});
  
}

final class ActivityDetailEditSaveLoadingState extends ActivityDetailState {
}


final class ActivityDetailEditSaveSuccessState extends ActivityDetailActionState {
}

final class ActivityDetailEditSaveErrorState extends ActivityDetailState {
}


class ActivityDetailEditQuitActionState extends ActivityDetailActionState {
}

class ActivityDetailEditClickDeleteState extends ActivityDetailState {
}


class ActivityDetailEditDeleteConfirmState extends ActivityDetailActionState {
}

class ActivityDetailEditDeleteConfirmSuccessState extends ActivityDetailActionState {
}

class ActivityDetailEditDeleteConfirmSErrorState extends ActivityDetailActionState {
}