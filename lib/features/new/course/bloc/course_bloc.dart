import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test1/data/model/assignment_model.dart';
import 'package:test1/data/model/assignment_user_model.dart';
import 'package:test1/data/model/course_model.dart';
import 'package:test1/data/model/course_user_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/assignment_user_repository.dart';
import 'package:test1/data/repo/course_repository.dart';
import 'package:test1/data/repo/course_user_repository.dart';
import 'package:test1/features/new/course/ui/course.dart';



part 'course_event.dart';
part 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {





  List<CourseModel> _myCourses = [];
  List<CourseModel> _allCourses = [];

  





  late UserModel user;

  StreamSubscription? _courseSubscription;
  StreamSubscription? _myCourseSubscription;

      Role myRole = Role.teacher;
      String query = '';

  CourseBloc() : super(CourseInitial()) {
    on<CourseInitialEvent>(courseInitialEvent);
    on<CourseSubscriptionRequested>(_onSubscriptionRequested);
    on<CourseUpdated>(_onCourseUpdated);
    on<MyCourseSubscriptionRequested>(_onMySubscriptionRequested);
    on<MyCourseUpdated>(_onMyCourseUpdated);
    on<CourseClickAddEvent>(courseClickAddEvent);
    on<CourseEnrollEvent>(courseEnrollEvent);
    on<QueryChangedEvent>(queryChangedEvent);
    // on<CourseAssignmentEvent>(courseAssignmentEvent);

  
  }

  FutureOr<void> _onSubscriptionRequested(
      CourseSubscriptionRequested event, Emitter<CourseState> emit) {
    _courseSubscription?.cancel();
    _courseSubscription = CourseRepository().coursesStream().listen((courses) {
      add(CourseUpdated(courses));
    }, onError: (error) {
      print(error);
    });



  }

  @override
  Future<void> close() {
    _courseSubscription?.cancel();
    _myCourseSubscription?.cancel();
    return super.close();
  }

  FutureOr<void> _onCourseUpdated(
      CourseUpdated event, Emitter<CourseState> emit) {
    _allCourses = event.courses;


    if (myRole == Role.teacher || myRole == Role.admin) {
     _myCourses = _allCourses.where((element) => element.createdBy == user.id).toList(); 
    }
   
   

    _emitSuccessState(emit);
  }

  FutureOr<void> courseClickAddEvent(
      CourseClickAddEvent event, Emitter<CourseState> emit) {
    emit(CourseClickAddActionState());
  }

  FutureOr<void> _onMySubscriptionRequested(
      MyCourseSubscriptionRequested event, Emitter<CourseState> emit) async {

        


    _myCourseSubscription?.cancel();

    if(myRole == Role.teacher || myRole == Role.admin) {
      return;
    }



    _myCourseSubscription = CourseUserRepository()
        .courseUserStream(userId: event.userId)
        .listen((courseUsers) async {
      List<CourseModel> courses = await CourseRepository().getCoursesByIds(
          courseUsers
              .map((courseUser) => courseUser.courseId.toString())
              .toList());

      add(MyCourseUpdated(courses));
    }, onError: (error) {
      print(error);
    });
  }

  



  FutureOr<void> _onMyCourseUpdated(
      MyCourseUpdated event, Emitter<CourseState> emit) async {
        
    _myCourses = event.myCourses;

    _emitSuccessState(emit);
  }

  void _emitSuccessState(Emitter<CourseState> emit) {
    var  myCourses = _myCourses.where((course) => course.name.toLowerCase().contains(query.toLowerCase())).toList();
    var allCourses = _allCourses.where((course) => course.name.toLowerCase().contains(query.toLowerCase())).toList();

    

    emit(CourseSuccessState(myCourses, allCourses));
  }

  FutureOr<void> courseEnrollEvent(
      CourseEnrollEvent event, Emitter<CourseState> emit) {
    emit(CourseEnrollActionState());
    try {
      CourseUserRepository().addCourseUser(
          CourseUserModel(courseId: event.courseId, userId: event.userId, earnedStars: []));
      AssignmentUserRepository()
          .giveAssignmentToUser(event.courseId, event.userId);

      add(MyCourseSubscriptionRequested(event.userId));
    } catch (e) {
      emit(CourseErrorState());
    }
  }

  FutureOr<void> queryChangedEvent(QueryChangedEvent event, Emitter<CourseState> emit) {
    query = event.query;
 _emitSuccessState (emit);

    
  }



  FutureOr<void> courseInitialEvent(CourseInitialEvent event, Emitter<CourseState> emit) {
    _myCourses.clear();
    _allCourses.clear();

    emit(CourseLoadingState());
    add(CourseSubscriptionRequested());
    add(MyCourseSubscriptionRequested(user.id));
  }

  
}

