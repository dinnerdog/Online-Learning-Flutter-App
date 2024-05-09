part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  
  @override
  List<Object> get props => [];
}


abstract class ProfileActionState extends ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoadingState extends ProfileState {}

final class ProfileSuccessState extends ProfileState {
  final UserModel user;
  final int stars;
  final IncentiveModel incentiveModel;
  final List<CourseUserModel> courseUsers;


  ProfileSuccessState(this.user, this.stars, this.incentiveModel, this.courseUsers);
  

  List<Object> get props => [user, stars, incentiveModel, courseUsers];
}


final class editProfileSuccessState extends ProfileState {
  final UserModel user;
  editProfileSuccessState(this.user);
  List<Object> get props => [user];
}


final class UserAvatarLoadingState extends ProfileState {}


