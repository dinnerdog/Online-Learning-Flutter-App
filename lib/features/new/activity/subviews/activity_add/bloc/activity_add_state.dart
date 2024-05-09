part of 'activity_add_bloc.dart';

abstract class ActivityAddState {}

abstract class ActivityAddActionState extends ActivityAddState {}

class ActivityAddInitial extends ActivityAddState {}

class ActivityAddSubmitLoadingState extends ActivityAddState {}

class ActivityAddSubmitSuccessState extends ActivityAddActionState {}

class ActivityAddSubmitActionState extends ActivityAddActionState {}



