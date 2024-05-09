import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum IncentiveType {
  badge,
  star,
  certificate,
  mana,
  achievement,
}

class IncentiveModel {
  final List<BadgeModel> badges;
  final List<StarModel> stars;
  final List<CertificateModel> certificates;
  final List<ManaModel> mana;
  final List<AchievementModel> achievements;
  final String userId;

  IncentiveModel(
      {required this.badges,
      required this.stars,
      required this.certificates,
      required this.mana,
      required this.achievements,
      required this.userId});

  factory IncentiveModel.fromMap(Map<String, dynamic> data) {
    return IncentiveModel(
      badges: data['badges'],
      stars: data['stars'],
      certificates: data['certificates'],
      mana: data['mana'],
      achievements: data['achievements'],
      userId: data['userId'],
    );
  }

   factory IncentiveModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<BadgeModel> badges = data['badges'] != null
        ? List.from(data['badges']).map((badgeData) => BadgeModel.fromMap(badgeData)).toList()
        : [];
    
    List<StarModel> stars = data['stars'] != null
        ? List.from(data['stars']).map((starData) => StarModel.fromMap(starData)).toList()
        : [];

    print(data['certificates']);
    
    List<CertificateModel> certificates = data['certificates'] != null

        ? List.from(data['certificates']).map((certificateData) => CertificateModel.fromMap(certificateData)).toList()
        : [];

        

    List<ManaModel> mana = data['mana'] != null
        ? List.from(data['mana']).map((manaData) => ManaModel.fromMap(manaData)).toList()
        : [];

    List<AchievementModel> achievements = data['achievements'] != null
        ? List.from(data['achievements']).map((achievementData) => AchievementModel.fromMap(achievementData)).toList()
        : [];

    return IncentiveModel(
      badges: badges,
      stars: stars,
      certificates: certificates,
      mana: mana,
      achievements: achievements,
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toMap() => {
        'badges': badges,
        'stars': stars,
        'certificates': certificates,
        'mana': mana,
        'achievements': achievements,
        'userId': userId,
      };

  IncentiveModel copyWith({
    List<BadgeModel>? badges,
    List<StarModel>? stars,
    List<CertificateModel>? certificates,
    List<ManaModel>? mana,
    List<AchievementModel>? achievements,
    String? userId,
  }) {
    return IncentiveModel(
      badges: badges ?? this.badges,
      stars: stars ?? this.stars,
      certificates: certificates ?? this.certificates,
      mana: mana ?? this.mana,
      achievements: achievements ?? this.achievements,
      userId: userId ?? this.userId,
    );
  }
}

class AchievementModel {
  //earn when satisfy the condition
  final String achievementId;
  final String userId;
  final String achievementName;
  final String achievementDescription;
  final DateTime dateEarned;

  AchievementModel({
    required this.achievementId,
    required this.userId,
    required this.achievementName,
    required this.achievementDescription,
    required this.dateEarned,
  });

  factory AchievementModel.fromMap(Map<String, dynamic> data) {
    return AchievementModel(
      achievementId: data['achievementId'],
      userId: data['userId'],
      achievementName: data['achievementName'],
      achievementDescription: data['achievementDescription'],
        dateEarned: (data['dateEarned'] as Timestamp).toDate(),
    );
  }

