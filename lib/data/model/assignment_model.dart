import 'package:cloud_firestore/cloud_firestore.dart';



class AssignmentType {
  static const String assignment = 'assignment';
  static const String quiz = 'quiz';
  static const String paint = 'paint';
}

class AssignmentModel {
  String id;
  String name;
  String courseId;
  DateTime assignedDate;
  DateTime deadLine;
  String submissionInstructions;
  String? description;
  String? imageUrl;
  
  
  

  AssignmentModel({
    required this.id,
    required this.name,
    required this.assignedDate,
    required this.courseId,
    required this.deadLine,
    required this.submissionInstructions,
    this.description,
    this.imageUrl,
  });

  factory AssignmentModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return AssignmentModel(
      id: doc.id,
      name: data['name'],
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      courseId: data['courseId'],
      deadLine: (data['deadLine'] as Timestamp).toDate(),
      assignedDate: (data['assignedDate'] as Timestamp).toDate(),
      submissionInstructions: data['submissionInstructions'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'assignedDate': assignedDate,
        'courseId': courseId,
        'deadLine': deadLine,
        'description': description ?? '',
        'imageUrl': imageUrl ?? '',
        'submissionInstructions': submissionInstructions,
      };
}
