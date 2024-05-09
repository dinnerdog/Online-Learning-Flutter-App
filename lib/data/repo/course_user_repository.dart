import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test1/data/model/course_model.dart';
import 'package:test1/data/model/course_user_model.dart';
import 'package:test1/data/repo/assignment_user_repository.dart';
import 'package:test1/data/repo/course_repository.dart';

class CourseUserRepository {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('course_users');



Stream<CourseUserModel?> getCourseUserByUserIdAndCourseId(String userId, String courseId) {
    return collection
        .where('userId', isEqualTo: userId)
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CourseUserModel.fromFirestore(doc))
            .first);
  }



Stream<List<CourseUserModel>> getCourseUserByUserId(String userId)  {
    return collection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CourseUserModel.fromFirestore(doc))
            .toList());
  }

  
 


Future<void> updateStar(String courseId, String userId, StarRating updatedStar) async {

  try {
     final courseModel = await CourseRepository().getCourse(courseId);
  final maxStar = courseModel!.stars.where((element) => element.name == updatedStar.name).first.rating;
  


  final assignmentUpdatedStar = StarRating(name: updatedStar.name, rating: ((updatedStar.rating/ 100) * maxStar).ceil() );
  final urlUpdatedStar = StarRating(name: updatedStar.name, rating: maxStar);

  final querySnapshot = await collection
      .where('courseId', isEqualTo: courseId)
      .where('userId', isEqualTo: userId)
      .get();

  for (var doc in querySnapshot.docs) {
    
     final data = doc.data() as Map<String, dynamic>;
    List<dynamic> earnedStars = data['earnedStars'];

    
    List<StarRating> stars = earnedStars.map((starMap) => StarRating.fromMap(starMap)).toList();

   
    int index = stars.indexWhere((star) => star.name == updatedStar.name);
    if (index != -1) {
      stars[index] =  updatedStar.name.startsWith('http') ? urlUpdatedStar : assignmentUpdatedStar; 
    } 


    await doc.reference.update({
      'earnedStars': stars.map((star) => star.toMap()).toList(),
    });
  }
  } catch (e) {
    print('Error updating star: $e');
  
  }
}



Future<void> distributeStars(String courseId, StarRating star) async {
    try {
      final querySnapshot = await collection
          .where('courseId', isEqualTo: courseId)
          .get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.update({
          'earnedStars': FieldValue.arrayUnion([star.toMap()])
        });
      }
    } catch (e) {
      print('Error distributing stars: $e');
    }

  }

  Stream<List<CourseUserModel>> courseUserStream({
      String? userId, String? courseId}) {
    Query query = collection;

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }
    if (courseId != null) {
      query = query.where('courseId', isEqualTo: courseId);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => CourseUserModel.fromFirestore(doc))
        .toList());
  }

Future<List<String>> getUserIdsByCourseId(String courseId) async {
  final userIds = await FirebaseFirestore.instance
    .collection('course_users')
    .where('courseId', isEqualTo: courseId)
    .get()
    .then((value) => value.docs
        .map((doc) => doc.data()['userId'] as String) 
        .toList()); 

  return userIds;
}

  // 删除我的课程
Future<void> deleteMyCourse({String? userId, String? courseId}) async {
    if (userId == null){
        final querySnapshot = await collection
        .where('courseId', isEqualTo: courseId)
        .get();
         for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
    } else if (courseId == null){
        final querySnapshot = await collection
        .where('userId', isEqualTo: userId)
        .get();
         for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
    } else {
        final querySnapshot = await collection
        .where('courseId', isEqualTo: courseId)
        .where('userId', isEqualTo: userId)
        .get();
         for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
    }
   
  }





      
      
  Future<void> removeStudentFromCourse(String courseId, String userId) async {
    final querySnapshot = await collection
        .where('courseId', isEqualTo: courseId)
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }


  Future<void> updateMyCourse(String id, CourseUserModel courseUser) async {
    await collection.doc(id.toString()).update(courseUser.toMap());
  }


  Future<String?> addCourseUser(CourseUserModel courseUser) async {
    
      String docId = "${courseUser.courseId}${courseUser.userId}";
    await collection.doc(docId).set(courseUser.toMap(), SetOptions(merge: true)); 
    await collection.doc(docId).update({"id": docId});

  }

  Future<void> addCourseUserByCourseIdAndUserId(String courseId, String userId) async {
    final courseUser = CourseUserModel(
      courseId: courseId,
      userId: userId,
      earnedStars: [],
    );
    
    
    await addCourseUser(courseUser);
    await AssignmentUserRepository().giveAssignmentToUser(courseId, userId);

  }

    Future<void> addCourseUserByCourseIdAndUserIds(String courseId, List<String> userIds) async {
    for (var userId in userIds) {
      await addCourseUserByCourseIdAndUserId(courseId, userId);
    }
  }
  
    

  
}
