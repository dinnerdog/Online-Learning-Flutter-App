part of 'my_trophies_bloc.dart';

sealed class MyTrophiesState extends Equatable {
  const MyTrophiesState();
  
  @override
  List<Object> get props => [];
}

final class MyTrophiesInitial extends MyTrophiesState {}
