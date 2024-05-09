import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test1/data/model/course_model.dart';
import 'package:test1/data/repo/assignment_repository.dart';
import 'package:test1/data/repo/course_user_repository.dart';
import 'package:test1/global/common/toast.dart';

class CourseRepository {
  final CollectionReference courseCollection = FirebaseFirestore.instance.collection('courses');





  Stream<List<CourseModel>> coursesStream() {
    return courseCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CourseModel.fromFirestore(doc);
      }).toList();
    });
  }

Future<void> deleteStars(String courseId, String name) async {
   try {
   
     final docSnapshot = await courseCollection.doc(courseId).get();
    final data = docSnapshot.data() as Map<String, dynamic>;
    final List<dynamic> stars = data['stars'];

    final updatedStars = stars.where((star) => star['name'] != name).toList();

    await courseCollection.doc(courseId).update({'stars': updatedStars});

   
  } catch (e) {
    print('Error deleting document: $e');
  }
  }




Future<void> configureStars(String courseId, StarRating starRating) async {
      try {

    await courseCollection.doc(courseId).update({
      'stars': FieldValue.arrayUnion([starRating.toMap()]),
    });
    } catch (e) {
      print(e.toString());
      showToast(message: e.toString());
    }
  }

  Future<void> updateStars(String courseId, String name, int newRating) async {
  try {
   
    final docSnapshot = await courseCollection.doc(courseId).get();
    final data = docSnapshot.data() as Map<String, dynamic>;
    List<dynamic> stars = data['stars'];

   
    final updatedStars = stars.map((star) {
      final Map<String, dynamic> starMap = star as Map<String, dynamic>;
      if (starMap['name'] == name) {
       
        return {'name': name, 'rating': newRating}; 
      }
      return star; 
    }).toList();

    await courseCollection.doc(courseId).update({'stars': updatedStars});
   
  } catch (e) {
    print('星级更新错误: $e');
  }
}




  Future<String?> createCourse({required CourseModel course}) async {
    try {
      Map<String, dynamic> data = course.toMap();
      final documentRef = await courseCollection.add(data);
      return documentRef.id;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }


  Stream<CourseModel?> courseStream(String documentId) {
    return courseCollection.doc(documentId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return CourseModel.fromFirestore(snapshot);
      }
      return null; 
    });
  }


  Future<void> updateCourseField(String documentId, String field, dynamic value) async {
    try {
      await courseCollection.doc(documentId).update({field: value});
    } catch (e) {
      print(e.toString());
      showToast(message: e.toString());
    }
  }


  Future<void> updateCourse(String documentId, CourseModel course) async {
    try {
      Map<String, dynamic> data = course.toMap();
      await courseCollection.doc(documentId).update(data);
    } catch (e) {
      print(e.toString());
      showToast(message: e.toString());
    }
  }

  Future<CourseModel?> getCourse(String documentId) async {
    try {
      var doc = await courseCollection.doc(documentId).get();
      if (doc.exists) {
        return CourseModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print(e.toString());
      showToast(message: e.toString());
      return null;
    }
  }


  Future<List<CourseModel>> getAllCourses() async {
    try {
      var querySnapshot = await courseCollection.get();
      return querySnapshot.docs.map((doc) {
        return CourseModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }


  Future<void> deleteCourse(String documentId) async {
    try {
     
      await courseCollection.doc(documentId).delete();

         QuerySnapshot assignmentsSnapshot = await courseCollection.doc(documentId).collection('assignments').get();
    for (QueryDocumentSnapshot assignmentDoc in assignmentsSnapshot.docs) {
      await assignmentDoc.reference.delete();
    }
      await CourseUserRepository().deleteMyCourse(courseId: documentId);
    } catch (e) {
      print(e.toString());
      showToast(message: e.toString());
    }

  }



  Future<void> deleteCourseResource(String courseId, String resourceUrl) async {
    try {
      await courseCollection.doc(courseId).update({
        'resourceUrls': FieldValue.arrayRemove([resourceUrl]),
      });
    } catch (e) {
      print(e.toString());
      showToast(message: e.toString());
    }
  }

  Future<void> appendCourseResources(String courseId, List<String> resourceUrls) async {
    try {
      await courseCollection.doc(courseId).update({
        'resourceUrls': FieldValue.arrayUnion(resourceUrls),
      });
    } catch (e) {
      print(e.toString());
      showToast(message: e.toString());
    }
  }
  


  
Future<List<CourseModel>> getCoursesByIds(List<String> courseIds) async {
    List<CourseModel> courses = [];
    for (String courseId in courseIds) {
      var documentSnapshot = await FirebaseFirestore.instance.collection('courses').doc(courseId).get();
      if (documentSnapshot.exists) {
        CourseModel course = CourseModel.fromFirestore(documentSnapshot);
        courses.add(course);
      }
    }
    return courses;
  }

}