  factory AchievementModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return AchievementModel(
      achievementId: data['achievementId'],
      userId: data['userId'],
      achievementName: data['achievementName'],
      achievementDescription: data['achievementDescription'],
      dateEarned: (data['dateEarned'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'achievementId': achievementId,
        'userId': userId,
        'achievementName': achievementName,
        'achievementDescription': achievementDescription,
        'dateEarned': dateEarned,
      };
}

class ManaModel {
  //earn from game
  final int manaCount;
  final String userId;
  final DateTime dateEarned;

  ManaModel(
      {required this.manaCount,
      required this.userId,
      required this.dateEarned});

  factory ManaModel.fromMap(Map<String, dynamic> data) {
    return ManaModel(
      manaCount: data['manaCount'],
      userId: data['userId'],
      dateEarned: (data['dateEarned'] as Timestamp).toDate(),
    );
  }

  factory ManaModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ManaModel(
      manaCount: data['manaCount'],
      userId: data['userId'],
      dateEarned: (data['dateEarned'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'manaCount': manaCount,
        'userId': userId,
        'dateEarned': dateEarned,
      };

  ManaModel copyWith({
    int? manaCount,
    String? userId,
    DateTime? dateEarned,
  }) {
    return ManaModel(
      manaCount: manaCount ?? this.manaCount,
      userId: userId ?? this.userId,
      dateEarned: dateEarned ?? this.dateEarned,
    );
  }
}

class CertificateModel {
  //earn when finish course while the teacher permit  the certificate
  final String certificateId;
  final String userId;
  final String courseId;
  final DateTime dateEarned;
  final String certificateName;
  final String certificateDescription;

  CertificateModel(
      {required this.certificateId,
      required this.userId,
      required this.courseId,
      required this.dateEarned,
      required this.certificateName,
      required this.certificateDescription});

  factory CertificateModel.fromMap(Map<String, dynamic> data) {
    return CertificateModel(
      certificateId: data['certificateId'],
      userId: data['userId'],
      courseId: data['courseId'],
      dateEarned: (data['dateEarned'] as Timestamp).toDate(),
      certificateName: data['certificateName'],
      certificateDescription: data['certificateDescription'],
    );
  }

  factory CertificateModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return CertificateModel(
      certificateId: data['certificateId'],
      userId: data['userId'],
      courseId: data['courseId'],
      dateEarned: (data['dateEarned'] as Timestamp).toDate(),
      certificateName: data['certificateName'],
      certificateDescription: data['certificateDescription'],
    );
  }

  Map<String, dynamic> toMap() => {
        'certificateId': certificateId,
        'userId': userId,
        'courseId': courseId,
        'dateEarned': dateEarned,
        'certificateName': certificateName,
        'certificateDescription': certificateDescription,
      };

  CertificateModel copyWith({
    String? certificateId,
    String? userId,
    String? courseId,
    DateTime? dateEarned,
    String? certificateName,
    String? certificateDescription,
  }) {
    return CertificateModel(
      certificateId: certificateId ?? this.certificateId,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      dateEarned: dateEarned ?? this.dateEarned,
      certificateName: certificateName ?? this.certificateName,
      certificateDescription:
          certificateDescription ?? this.certificateDescription,
    );
  }
}

class StarModel {
  //earn from course
  final String starId;
  final String userId;
  final String courseId;
  final DateTime dateEarned;
  final int starCount;

  StarModel(
      {required this.starId,
      required this.userId,
      required this.courseId,
      required this.dateEarned,
      required this.starCount});

  factory StarModel.fromMap(Map<String, dynamic> data) {
    return StarModel(
      starId: data['starId'],
      userId: data['userId'],
      courseId: data['courseId'],
       dateEarned: (data['dateEarned'] as Timestamp).toDate(),
      starCount: data['starCount'],
    );
  }

  factory StarModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return StarModel(
      starId: data['starId'],
      userId: data['userId'],
      courseId: data['courseId'],
      dateEarned: (data['dateEarned'] as Timestamp).toDate(),
      starCount: data['starCount'],
    );
  }

  Map<String, dynamic> toMap() => {
        'starId': starId,
        'userId': userId,
        'courseId': courseId,
        'dateEarned': dateEarned,
        'starCount': starCount,
      };
}

class BadgeModel {
  //earn from assignment

  final String badgeId;
  final String userId;
  final String courseId;
  final String assignmentId;
  final DateTime dateEarned;
  final String badgeName;
  final String badgeDescription;

  BadgeModel({
    required this.badgeId,
    required this.userId,
    required this.courseId,
    required this.assignmentId,
    required this.dateEarned,
    required this.badgeName,
    required this.badgeDescription,
  });

  factory BadgeModel.fromMap(Map<String, dynamic> data) {
    return BadgeModel(
      badgeId: data['badgeId'],
      userId: data['userId'],
      courseId: data['courseId'],
      assignmentId: data['assignmentId'],
     dateEarned: (data['dateEarned'] as Timestamp).toDate(),
      badgeName: data['badgeName'],
      badgeDescription: data['badgeDescription'],
    );
  }

  factory BadgeModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return BadgeModel(
      badgeId: data['badgeId'],
      userId: data['userId'],
      courseId: data['courseId'],
      assignmentId: data['assignmentId'],
      dateEarned: (data['dateEarned'] as Timestamp).toDate(),
      badgeName: data['badgeName'],
      badgeDescription: data['badgeDescription'],
    );
  }

  Map<String, dynamic> toMap() => {
        'badgeId': badgeId,
        'userId': userId,
        'courseId': courseId,
        'assignmentId': assignmentId,
        'dateEarned': dateEarned,
        'badgeName': badgeName,
        'badgeDescription': badgeDescription,
      };
}
