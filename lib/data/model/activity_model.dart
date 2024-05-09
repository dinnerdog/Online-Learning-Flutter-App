import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test1/global/extension/string.dart';

enum ActivityCategory {
  general,
  sport,
  music,
  art,
  food,
  travel,
  movie,
  book,
  game,
  other
}


enum ActivityStatus { outdated, active, cancelled }



extension ActivityCategoryExtension on ActivityCategory {
  String get name => toString().split('.').last;
}



extension TimeOfDayExtension on TimeOfDay {
  int toInt() {
    return this.hour * 60 + this.minute;
  }
}

extension IntExtension on int {
  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: this ~/ 60, minute: this % 60);
  }
}


class LocationModel {
  final double latitude;
  final double longitude;
  final String formattedAddress;

  LocationModel(this.formattedAddress, {required this.latitude, required this.longitude});

  factory LocationModel.fromFirestore(Map<String, dynamic> data) {
    return LocationModel(
      data['formattedAddress'],
      latitude: data['latitude'],
      longitude: data['longitude'],
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'formattedAddress': formattedAddress,
    };
  }

}

class ActivityModel {
  String id;
  String title;
  String description;
  String image;
  DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;
  LocationModel location;
  ActivityCategory category;
  String createdBy;
  DateTime createdAt;
  List<int> ratings;
  List<String> reviews;
  ActivityStatus status;

  

  ActivityModel(
      {required this.id,
      required this.title,
      required this.description,
      required this.image,
      required this.date,
      required this.startTime,
      required this.endTime,
      required this.location,
      required this.category,
      required this.createdBy,
      required this.createdAt,
      required this.ratings,
      required this.reviews,
      required this.status});

  factory ActivityModel.fromFirestore(Map<String, dynamic> data) {
    return ActivityModel(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      image: data['image'],
      createdBy: data['createdBy'],

      location: LocationModel.fromFirestore(data['location']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      date: (data['date'] as Timestamp).toDate(),
     
      startTime: (data['startTime'] as int).toTimeOfDay(),
      endTime: (data['endTime'] as int).toTimeOfDay(),
      
      status: (data['status'] as String).toStatus(),
      category: (data['category'] as String).toCategory(),
      ratings: data['ratings'] == [] ? [] : List<int>.from(data['ratings']),
      reviews: data['reviews'] == [] ? [] : List<String>.from(data['reviews']),
    
      
    
      
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'createdBy': createdBy,

      'location': location.toMap(),
      'createdAt': createdAt,
      'date': date,


      'startTime': startTime.toInt(),
      'endTime': endTime.toInt(),

      'status': status.toString(),
      'category': category.toString(),
      'ratings': ratings,
      'reviews': reviews,
    };
  }
}
