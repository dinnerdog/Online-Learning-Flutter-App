import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:test1/global/extension/string.dart';

enum Role { admin, teacher, student }

enum Gender { male, female, non_binary, sercret }



extension GenderExtension on Gender {
  String get name => toString().split('.').last;
}

extension RoleExtension on Role {
  String get name => toString().split('.').last;
}

class UserModel {
  String id;
  String name;
  String email;
  Role role;
  Gender gender;
  DateTime birthday;
  String? phoneNumber;
  String? address;
  String? motto;
  String? classId;
  String? avatarUrl;
  List<String>? createdActivityIds;


  List<String>? hobbies;


  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.birthday,
    required this.gender,
    this.phoneNumber,
    this.address,
    this.motto,
     this.classId,
    this.avatarUrl,
    this.hobbies,
    this.createdActivityIds,
  

  });

  
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    Role? role,
    Gender? gender,
    DateTime? birthday,
    String? phoneNumber,
    String? address,
    String? motto,
    String? classId,
    String? avatarUrl,
    List<String>? hobbies,
    List<String>? createdActivityIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      motto: motto ?? this.motto,
      classId: classId ?? this.classId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hobbies: hobbies ?? this.hobbies,
      createdActivityIds: createdActivityIds ?? this.createdActivityIds,
    );
  }



    

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;

    return UserModel(
        id: doc.id,
        name: data['name'],
        email: data['email'],
        role: (data['role'] as String).toRole(),
        gender: (data['gender'] as String).toGender(),
        birthday: (data['birthday'] as Timestamp).toDate(),
        classId: data['classId'],
        avatarUrl: data['avatarUrl'] ?? 'https://cdn.pixabay.com/photo/2018/01/22/01/08/heart-3097905_1280.jpg',

        phoneNumber: data['phoneNumber'] ?? null,
        address: data['address'] ?? null,
        motto: data['motto'] ?? null,

        hobbies: List<String>.from(data['hobbies'] ?? []),
        createdActivityIds: List<String>.from(data['createdActivityIds'] ?? []),
             
        );
  }


  Map<String, dynamic> toMap() {
  return {
    'id': id,
    'name': name,
    'email': email,
    'role': role.name,
     'gender': gender.name,
    'birthday': birthday,
    'phoneNumber': phoneNumber, 
    'address': address, 
    'motto': motto,
    'classId': classId, 
    'avatarUrl': avatarUrl, 
    'hobbies': hobbies,

    'createdActivityIds': createdActivityIds,

  };

}



}




