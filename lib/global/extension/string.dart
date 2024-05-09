import 'package:test1/data/model/activity_model.dart';
import 'package:test1/data/model/user_model.dart';

extension StringExtension on String {
  ActivityCategory toCategory() {
    return ActivityCategory.values.firstWhere(
      (c) => c.toString().split('.').last == this,
      orElse: () => ActivityCategory.other,
    );
  }

  ActivityStatus toStatus() {
    return ActivityStatus.values.firstWhere(
      (c) => c.toString().split('.').last == this,
      orElse: () => ActivityStatus.active,
    );
  }

    Role toRole() {
    return Role.values.firstWhere(
      (c) => c.toString().split('.').last == this,
      
      orElse: () => Role.student,
    );
  }



  Gender toGender() {
    return Gender.values.firstWhere(
      (c) => c.toString().split('.').last == this,
      orElse: () => Gender.sercret,
    );
  }
}