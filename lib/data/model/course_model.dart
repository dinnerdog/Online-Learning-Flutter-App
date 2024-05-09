import 'package:cloud_firestore/cloud_firestore.dart';


class StarRating {
  String name;
  int rating;

  StarRating({required this.name, required this.rating});

 
  factory StarRating.fromMap(Map<String, dynamic> data) {
    return StarRating(
      name: data['name'],
      rating: data['rating'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rating': rating,
    };
  }

  
}



class CourseModel {
  String id;
  String name;
  DateTime startDate;
  DateTime endDate;
  String description;
  String imageUrl;
  DateTime createdAt;
  String createdBy;
  List<String> resourceUrls;
 List<StarRating> stars;
  



  CourseModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
    required this.createdBy,
    required this.resourceUrls,
    required this.stars

  });

  factory CourseModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return CourseModel(
      id: doc.id,
      name: data['name'],
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'],
      resourceUrls: List<String>.from(data['resourceUrls'] ?? [],),
      stars: (data['stars'] as List<dynamic> ?? []).map((starData) => StarRating.fromMap(starData)).toList(),

    );
  }


   sum() {

    int resourceUrls = 0;
    int assignments = 0;

  
    stars.fold<void>(null, (previousValue, element) {
      if (element.name.startsWith('https')) {
        resourceUrls += element.rating;
      } else {
        assignments += element.rating;
      }
    });

    return  [resourceUrls,assignments];
   
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'startDate': startDate,
        'endDate': endDate,
        'description': description,
        'imageUrl': imageUrl,
        'createdAt': createdAt,
        'createdBy': createdBy,
        'resourceUrls': resourceUrls,
       'stars': stars.map((star) => star.toMap()).toList(),
  
      };
}
