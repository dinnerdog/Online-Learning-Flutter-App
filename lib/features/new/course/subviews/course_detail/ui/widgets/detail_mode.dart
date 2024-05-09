part of '../course_detail.dart';

Column detailMode(
    CourseModel course,
    BuildContext context,
    CourseDetailSuccessState state,
    CourseDetailBloc courseDetailBloc,
    String userId,
    UserModel user) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      courseCover(course),
      buttonsView(context, state, courseDetailBloc, userId, course, user),
      courseInfo(course, userId, context, courseDetailBloc),
      if (courseDetailBloc.myRole == Role.teacher ||
          courseDetailBloc.myRole == Role.admin)
        _buildAssignmentCompletionStatusSection(
            userId, course, context, courseDetailBloc),
      if (courseDetailBloc.myRole == Role.student ||
          courseDetailBloc.myRole == Role.admin)
        _buildAssignmentToBeDoneSection(userId, course, courseDetailBloc),
    ],
  );
}

Widget courseCover(CourseModel course) {
  return Container(
    padding: EdgeInsets.only(left: 100, right: 100, bottom: 80),
    decoration: BoxDecoration(
        gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.mainColor,
        Colors.black.withOpacity(0.9),
      ],
    )),
    child: CachedNetworkImage(
      imageBuilder: (context, imageProvider) => Column(
        children: [
          Hero(
            tag: course.id,
            child: Container(
              height: 300,
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Text(
            course.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      imageUrl: course.imageUrl,
      errorWidget: (context, url, error) => Icon(Icons.error),
      placeholder: (context, url) => Skeletonizer(
        child: Container(
          padding: EdgeInsets.only(left: 100, right: 100, bottom: 80),
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.mainColor,
              Colors.black.withOpacity(0.9),
            ],
          )),
          child: Column(
            children: [
              Container(
                height: 300,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              Text(
                course.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      fit: BoxFit.cover,
    ),
  );
}

Widget courseInfo(CourseModel course, String userId, BuildContext context,
    CourseDetailBloc courseDetailBloc) {
  return ExpansionTileCard(
      leading: Icon(Icons.event_available, color: AppColors.secondaryColor),
      title: Text(course.name,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(color: AppColors.secondaryColor)),
      subtitle: Text(
          '${course.startDate.formalizeOnly() + ' to ' + course.endDate.formalizeOnly()}',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(color: AppColors.secondaryColor)),
      trailing:
          Icon(Icons.arrow_drop_down_circle, color: AppColors.secondaryColor),
      initiallyExpanded: true,
      animateTrailing: true,
      initialPadding: EdgeInsets.all(8),
      finalPadding: EdgeInsets.all(10),
      baseColor: AppColors.mainColor,
      expandedColor: AppColors.accentColor,
      expandedTextColor: AppColors.accentColor,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.secondaryColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading:
                            Icon(Icons.description, color: AppColors.mainColor),
                        title: Text('Description',
                            style: TextStyle(color: AppColors.mainColor)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(course.description,
                            style: TextStyle(color: AppColors.mainColor)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Column(
                    children: [
                      StreamBuilder<UserModel?>(
                          stream: UserRepository()
                              .getUserByIdStream(course.createdBy),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            } else if (snapshot.hasData) {
                              final teacher = snapshot.data!;

                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: AppColors.secondaryColor,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            leading: Icon(Icons.person,
                                                color: AppColors.mainColor),
                                            title: Text('Teacher',
                                                style: TextStyle(
                                                    color:
                                                        AppColors.mainColor)),
                                          ),
                                          Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: CachedNetworkImage(
                                                  imageUrl: teacher.avatarUrl!,
                                                  placeholder: (context, url) =>
                                                      Skeletonizer(
                                                    child: Container(
                                                      width: 80,
                                                      height: 100,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: Colors.grey[300],
                                                      ),
                                                    ),
                                                  ),
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      Container(
                                                    width: 80,
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                  child: Container(
                                                padding: EdgeInsets.all(8),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ListTile(
                                                      title: Text('Motto',
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .mainColor)),
                                                      subtitle: Text(
                                                          teacher.motto ??
                                                              'This teacher have no motto yet',
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .mainColor)),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                            ],
                                          ),
                                          ListTile(
                                            trailing: IconButton(
                                              icon: Icon(Icons.chat),
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        AppColors.accentColor),
                                                foregroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.white),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Chatroom(
                                                      anotherUserId: teacher.id,
                                                      currentUserId: userId,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            title: Text(teacher.name,
                                                style: TextStyle(
                                                    color:
                                                        AppColors.mainColor)),
                                            subtitle: Text(teacher.email,
                                                style: TextStyle(
                                                    color:
                                                        AppColors.mainColor)),
                                          ),
                                        ],
                                      ),
                                    )),
                              );
                            } else {
                              return Text('No teacher found');
                            }
                          }),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.secondaryColor,
                      ),
                      child: ExpansionTileCard(
                        elevation: 0,
                        expandedTextColor: AppColors.accentColor,
                        animateTrailing: true,
                        initialPadding: EdgeInsets.all(8),
                        finalPadding: EdgeInsets.all(18),
                        trailing: Icon(Icons.arrow_drop_down_circle,
                            color: AppColors.mainColor),
                        leading: Icon(Icons.people, color: AppColors.mainColor),
                        title: Text('Enrolled Students',
                            style: TextStyle(color: AppColors.mainColor)),
                        subtitle: Text(
                            'Tap to view the students enrolled in this course',
                            style: TextStyle(color: AppColors.mainColor)),
                        children: [
                          StreamBuilder<List<CourseUserModel>>(
                            stream: CourseUserRepository()
                                .courseUserStream(courseId: course.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text("Error: ${snapshot.error}");
                              } else if (snapshot.hasData) {
                                final courseUserModels = snapshot.data!;

                                if (courseUserModels.length == 0) {
                                  return Container(
                                    padding: EdgeInsets.all(8),
                                    width: double.maxFinite,
                                    height: 100,
                                    child: Center(
                                        child: Text('No enrolled students yet',
                                            style: TextStyle(
                                                color: AppColors.mainColor))),
                                  );
                                }
                                return SingleChildScrollView(
                                  child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: courseUserModels.length,
                                      itemBuilder: (context, index) {
                                        return StreamBuilder<UserModel?>(
                                          stream: UserRepository()
                                              .getUserByIdStream(
                                                  courseUserModels[index]
                                                      .userId),
                                          builder: (context, futureSnapshot) {
                                            if (futureSnapshot
                                                    .connectionState ==
                                                ConnectionState.waiting) {
                                              return ListTile(
                                                  title: Text('Loading...'));
                                            } else if (futureSnapshot
                                                .hasError) {
                                              return ListTile(
                                                  title: Text(
                                                      'Error in conversion'));
                                            } else if (futureSnapshot.hasData) {
                                              final user = futureSnapshot.data!;
                                              return ListTile(
                                                leading: CircleAvatar(
                                                  backgroundImage:
                                                      CachedNetworkImageProvider(
                                                          user.avatarUrl!),
                                                ),
                                                title: Text(user.name,
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .accentColor)),
                                                subtitle: Text(user.classId ?? user.email,
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .accentColor)),
                                                trailing:
                                                    (courseDetailBloc.myRole ==
                                                                Role.teacher ||
                                                            courseDetailBloc
                                                                    .myRole ==
                                                                Role.admin)
                                                        ? SizedBox(
                                                          width: MediaQuery.of(context).size.width * 0.2,
                                                          child: ButtonBar(

                                                              
                                                              children: [
                                                                 IconButton(
                                                                  icon: Icon(
                                                                    Icons
                                                                        .verified,
                                                                    color: AppColors
                                                                        .accentColor,
                                                                  ),
                                                                  onPressed: () {
                                                                    showAdaptiveDialog(context: context,
                                                                  
                                                                    
                                                                     builder: 
                                                                     (context) => 
                                                                      AlertDialog(
                                                                        contentTextStyle: TextStyle(color: AppColors.mainColor),
                                                                        backgroundColor: AppColors.secondaryColor,
                                                                        title: Text('Give Certificate'),
                                                                        content: Text('Are you sure you want to give a certificate to ${user.name}'),
                                                                        actions: [
                                                                          TextButton(
                                                                            onPressed: () {
                                                                              courseDetailBloc.add(CourseGiveCertificateEvent(course: course, userId: user.id));
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child: Text('Yes', 
                                                                            style: TextStyle(color: AppColors.accentColor),
                                                                            ),
                                                                          ),
                                                                          TextButton(
                                                                            onPressed: () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child: Text('No',
                                                                            style: TextStyle(color: AppColors.accentColor),
                                                                            
                                                                            ),
                                                                          )
                                                                        ],
                                                                      )

                                                                    
                                                                    
                                                                    
                                                                    );
                                                                  },
                                                                ),
                                                                IconButton(
                                                                  icon: Icon(
                                                                    Icons
                                                                        .delete_rounded,
                                                                    color: AppColors
                                                                        .accentColor,
                                                                  ),
                                                                  onPressed: () {
                                                                    courseDetailBloc.add(CourseDeleteEnrolledUserEvent(
                                                                        courseId:
                                                                            course
                                                                                .id,
                                                                        userId: user
                                                                            .id));
                                                                  },
                                                                )
                                                              ],
                                                            ),
                                                        )
                                                        : null,
                                              );
                                            } else {
                                              return ListTile(
                                                  title: Text(
                                                      'No user details available'));
                                            }
                                          },
                                        );
                                      }),
                                );
                              } else {
                                return Text('No enrolled users found');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ]);
}

Widget buttonsView(
    BuildContext context,
    CourseDetailSuccessState state,
    CourseDetailBloc courseDetailBloc,
    String userId,
    CourseModel course,
    UserModel user) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      color: AppColors.mainColor,
    ),
    padding: EdgeInsets.all(8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (courseDetailBloc.myRole == Role.teacher ||
            courseDetailBloc.myRole == Role.admin)
          TextButton.icon(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColors.accentColor),
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddAssignment(courseId: course.id),
              ));
            },
            label: Text('Add Assignment'),
            icon: Icon(Icons.add),
          ),
        TextButton.icon(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColors.accentColor),
              foregroundColor:
                  MaterialStateProperty.all(AppColors.secondaryColor)),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  AssginmentResources(courseModel: course, userModel: user),
            ));
          },
          icon: Icon(Icons.file_copy),
          label: Text('Resources'),
        ),
        TextButton.icon(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColors.accentColor),
              foregroundColor:
                  MaterialStateProperty.all(AppColors.secondaryColor)),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  CourseProgress(courseModel: course, userModel: user),
            ));
          },
          icon: Icon(Icons.assignment),
          label: Text('The progress'),
        ),
        if (courseDetailBloc.myRole == Role.teacher ||
            courseDetailBloc.myRole == Role.admin)
          TextButton.icon(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColors.accentColor),
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) => StreamBuilder(
                    stream: Rx.combineLatest2(
                        UserRepository().getAllStudents(),
                        CourseUserRepository()
                            .courseUserStream(courseId: course.id),
                        (a, b) => [a, b]),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final allUsers = snapshot.data![0] as List<UserModel>;
                        final courseUsers =
                            snapshot.data![1] as List<CourseUserModel>;
                        return InviteDialog(
                          allUsers: allUsers,
                          courseUsers: courseUsers,
                          courseId: course.id,
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return AlertDialog(
                          title: Text('Loading...'),
                        );
                      } else {
                        return AlertDialog(
                          title: Text('No data found'),
                        );
                      }
                    }),
              );
            },
            icon: Icon(Icons.person_add),
            label: Text('invite students'),
          ),
        // TextButton.icon(
        //   style: ButtonStyle(
        //       backgroundColor: MaterialStateProperty.all(Colors.red),
        //       foregroundColor: MaterialStateProperty.all(Colors.white)),
        //   onPressed: () {
        //     // TO DO
        //   },
        //   icon: Icon(Icons.cancel),
        //   label: Text('Withdraw'),
        // ),
      ],
    ),
  );
}

