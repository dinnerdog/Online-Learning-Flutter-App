import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:searchbar_animation/searchbar_animation.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:test1/data/model/assignment_model.dart';
import 'package:test1/data/model/assignment_user_model.dart';
import 'package:test1/data/model/course_model.dart';
import 'package:test1/data/model/course_user_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/assignment_user_repository.dart';
import 'package:test1/data/repo/course_user_repository.dart';
import 'package:test1/features/new/course/bloc/course_bloc.dart';
import 'package:test1/features/new/course/subviews/course_add/ui/course_add.dart';
import 'package:test1/features/new/course/subviews/course_detail/ui/course_detail.dart';
import 'package:test1/features/new/home/bloc/bloc/menu_bloc.dart';
import 'package:test1/main.dart';

final formattedDate = DateFormat('dd/MM/yyyy');

class Course extends StatefulWidget {
  final UserModel user;
  const Course({super.key, required this.user});

  @override
  State<Course> createState() => _CourseState();
}

class _CourseState extends State<Course> {
  CourseBloc courseBloc = CourseBloc();

  @override
  void initState() {
    super.initState();

    courseBloc.myRole = widget.user.role;
    courseBloc.user = widget.user;
    courseBloc.add(CourseInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController queryController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        automaticallyImplyLeading : false,
        title: Text('Courses', style: TextStyle(color: AppColors.accentColor)),
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: AppColors.accentColor,
        toolbarHeight: 80,
        actions: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: searchBar(queryController, courseBloc)),
          IconButton(
            style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all(AppColors.secondaryColor),
              backgroundColor: MaterialStateProperty.all(AppColors.accentColor),
            ),
            onPressed: () {
              BlocProvider.of<MenuBloc>(context).add(MenuToggleEvent());
            },
            icon: Icon(
              Icons.expand_outlined,
            ),
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: Container(
        color: AppColors.secondaryColor,
        child: BlocConsumer<CourseBloc, CourseState>(
            bloc: courseBloc,
            listenWhen: (previous, current) => current is CourseActionState,
            buildWhen: (previous, current) => current is! CourseActionState,
            listener: (context, state) {},
            builder: (context, state) {
              return courseSection(state, context);
            }),
      ),
    );
  }

  Skeletonizer skeletonAssignmentItem() {
    return Skeletonizer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 10),
            child: Text(
              'Assignments in total: 32',
              style: TextStyle(color: AppColors.secondaryColor, fontSize: 15),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: 2,
            itemBuilder: (context, index) {
              return ListTile(
                textColor: AppColors.secondaryColor,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8)),
                ),
                title: Text('Assignments'),
                subtitle: Text(BoneMock.longParagraph,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              );
            },
          ),
        ],
      ),
    );
  }

  Column assignmentItem(
      List<AssignmentModel> assignments, CourseModel myCourse) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 10),
          child: Text(
            'Assignments in total: ${assignments.length}',
            style: TextStyle(color: AppColors.secondaryColor, fontSize: 15),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: assignments.length,
          itemBuilder: (context, index) {
            final assignment = assignments[index];
            return ListTile(
              textColor: AppColors.secondaryColor,
              trailing: StreamBuilder<List<dynamic>>(
                stream: Rx.combineLatest2(
                  AssignmentUserRepository()
                      .getAssignmentSubmissions(assignment.id),
                  CourseUserRepository()
                      .courseUserStream(courseId: myCourse.id),
                  (List<AssignmentUserModel> assignmentSubmissions,
                      List<CourseUserModel> courseUsers) {
                    return [assignmentSubmissions, courseUsers];
                  },
                ),
                builder: (BuildContext context,
                    AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (snapshot.hasData) {
                    final assignmentSubmissions =
                        snapshot.data![0] as List<AssignmentUserModel>;

                    var submitted = assignmentSubmissions
                        .where((element) => element.isSubmitted == true)
                        .toList();

                    return Text(
                      'Submissions: ${submitted.length} / ${assignmentSubmissions.length}',
                    );
                  } else {
                    return Text('No data found');
                  }
                },
              ),
              leading: CachedNetworkImage(
                imageUrl: assignment.imageUrl!,
                imageBuilder: (context, imageProvider) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover)),
                  );
                },
              ),
              title: Text(assignment.name),
              subtitle: Text(assignment.description!,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            );
          },
        ),
      ],
    );
  }

  SingleChildScrollView courseSection(CourseState state, BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            if (state is CourseSuccessState) ...[
              myCoursesHeader(state),
              Container(
                  height: 320,
                  child: state.myCourses.isEmpty
                      ? Center(
                          child: Text(
                          'No courses enrolled yet!',
                          style: TextStyle(
                              color: AppColors.mainColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ))
                      : buildMyCourseList(state.myCourses, widget.user)),
              allCoursesHeader(state, context),
              state.allCourses.isEmpty
                  ? Container(
                      width: double.maxFinite,
                      height: 200,
                      child: Center(
                          child: Text(
                        'No courses available',
                        style: TextStyle(
                            color: AppColors.mainColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
                    )
                  : buildAllCourseGrid(
                      state.allCourses, widget.user, courseBloc),
            ],
            if (state is CourseInitial || state is CourseLoadingState) ...[
              fakeMyHeader(),
              fakeMyItems(),
              fakeMyHeader(),
               fakeAllItmes(),
            ],
          ],
        ),
      ),
    );
  }

  ListView fakeAllItmes() {
    return ListView.builder(
  physics: NeverScrollableScrollPhysics(),
  shrinkWrap: true,
  itemCount: 8,
  itemBuilder: (context, index) {

    return Skeletonizer(
      child: Container(
        padding: EdgeInsets.all(8),
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              
            ),
            height: 200,
            child: Stack(
              children: [
                ClipRect(
                    child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),

                    color: Colors.black.withOpacity(0.3),
                  ),
                )),
                Positioned(
                    left: 30,
                    top: 10,
                    child: Text(BoneMock.fullName,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white))),
                Positioned(
                    left: 30,
                    top: 40,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(BoneMock.address,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(fontSize: 14, color: Colors.white)),
                    )),
                Positioned(
                    top: 10,
                    right: 30,
                    child: Text(
                        '${formattedDate.format(DateTime.now())} - ${formattedDate.format(DateTime.now())}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70))),
                
              ],
            )),
      ),
    );
  },
);
  }

  Skeletonizer fakeMyItems() {
    return Skeletonizer(
      child: Container(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: 8,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Stack(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 300,
                        height: 300,
                      ),
                    ),
                    ClipRect(
                        child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent
                          ],
                        ),
                      ),
                    )),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Text(BoneMock.fullName,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                  ]),
                ],
              );
            },
          )),
    );
  }

  Skeletonizer fakeMyHeader() {
    return Skeletonizer(
      child: Container(
        width: double.maxFinite,
        child: Card.filled(
          color: AppColors.mainColor,
          child: ListTile(
            dense: true,
            leading:
                Icon(Icons.my_library_books, color: AppColors.secondaryColor),
            title: Text("My Courses",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryColor)),
            subtitle: Text('myCourses.length courses',
                style: TextStyle(color: AppColors.secondaryColor)),
          ),
        ),
      ),
    );
  }

  Card allCoursesHeader(CourseSuccessState state, BuildContext context) {
    return Card.filled(
      color: AppColors.mainColor,
      child: ListTile(
          dense: true,
          leading:
              Icon(Icons.my_library_books, color: AppColors.secondaryColor),
          title: Text(
            "All Courses",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryColor),
          ),
          subtitle: Text('${state.allCourses.length} courses available',
              style: TextStyle(color: AppColors.secondaryColor)),
          trailing: 
          courseBloc.myRole == Role.teacher || courseBloc.myRole == Role.admin ? TextButton.icon(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColors.accentColor),
              foregroundColor:
                  MaterialStateProperty.all(AppColors.secondaryColor),
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CourseAdd(
                        user: widget.user,
                      )));
            },
            label: Text('Add Course'),
            icon: Icon(Icons.add),
          ): null
          ),
    );
  }

  Container myCoursesHeader(CourseSuccessState state) {
    return Container(
      width: double.maxFinite,
      child: Card.filled(
        color: AppColors.mainColor,
        child: ListTile(
          dense: true,
          leading:
              Icon(Icons.my_library_books, color: AppColors.secondaryColor),
          title: Text("My Courses",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor)),
          subtitle: Text('${state.myCourses.length} courses',
              style: TextStyle(color: AppColors.secondaryColor)),
        ),
      ),
    );
  }
}



