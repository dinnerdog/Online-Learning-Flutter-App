part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}


class UserSubscriptionRequested extends ProfileEvent {
}


class ProfileInitialEvent extends ProfileEvent {
}




class UserUpdated extends ProfileEvent {
  final UserModel user;
  UserUpdated(this.user);
}


class ItemsSubscriptionRequested extends ProfileEvent {
  final UserModel user;

  ItemsSubscriptionRequested({required this.user});


}





class ItemsUpdated extends ProfileEvent {
  final List<CourseUserModel> courseUsers;
  final IncentiveModel incentiveModel;
  

  ItemsUpdated({required this.courseUsers, required this.incentiveModel});

}




