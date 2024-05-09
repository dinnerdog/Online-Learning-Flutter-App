part of 'assignment_portal_bloc.dart';

// assignment_portal_bloc.dart

abstract class AssignmentPortalState extends Equatable {
  AssignmentPortalState();

  @override
  List<Object?> get props => [];
}



class AssignmentPortalInitial extends AssignmentPortalState {}

class AssignmentPortalFilePicking extends AssignmentPortalState {}

class AssignmentPortalFilePickedState extends AssignmentPortalState {
  final List<File> files;

  AssignmentPortalFilePickedState(this.files);

  @override
  List<Object?> get props => [files];
}

class AssignmentPortalFileUploading extends AssignmentPortalState {
 final double progress; // 进度值，范围从0.0到1.0

  AssignmentPortalFileUploading({required this.progress});

  @override
  List<Object> get props => [progress];
}

class AssignmentPortalFileUploadedState extends AssignmentPortalState {}

class AssignmentPortalError extends AssignmentPortalState {
  final String error;

  AssignmentPortalError(this.error);

  @override
  List<Object?> get props => [error];
}