Widget _buildAssignmentCompletionStatusSection(
    String userId,
    CourseModel course,
    BuildContext context,
    CourseDetailBloc courseDetailBloc) {
  return StreamBuilder<List<AssignmentModel>>(
      stream: AssignmentRepository().getAssignmentsForCourse(course.id),
      builder: (context, snapshot) {
        return ExpansionTileCard(
            animateTrailing: true,
            initialPadding: EdgeInsets.all(8),
            finalPadding: EdgeInsets.all(10),
            baseColor: AppColors.mainColor,
            expandedColor: AppColors.accentColor,
            trailing: Icon(Icons.arrow_drop_down_circle,
                color: AppColors.secondaryColor),
            expandedTextColor: AppColors.accentColor,
            subtitle: Text('Assignments Completion Status',
                style: TextStyle(color: AppColors.secondaryColor)),
            title: Text('Assignments Completion Status for ${course.name}',
                style: TextStyle(color: AppColors.secondaryColor)),
            children: [
              SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    StreamBuilder<List<AssignmentModel>>(
                      stream: AssignmentRepository()
                          .getAssignmentsForCourse(course.id),
                      builder: (context, snapshot) {
                        if (snapshot.data?.isEmpty ?? snapshot.data == null) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.secondaryColor,
                              ),
                              child: ListTile(
                                textColor: AppColors.mainColor,
                                title: Text('No assignments yet'),
                              ),
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else if (snapshot.hasData) {
                          final assignmentModels = snapshot.data!;
                          return Column(children: [
                            if (assignmentModels.isNotEmpty)
                              Container(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: assignmentModels.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: AppColors.secondaryColor,
                                        ),
                                        child: Column(
                                          children: [
                                            ListTile(
                                                textColor: AppColors.mainColor,
                                                leading: SizedBox(
                                                  width: 50,
                                                  height: 50,
                                                  child: CachedNetworkImage(
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    imageUrl:
                                                        assignmentModels[index]
                                                                .imageUrl ??
                                                            '',
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                title: Text(
                                                    assignmentModels[index]
                                                        .name),
                                                subtitle: Text(
                                                    // format the date
                                                    'Deadline: ${formattedDate.format(assignmentModels[index].deadLine)}'),
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        AssignmentCompletion(
                                                      assignmentModel:
                                                          assignmentModels[
                                                              index],
                                                      courseModel: course,
                                                    ),
                                                  ));
                                                },
                                                trailing: StreamBuilder<
                                                    List<dynamic>>(
                                                  stream: Rx.combineLatest2(
                                                    AssignmentUserRepository()
                                                        .getAssignmentSubmissions(
                                                            assignmentModels[
                                                                    index]
                                                                .id),
                                                    CourseUserRepository()
                                                        .courseUserStream(
                                                            courseId:
                                                                course.id),
                                                    (List<AssignmentUserModel>
                                                            assignmentSubmissions,
                                                        List<CourseUserModel>
                                                            courseUsers) {
                                                      return [
                                                        assignmentSubmissions,
                                                        courseUsers
                                                      ];
                                                    },
                                                  ),
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<
                                                                  List<dynamic>>
                                                              snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return CircularProgressIndicator();
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return Text(
                                                          "Error: ${snapshot.error}");
                                                    } else if (snapshot
                                                        .hasData) {
                                                      final assignmentSubmissions =
                                                          snapshot.data![0] as List<
                                                              AssignmentUserModel>;

                                                      var submitted =
                                                          assignmentSubmissions
                                                              .where((element) =>
                                                                  element
                                                                      .isSubmitted ==
                                                                  true)
                                                              .toList();

                                                      return Text(
                                                        'Submissions: ${submitted.length} / ${assignmentSubmissions.length}',
                                                      );
                                                    } else {
                                                      return Text(
                                                          'No data found');
                                                    }
                                                  },
                                                )),
                                            ButtonBar(
                                              children: [
                                                TextButton.icon(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(AppColors
                                                                .accentColor),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.white),
                                                  ),
                                                  onPressed: () {
                                                    _showAssignmentDetail(
                                                        context,
                                                        assignmentModels[index],
                                                        course,
                                                        courseDetailBloc);
                                                  },
                                                  icon: Icon(Icons.assignment),
                                                  label: Text('View'),
                                                ),
                                                TextButton.icon(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(AppColors
                                                                .accentColor),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.white),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            AssignmentCompletion(
                                                          assignmentModel:
                                                              assignmentModels[
                                                                  index],
                                                          courseModel: course,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  icon: Icon(Icons
                                                      .assignment_turned_in),
                                                  label: Text('Review'),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ]);
                        } else {
                          return Text('No assignments yet');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ]);
      });
}

Widget _buildAssignmentToBeDoneSection(
    String userId, CourseModel course, CourseDetailBloc courseDetailBloc) {
  return ExpansionTileCard(
      animateTrailing: true,
      initialPadding: EdgeInsets.all(8),
      finalPadding: EdgeInsets.all(10),
      baseColor: AppColors.mainColor,
      expandedColor: AppColors.accentColor,
      trailing:
          Icon(Icons.arrow_drop_down_circle, color: AppColors.secondaryColor),
      expandedTextColor: AppColors.accentColor,
      subtitle: Text('Assignments To Be Done',
          style: TextStyle(color: AppColors.secondaryColor)),
      title: Text('Assignments you have to finish for ${course.name}',
          style: TextStyle(color: AppColors.secondaryColor)),
      children: [
        SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(children: [
            StreamBuilder(
              stream: AssignmentUserRepository()
                  .getAssignmentsForUserCourse(userId, course.id),
              builder: (context, snapshot) {
                if (snapshot.data?.isEmpty ?? snapshot.data == null) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.secondaryColor,
                      ),
                      child: ListTile(
                        textColor: AppColors.mainColor,
                        title: Text('No assignments yet'),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (snapshot.hasData) {
                  final assignmentUserModels =
                      snapshot.data as List<AssignmentUserModel>;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: assignmentUserModels.length,
                    itemBuilder: (context, index) {
                      return StreamBuilder<AssignmentModel?>(
                        stream: AssignmentRepository().getAssignmentByIdStream(
                            course.id,
                            assignmentUserModels[index].assignmentId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else if (snapshot.hasData) {
                            final assignment = snapshot.data!;

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppColors.secondaryColor,
                                ),
                                child: Column(
                                  children: [
                                    ListTile(
                                      textColor: AppColors.mainColor,
                                      leading: SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: CachedNetworkImage(
                                          imageUrl: assignment.imageUrl ?? '',
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      title: Text(assignment.name),
                                      subtitle: Text(
                                        // format the date
                                        'Deadline: ${formattedDate.format(assignment.deadLine)}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Text(
                                        'status: ${assignmentUserModels[index].isSubmitted ? assignmentUserModels[index].score == 0 ? 'Submitted' : 'Score: ${assignmentUserModels[index].score}' : 'Not Submitted'}',
                                        style: TextStyle(
                                          color: assignmentUserModels[index]
                                                  .isSubmitted
                                              ? assignmentUserModels[index]
                                                          .score ==
                                                      0
                                                  ? Colors.amber
                                                  : Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      onTap: () {
                                        if (assignmentUserModels[index]
                                            .isSubmitted) {
                                          showAssginmentDialog(
                                              context,
                                              courseDetailBloc,
                                              assignmentUserModels[index],
                                              assignment);
                                        } else {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) =>
                                                AssignmentPortal(
                                              assignmentUserModel:
                                                  assignmentUserModels[index],
                                            ),
                                          ));
                                        }
                                      },
                                    ),
                                    ButtonBar(
                                      children: [
                                        TextButton.icon(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    AppColors.accentColor),
                                            foregroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.white),
                                          ),
                                          onPressed: () {
                                            _showAssignmentDetail(
                                                context,
                                                assignment,
                                                course,
                                                courseDetailBloc);
                                          },
                                          icon: Icon(Icons.assignment),
                                          label: Text('View'),
                                        ),
                                        TextButton.icon(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    AppColors.accentColor),
                                            foregroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.white),
                                          ),
                                          onPressed: () {
                                            if (assignmentUserModels[index]
                                                .isSubmitted) {
                                              showToast(
                                                  message:
                                                      'You have already submitted the assignment');
                                              return;
                                            }

                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AssignmentPortal(
                                                  assignmentUserModel:
                                                      assignmentUserModels[
                                                          index],
                                                ),
                                              ),
                                            );
                                          },
                                          icon:
                                              Icon(Icons.assignment_turned_in),
                                          label: Text('Complete'),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Text('No data found');
                          }
                        },
                      );
                    },
                  );
                } else {
                  return Text('No assignments found');
                }
              },
            ),
          ]),
        ),
      ]);
}

