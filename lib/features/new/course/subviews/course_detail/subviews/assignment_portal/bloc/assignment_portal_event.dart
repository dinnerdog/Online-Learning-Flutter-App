part of 'assignment_portal_bloc.dart';



abstract class AssignmentPortalEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AssignmentPortalFilePicked extends AssignmentPortalEvent {
  final List<File> files;

  AssignmentPortalFilePicked(this.files);

  @override
  List<Object?> get props => [files];
}

class AssignmentPortalFileUploaded extends AssignmentPortalEvent {
    final List<File> files;
    final AssignmentUserModel assignmentUserModel;

  AssignmentPortalFileUploaded(this.files, this.assignmentUserModel);

  @override
  List<Object?> get props => [files];
}

class AssignmentPortalSubmit extends AssignmentPortalEvent {
  final AssignmentUserModel assignmentUserModel;

  AssignmentPortalSubmit({
    required this.assignmentUserModel,
  
  });

  @override
  List<Object?> get props => [assignmentUserModel];
}