class myCourseItem extends StatelessWidget {
  const myCourseItem({
    super.key,
    required this.course,
  });

  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CachedNetworkImage(
            imageUrl: course.imageUrl!,
            fit: BoxFit.cover,
            fadeInDuration: Duration(milliseconds: 0),
            width: 300,
            height: 300,
            placeholder: (context, url) => Skeletonizer(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        ClipRect(
            child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
        )),
      ],
    );
  }
}

Widget buildMyCourseList(List<CourseModel> myCourses, UserModel user) {
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    physics: BouncingScrollPhysics(),
    shrinkWrap: true,
    itemCount: myCourses.length,
    itemBuilder: (context, index) {
      final course = myCourses[index];

      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CourseDetail(course: course, user: user)));
        },
        child: Column(
          children: [
            Stack(children: [
              Hero(
                tag: course.id,
                child: myCourseItem(course: course),
              ),
              Positioned(
                left: 10,
                top: 10,
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Text(course.name,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ]),
          ],
        ),
      );
    },
  );
}



Widget buildAllCourseGrid(
    List<CourseModel> courses, UserModel user, CourseBloc courseBloc) {
  return ListView.builder(
    physics: NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: courses.length,
    itemBuilder: (context, index) {
      final course = courses[index];
      return Container(
        padding: EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    CourseDetail(course: course, user: user)));
          },
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(course.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
              height: 200,
              child: Stack(
                children: [
                  ClipRect(
                      child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent
                        ],
                      ),
                    ),
                  )),
                  Positioned(
                      left: 30,
                      top: 10,
                      child: Text(course.name,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                  Positioned(
                      left: 30,
                      top: 40,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Text(course.description.replaceAll('\n', ''),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style:
                                TextStyle(fontSize: 14, color: Colors.white)),
                      )),
                  Positioned(
                      top: 10,
                      right: 30,
                      child: Text(
                          '${formattedDate.format(course.startDate)} - ${formattedDate.format(course.endDate)}',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70))),
                  // Positioned(
                  //     left: 10,
                  //     bottom: 10,
                  //     child: TextButton.icon(
                  //         onPressed: () {
                  //           courseBloc
                  //               .add(CourseEnrollEvent(course.id, user.id));
                  //         },
                  //         label: Text('Enroll'),
                  //         icon: Icon(Icons.add_box),
                  //         style: ButtonStyle(
                  //           backgroundColor: MaterialStateProperty.all(
                  //               AppColors.accentColor),
                  //           foregroundColor:
                  //               MaterialStateProperty.all(Colors.white),
                  //         )))
                ],
              )),
        ),
      );
    },
  );
}

Widget searchBar(TextEditingController queryController, CourseBloc courseBloc) {
  return SizedBox(
    child: SearchBarAnimation(
      textEditingController: queryController,
      durationInMilliSeconds: 1000,
      isSearchBoxOnRightSide: true,
      isOriginalAnimation: false,
      enableKeyboardFocus: true,
      buttonBorderColour: AppColors.accentColor,
      searchBoxBorderColour: AppColors.accentColor,
      buttonColour: AppColors.accentColor,
      hintTextColour: AppColors.accentColor,
      hintText: 'Search...',
      enteredTextStyle: TextStyle(
        color: AppColors.accentColor,
      ),
      onChanged: (value) {
        courseBloc.add(QueryChangedEvent(value));
      },
    
      onCollapseComplete: () {
          courseBloc.add(QueryChangedEvent(''));
        if (!queryController.text.isEmpty) {
          
          queryController.clear();
        }
      },
      trailingWidget: const Icon(Icons.search, color: AppColors.accentColor),
      secondaryButtonWidget: const Icon(
        Icons.close,
        color: AppColors.secondaryColor,
      ),
      buttonWidget: const Icon(
        Icons.search,
        color: AppColors.secondaryColor,
      ),
    ),
  );
}