showAssginmentDialog(
    BuildContext context,
    CourseDetailBloc assignmentPortalBloc,
    AssignmentUserModel assignmentUserModel,
    AssignmentModel assignmentModel) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        final filesFuture = listFiles(
            'assignments/${assignmentUserModel.courseId}/${assignmentUserModel.assignmentId}/${assignmentUserModel.userId}');

        return SingleChildScrollView(
          child: Column(
            children: [
              if (assignmentUserModel.score == 0)
                ungradedSubview(
                    assignmentUserModel, assignmentModel, filesFuture)
              else
                Column(
                  children: [
                    ListTile(
                      title: Text('View The Grade!',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      subtitle: Text('The teacher has graded your assignment'),
                    ),
                    dateSubview(assignmentUserModel, assignmentModel),
                    fileSubview(filesFuture),
                    Card.outlined(
                      child: ListTile(
                        leading: Icon(Icons.score),
                        title: Text('Score:'),
                        subtitle: Text(' ${assignmentUserModel.score} / 100'),
                      ),
                    ),
                    Card.outlined(
                      child: ListTile(
                        leading: Icon(Icons.comment),
                        title: Text('Comment by teacher:'),
                        subtitle: Text(' ${assignmentUserModel.review}'),
                      ),
                    ),
                    Card.outlined(
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.emoji_events),
                            title: Text('Incentives:'),
                            subtitle: Text(
                                'You have earned the following badges for your hard work!'),
                          ),
                          StreamBuilder(
                            stream: IncentiveRepository()
                                .getIncentivesForUserStream(
                                    assignmentUserModel.userId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text("Error: ${snapshot.error}");
                              } else if (snapshot.hasData) {
                                final incentiveModel = snapshot.data!;
                                final badges = incentiveModel.badges;
                                if (badges.isEmpty) {
                                  return Text('You can get badges next time!');
                                } else {
                                  return GridView(
                                    shrinkWrap: true,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 5,
                                      crossAxisSpacing: 10.0,
                                      mainAxisSpacing: 4.0,
                                    ),
                                    children: badges
                                        .map((badge) => buildBadge(
                                              badge.badgeName,
                                            ))
                                        .toList(),
                                  );
                                }
                              } else {
                                return Text('No incentives found');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                )
            ],
          ),
        );
      });
}

