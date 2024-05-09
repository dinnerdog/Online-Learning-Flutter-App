import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:test1/data/model/assignment_user_model.dart';
import 'package:test1/data/repo/assignment_user_repository.dart';

part 'assignment_portal_event.dart';
part 'assignment_portal_state.dart';

class AssignmentPortalBloc
    extends Bloc<AssignmentPortalEvent, AssignmentPortalState> {

  AssignmentPortalBloc() : super(AssignmentPortalInitial()) {
    on<AssignmentPortalFilePicked>(_onFilePicked);
    on<AssignmentPortalFileUploaded>(_onFileUploaded);
    on<AssignmentPortalSubmit>(_onSubmit);
    
  }

  Future<void> _onFilePicked(AssignmentPortalFilePicked event,
      Emitter<AssignmentPortalState> emit) async {
    emit(AssignmentPortalFilePicking());

    emit(AssignmentPortalFilePickedState(event.files));
  }

  Future<void> _onFileUploaded(AssignmentPortalFileUploaded event,
      Emitter<AssignmentPortalState> emit) async {
    emit(AssignmentPortalFileUploading(
      progress: 0.0,
    ));

    try {
      await _uploadFile(event.files, event.assignmentUserModel, (progress) {
        emit(AssignmentPortalFileUploading(progress: progress));
      });
      emit(AssignmentPortalFileUploadedState());
    } catch (e) {
      emit(AssignmentPortalError(e.toString()));
    }
  }

  Future<void> _uploadFile(
      List<File> files, AssignmentUserModel assignmentUserModel, void Function(double) onProgress) async {
    int totalBytes = files.fold(0, (prev, file) => prev + file.lengthSync());
    int uploadedBytes = 0;

    try {
      for (File file in files) {
        // 这里是上传文件的逻辑
        await FirebaseStorage.instance
            .ref(
                'assignments/${assignmentUserModel.courseId}/${assignmentUserModel.assignmentId}/${assignmentUserModel.userId}/${file.path.substring(file.path.lastIndexOf('/') + 1)}')
            .putFile(file);

        // 假设每个文件上传完成后更新进度
        uploadedBytes += file.lengthSync();
        onProgress(uploadedBytes / totalBytes);
      }
    } catch (e) {
      throw e;
    }
  }

  FutureOr<void> _onSubmit(AssignmentPortalSubmit event, Emitter<AssignmentPortalState> emit) async{
    try{
      await AssignmentUserRepository().updateSubmissionField(event.assignmentUserModel.id!, {
  "isSubmitted": true, 
  'submittedDate': DateTime.now(),
});
    } catch 
    (e) {
      emit(AssignmentPortalError(e.toString()));

    }
  }
}
