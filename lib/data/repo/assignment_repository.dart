import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test1/data/model/assignment_model.dart';
import 'package:test1/data/repo/assignment_user_repository.dart'; // 假设这是您的AssignmentModel路径

class AssignmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 添加作业到课程

  Stream<AssignmentModel> getAssignmentByIdStream(String courseId, String assignmentId)  {
    return _firestore.collection('courses').doc(courseId).collection('assignments').doc(assignmentId).snapshots().map((snapshot) => AssignmentModel.fromFirestore(snapshot));
  }
  

  Future<String> addAssignment(String courseId, AssignmentModel assignment) async {
    
    final assignmentId = (await _firestore.collection('courses').doc(courseId).collection('assignments').add(assignment.toMap())).id;
    
  return assignmentId;
  }

  // 获取特定课程的所有作业
  Stream<List<AssignmentModel>> getAssignmentsForCourse(String courseId) {
    return _firestore.collection('courses').doc(courseId).collection('assignments').snapshots().map((snapshot) => snapshot.docs.map((doc) => AssignmentModel.fromFirestore(doc)).toList());
  }


  // 更新特定课程的特定作业
  Future<void> updateAssignment(String courseId, String assignmentId, Map<String, dynamic> newData) async {
    await _firestore.collection('courses').doc(courseId).collection('assignments').doc(assignmentId).update(newData);
  }

  Future<void> deleteAssignment(String courseId, String assignmentId) async {
    await _firestore.collection('courses').doc(courseId).collection('assignments').doc(assignmentId).delete();

  }

  Future<void> updateAssignmentField(String courseId, String assignmentId, String field,  String newValue) async {
    await _firestore.collection('courses').doc(courseId).collection('assignments').doc(assignmentId).update({field: newValue});
  }
}