SingleChildScrollView ungradedSubview(AssignmentUserModel assignmentUserModel,
    AssignmentModel assignmentModel, Future<List<Reference>> filesFuture) {
  return SingleChildScrollView(
    child: Column(
      children: [
        ListTile(
          title: Text('Relax!',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          subtitle: Text('The teacher has not graded your assignment yet'),
        ),
        dateSubview(assignmentUserModel, assignmentModel),
        fileSubview(filesFuture),
      ],
    ),
  );
}

Card dateSubview(
    AssignmentUserModel assignmentUserModel, AssignmentModel assignmentModel) {
  return Card.outlined(
    child: ListTile(
      leading: Icon(Icons.date_range),
      title: Text('Assignment Submitted Date:'),
      trailing:
          assignmentUserModel.submittedDate!.isBefore(assignmentModel.deadLine)
              ? Text(
                  'On Time',
                  style: TextStyle(color: Colors.green),
                )
              : Text(
                  'Late',
                  style: TextStyle(color: Colors.red),
                ),
      subtitle:
          Text(' ${formattedDate.format(assignmentUserModel.submittedDate!)}'),
    ),
  );
}

Card fileSubview(Future<List<Reference>> filesFuture) {
  return Card.outlined(
    child: Column(
      children: [
        ListTile(
          leading: Icon(Icons.file_copy),
          title: Text('Assignment Files:'),
          subtitle: Text('The files you submitted'),
        ),
        FutureBuilder<List<Reference>>(
            future: filesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Icon(Icons.error);
              } else if (snapshot.hasData) {
                final List<Reference> files = snapshot.data!;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 4.0,
                  ),
                  padding: EdgeInsets.all(8),
                  shrinkWrap: true,
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<FullMetadata>(
                      future: files[index].getMetadata(),
                      builder: (context, metadataSnapshot) {
                        if (metadataSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (metadataSnapshot.hasError) {
                          return Icon(Icons.error);
                        } else {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey[200]!,
                                  Colors.grey[400]!,
                                ],
                              ),
                            ),
                            child: _buildFileItem(
                                metadataSnapshot.data!, files[index]),
                          );
                        }
                      },
                    );
                  },
                );
              } else {
                return Text('No files found');
              }
            }),
      ],
    ),
  );
}

