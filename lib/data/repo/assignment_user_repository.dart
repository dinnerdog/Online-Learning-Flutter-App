import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test1/data/model/assignment_user_model.dart';
import 'package:test1/data/model/course_model.dart';
import 'package:test1/data/repo/course_repository.dart';
import 'package:test1/data/repo/course_user_repository.dart';

class AssignmentUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  Stream<List<AssignmentUserModel>> getAssignmentsForUser(String userId) {
    return _firestore
        .collection('assignments_users')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AssignmentUserModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<AssignmentUserModel>> getAssignmentsForUserCourse(
      String userId, String courseId) {
    return _firestore
        .collection('assignments_users')
        .where('userId', isEqualTo: userId)
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AssignmentUserModel.fromFirestore(doc))
            .toList());
  }

  Future<void> submitAssignment(AssignmentUserModel submission) async {
    await _firestore.collection('assignments_users').add(submission.toMap());
  }

  Future<void> distributeAssignment(
      String assignmentId, String courseId) async {
    final userIds = await CourseUserRepository().getUserIdsByCourseId(courseId);

    for (var userId in userIds) {
      
      await _firestore.collection('assignments_users').add({
        'submissionUrl': '',
        'assignmentId': assignmentId,
        'userId': userId,
        'courseId': courseId,
        'isSubmitted': false,
        'score': 0,
        'review': '',
        'submittedDate': '',
      });
    }
  }

  Future<void> giveAssignmentToUser(String courseId, String userId) async {

    List<String> assignmentIds = [];


    QuerySnapshot assignmentsSnapshot = await _firestore
        .collection('courses') 
        .doc(courseId) 
        .collection('assignments')
        .get();
    for (var doc in assignmentsSnapshot.docs) {
      assignmentIds.add(doc.id);
    }



    for (var assignmentId in assignmentIds) {
      await _firestore.collection('assignments_users').add({
        'submissionUrl': '',
        'courseId': courseId,
        'assignmentId': assignmentId,
        'userId': userId,
        'isSubmitted': false,
        'score': 0,
        'review': '',
        'submittedDate': '',
      });

         await  CourseUserRepository().distributeStars(courseId, StarRating(
          name: assignmentId,
          rating: 0,
        ));
        
    }


    final urls = await CourseRepository().getCourse(courseId).then((value) => value!.resourceUrls);
    for (var url in urls) {
       await  CourseUserRepository().distributeStars(courseId, StarRating(
          name: url,
          rating: 0,
        ));
    }
  }

  Future<void> takeAssignmentFromUser(String courseId, String userId) async {

    List<String> assignmentIds = [];


    QuerySnapshot assignmentsSnapshot = await _firestore
        .collection('courses') 
        .doc(courseId) 
        .collection('assignments')
        .get();
    for (var doc in assignmentsSnapshot.docs) {
      assignmentIds.add(doc.id);

    }

    for (var assignmentId in assignmentIds) {
      await _firestore
          .collection('assignments_users')
          .where('assignmentId', isEqualTo: assignmentId)
          .where('userId', isEqualTo: userId)
          .get()
          .then((value) => value.docs.forEach((doc) {
                doc.reference.delete();
              }));
    }
  }

  Future<void> deleteAssignmentByCourseId(String courseId) async {
    await _firestore
        .collection('assignments_users')
        .where('courseId', isEqualTo: courseId)
        .get()
        .then((value) => value.docs.forEach((doc) {
              doc.reference.delete();
            }));
  }

Future<void> deleteAssignmentsByUserId(String courseId, String userId) async {
  await _firestore
      .collection('assignments_users')
      .where('courseId', isEqualTo: courseId)
      .where('userId', isEqualTo: userId)
      .get()
      .then((value) => value.docs.forEach((doc) {
            doc.reference.delete();
          }));
}


 Future<void> deleteDistributedAssignment(String assignmentId, String courseId) async {
  final submissions = await _firestore
      .collection('assignments_users')
      .where('assignmentId', isEqualTo: assignmentId)
      .where('courseId', isEqualTo: courseId)
      .get();

  for (var submission in submissions.docs) {
    await submission.reference.delete();
  }
}


  Stream<List<AssignmentUserModel>> getUserSubmissions(String userId) {
    return _firestore
        .collection('assignments_users')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AssignmentUserModel.fromFirestore(doc))
            .toList());
  }

// 监听特定作业的所有用户提交
  Stream<List<AssignmentUserModel>> getAssignmentSubmissions(
      String assignmentId) {
    return _firestore
        .collection('assignments_users')
        .where('assignmentId', isEqualTo: assignmentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AssignmentUserModel.fromFirestore(doc))
            .toList());
  }

  Stream<AssignmentUserModel?> getCourseSubmissions(String courseId) {
    return _firestore
        .collection('assignments_users')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty
            ? AssignmentUserModel.fromFirestore(snapshot.docs.first)
            : null);
  }

  // 获取学生的作业提交信息
  Stream<AssignmentUserModel?> getSubmissionInfo(
      String assignmentId, String userId) {
    return _firestore
        .collection('assignments_users')
        .where('assignmentId', isEqualTo: assignmentId)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty
            ? AssignmentUserModel.fromFirestore(snapshot.docs.first)
            : null);
  }

  Future<void> updateSubmissionField(
      String assignmentUserId, Map<String, dynamic> fieldsToUpdate) async {
    await _firestore
        .collection('assignments_users')
        .doc(assignmentUserId)
        .update(fieldsToUpdate);
  }

}