Widget _buildFileItem(FullMetadata metadata, Reference ref) {
  bool isImage = metadata.contentType?.startsWith('image/') ?? false;
  bool isVideo = metadata.contentType?.startsWith('video/') ?? false;

  if (isImage || isVideo) {
    return FutureBuilder<dynamic>(
      future: ref.getDownloadURL(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Icon(Icons.error);
        } else {
          return GridTile(
            header: Row(
              children: [
                Flexible(
                  child: Text(
                    ref.name,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            child: CachedNetworkImage(
              imageUrl: snapshot.data,
              fit: BoxFit.cover,
              placeholder: (context, url) => Icon(Icons.image),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          );
        }
      },
    );
  } else {
    return GridTile(
      child: Icon(Icons.insert_drive_file),
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(ref.name, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

void _showAssignmentDetail(BuildContext context, AssignmentModel assignment,
    CourseModel course, CourseDetailBloc courseDetailBloc) {
  showDialog(
    barrierLabel: 'Assignment Detail',
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColors.mainColor,
        iconColor: AppColors.mainColor,
        titleTextStyle: TextStyle(color: AppColors.secondaryColor),
        contentTextStyle: TextStyle(color: AppColors.mainColor),
        title: Text(assignment.name, style: TextStyle(fontSize: 24)),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.secondaryColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading:
                            Icon(Icons.description, color: AppColors.mainColor),
                        title: Text('Description',
                            style: TextStyle(color: AppColors.mainColor)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${assignment.description}'),
                      ),
                    ],
                  )),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.secondaryColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading:
                          Icon(Icons.date_range, color: AppColors.mainColor),
                      title: Text('Due Date',
                          style: TextStyle(color: AppColors.mainColor)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${assignment.deadLine.formalize()}'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.secondaryColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(Icons.help, color: AppColors.mainColor),
                      title: Text('Instructions',
                          style: TextStyle(color: AppColors.mainColor)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${assignment.submissionInstructions}'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          if (courseDetailBloc.myRole == Role.teacher ||
              courseDetailBloc.myRole == Role.admin)
            TextButton.icon(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(AppColors.accentColor),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              icon: Icon(Icons.edit),
              label: Text('Edit Assignment'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddAssignment(
                      assignment: assignment,
                      courseId: course.id,
                    ),
                  ),
                );
              },
            ),
          TextButton.icon(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColors.accentColor),
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
            label: Text('Close'),
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
