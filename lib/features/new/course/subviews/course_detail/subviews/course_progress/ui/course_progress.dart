import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rxdart/rxdart.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:test1/data/model/assignment_model.dart';
import 'package:test1/data/model/assignment_user_model.dart';
import 'package:test1/data/model/course_model.dart';
import 'package:test1/data/model/course_user_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/assignment_repository.dart';
import 'package:test1/data/repo/assignment_user_repository.dart';
import 'package:test1/data/repo/course_repository.dart';
import 'package:test1/data/repo/course_user_repository.dart';
import 'package:test1/features/new/course/subviews/course_detail/subviews/course_progress/bloc/course_progress_bloc.dart';
import 'package:test1/main.dart';

class CourseProgress extends StatefulWidget {
  final CourseModel courseModel;
  final UserModel userModel;

  const CourseProgress(
      {super.key, required this.courseModel, required this.userModel});

  @override
  State<CourseProgress> createState() => _CourseProgressState();
}

class _CourseProgressState extends State<CourseProgress> {
  CourseProgressBloc courseProgressBloc = CourseProgressBloc();

  @override
  void initState() {
    courseProgressBloc.add(CourseProgressInitialEvent(widget.courseModel.id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        foregroundColor: AppColors.secondaryColor,
        title: Text('Course Progress'),
      ),
      body: SingleChildScrollView(
        child: BlocBuilder<CourseProgressBloc, CourseProgressState>(
          bloc: courseProgressBloc,
          builder: (context, state) {
            if (state is CourseProgressLoadingState) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is CourseProgressSuccessState) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.mainColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          textColor: AppColors.secondaryColor,
                          iconColor: AppColors.secondaryColor,
                          leading: Icon(Icons.star),
                          title: Text('Course Name: ${state.course.name}'),
                          subtitle: Text(
                              'This is the course progress of ${state.course.name}'),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        cover(),
                        SizedBox(
                          width: 10,
                        ),
                        overview(state),
                      ],
                    ),
                  ),
                  // if (widget.userModel.role == Role.teacher ||
                  //     widget.userModel.role == Role.admin)
                  //   resourcesCustomList(state),
                  if (widget.userModel.role == Role.teacher ||
                      widget.userModel.role == Role.admin)
                    assignmentCustomList(state),
                  if (widget.userModel.role == Role.student ||
                      widget.userModel.role == Role.admin)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.mainColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.star,
                                  color: AppColors.secondaryColor),
                              title: Text('Stars Earned from Assignments',
                                  style: TextStyle(
                                      color: AppColors.secondaryColor)),
                              subtitle: Text(
                                  'here are the stars you have earned from finishing the assignments.',
                                  style: TextStyle(
                                      color: AppColors.secondaryColor)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: StreamBuilder(
                                    stream: Rx.combineLatest2(
                                        AssignmentUserRepository()
                                            .getAssignmentsForUserCourse(
                                                widget.userModel.id,
                                                state.course.id),
                                        CourseUserRepository()
                                            .getCourseUserByUserIdAndCourseId(
                                                widget.userModel.id,
                                                state.course.id),
                                        (a, b) => [a, b]),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Skeletonizer(child: Container());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'),
                                        );
                                      } else if (snapshot.hasData) {
                                        final assignmentUsers =
                                            snapshot.data![0]
                                                as List<AssignmentUserModel>;
                                        final courseUser = snapshot.data![1]
                                            as CourseUserModel;

                                        return ListView.builder(
                                          padding: EdgeInsets.all(0),
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: assignmentUsers.length,
                                          itemBuilder: (context, index) {
                                            final assignmentUser =
                                                assignmentUsers[index];
                                            return StreamBuilder<
                                                    AssignmentModel>(
                                                stream: AssignmentRepository()
                                                    .getAssignmentByIdStream(
                                                        state.course.id,
                                                        assignmentUser
                                                            .assignmentId),
                                                builder:
                                                    (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState
                                                          .waiting) {
                                                    return Skeletonizer(
                                                        child: Container());
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Center(
                                                      child: Text(
                                                          'Error: ${snapshot.error}'),
                                                    );
                                                  } else if (snapshot
                                                      .hasData) {
                                                    final assignment =
                                                        snapshot.data!;
                                        
                                                    return ListTile(
                                                      textColor: AppColors
                                                          .mainColor,
                                                      iconColor: AppColors
                                                          .mainColor,
                                                      title: Text(
                                                          assignment.name, maxLines: 1, overflow: TextOverflow.ellipsis,),
                                                      subtitle: Text(assignmentUser
                                                                  .score ==
                                                              0
                                                          ? 'Not Scored Yet'
                                                          : 'Score: ${assignmentUser.score}'),
                                                      leading: Icon(
                                                          Icons.assignment),
                                                      trailing: Row(
                                                        mainAxisSize:
                                                            MainAxisSize
                                                                .min,
                                                        children: [
                                                          Icon(Icons.star),
                                                          Text(
                                                              '${courseUser.earnedStars.where((element) => element.name == assignmentUser.assignmentId).first.rating}'),
                                                        ],
                                                      ),
                                                    );
                                                  } else {
                                                    return Center(
                                                      child:
                                                          Text('No data'),
                                                    );
                                                  }
                                                });
                                          },
                                        );
                                      } else {
                                        return Center(
                                          child: Text('No data'),
                                        );
                                      }
                                    }),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),


                   
                   
                ],
              );
            } else {
              return Center(
                child: Text('Error'),
              );
            }
          },
        ),
      ),
    );
  }

  // ExpansionTileCard resourcesCustomList(CourseProgressSuccessState state) {
  //   return ExpansionTileCard(
  //     title:
  //         Text('Resources', style: TextStyle(color: AppColors.secondaryColor)),
  //     leading: Icon(Icons.folder, color: AppColors.secondaryColor),
  //     animateTrailing: true,
  //     initialPadding: EdgeInsets.all(8),
  //     trailing:
  //         Icon(Icons.arrow_drop_down_circle, color: AppColors.secondaryColor),
  //     finalPadding: EdgeInsets.all(10),
  //     baseColor: AppColors.mainColor,
  //     expandedColor: AppColors.accentColor,
  //     expandedTextColor: AppColors.accentColor,
  //     subtitle: Text('Customise each resources incetives',
  //         style: TextStyle(color: AppColors.secondaryColor)),
  //     children: [
  //       ListView.builder(
  //         physics: NeverScrollableScrollPhysics(),
  //         shrinkWrap: true,
  //         itemCount: state.course.stars
  //             .where((star) => star.name.startsWith('https'))
  //             .length,
  //         itemBuilder: (context, index) {
  //           final resourceItem = state.course.stars
  //               .where((star) => star.name.startsWith('https'))
  //               .elementAt(index);

  //           return FutureBuilder<FullMetadata?>(
  //               future: getMetadataFromDownloadURL(resourceItem.name),
  //               builder: (context, snapshot) {
  //                 if (snapshot.connectionState == ConnectionState.waiting) {
  //                   return Skeletonizer(
  //                       child: ListTile(
  //                     leading: Container(
  //                       width: 50,
  //                       height: 50,
  //                       decoration: BoxDecoration(
  //                           color: AppColors.secondaryColor,
  //                           borderRadius: BorderRadius.circular(10)),
  //                     ),
  //                     title: Text(BoneMock.fullName),
  //                     trailing: Row(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         Icon(Icons.star),
  //                         Text('${Random().nextInt(10)}'),
  //                       ],
  //                     ),
  //                   ));
  //                 }

  //                 if (snapshot.hasError) {
  //                   return Center(
  //                     child: Text('Error: ${snapshot.error}'),
  //                   );
  //                 }

  //                 if (snapshot.hasData) {
  //                   final metadata = snapshot.data!;

  //                   return Column(
  //                     children: [
  //                       ListTile(
  //                         textColor: AppColors.secondaryColor,
  //                         iconColor: AppColors.secondaryColor,
  //                         leading: metadata.contentType!.startsWith('image')
  //                             ? CachedNetworkImage(
  //                                 imageUrl: resourceItem.name,
  //                                 width: 50,
  //                                 height: 50,
  //                                 imageBuilder: (context, imageProvider) =>
  //                                     Container(
  //                                   decoration: BoxDecoration(
  //                                       borderRadius: BorderRadius.circular(10),
  //                                       image: DecorationImage(
  //                                           image: imageProvider,
  //                                           fit: BoxFit.cover)),
  //                                 ),
  //                               )
  //                             : Container(
  //                                 width: 50,
  //                                 height: 50,
  //                                 decoration: BoxDecoration(
  //                                     color: AppColors.secondaryColor,
  //                                     borderRadius: BorderRadius.circular(10)),
  //                                 child: Icon(Icons.insert_drive_file,
  //                                     size: 30, color: AppColors.mainColor),
  //                               ),
  //                         title: Text(metadata.name),
  //                         trailing: Row(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: [
  //                             Icon(Icons.star),
  //                             SizedBox(
  //                               width: 50,
  //                               child: FormBuilderDropdown(
  //                                   name: 'stars',
  //                                   dropdownColor: AppColors.mainColor,
  //                                   style: TextStyle(
  //                                       color: AppColors.secondaryColor),
  //                                   decoration: InputDecoration(
  //                                     fillColor: AppColors.mainColor,
  //                                     labelStyle: TextStyle(
  //                                         color: AppColors.secondaryColor),
  //                                     enabledBorder: null,
  //                                   ),
  //                                   initialValue: resourceItem.rating,
  //                                   onChanged: (value) {
  //                                     courseProgressBloc.add(
  //                                         CourseProgressResourceStarChangeEvent(
  //                                             courseId: state.course.id,
  //                                             name: resourceItem.name,
  //                                             rating: value as int));
  //                                   },
  //                                   items: [
  //                                     DropdownMenuItem(
  //                                       alignment: Alignment.center,
  //                                       child: Text('0',
  //                                           style: TextStyle(
  //                                               color:
  //                                                   AppColors.secondaryColor)),
  //                                       value: 0,
  //                                     ),
  //                                     DropdownMenuItem(
  //                                       alignment: Alignment.center,
  //                                       child: Text('1'),
  //                                       value: 1,
  //                                     ),
  //                                     DropdownMenuItem(
  //                                       alignment: Alignment.center,
  //                                       child: Text('2'),
  //                                       value: 2,
  //                                     ),
  //                                     DropdownMenuItem(
  //                                       alignment: Alignment.center,
  //                                       child: Text('3'),
  //                                       value: 3,
  //                                     ),
  //                                     DropdownMenuItem(
  //                                       alignment: Alignment.center,
  //                                       child: Text('4'),
  //                                       value: 4,
  //                                     ),
  //                                     DropdownMenuItem(
  //                                       alignment: Alignment.center,
  //                                       child: Text('5'),
  //                                       value: 5,
  //                                     ),
  //                                   ]),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   );
  //                 } else {
  //                   return Center(
  //                     child: Text('No data'),
  //                   );
  //                 }
  //               });
  //         },
  //       ),
  //     ],
  //   );
  // }

  ExpansionTileCard assignmentCustomList(CourseProgressSuccessState state) {
    return ExpansionTileCard(
      leading: Icon(Icons.assignment, color: AppColors.secondaryColor),
      animateTrailing: true,
      initialPadding: EdgeInsets.all(8),
      trailing:
          Icon(Icons.arrow_drop_down_circle, color: AppColors.secondaryColor),
      finalPadding: EdgeInsets.all(10),
      baseColor: AppColors.mainColor,
      expandedColor: AppColors.accentColor,
      expandedTextColor: AppColors.accentColor,
      title: Text('Assignments',
          style: TextStyle(color: AppColors.secondaryColor)),
      subtitle: Text('Customise each assignment incetives',
          style: TextStyle(color: AppColors.secondaryColor)),
      children: [
        ListView.builder(
          shrinkWrap: true,
          itemCount: state.course.stars
              .where((star) => !star.name.startsWith('https'))
              .length,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final assignmentItem = state.course.stars
                .where((star) => !star.name.startsWith('https'))
                .elementAt(index);

            return StreamBuilder<AssignmentModel>(
                stream: AssignmentRepository().getAssignmentByIdStream(
                    state.course.id, assignmentItem.name),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Skeletonizer(
                        child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      title: Text(BoneMock.fullName),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star),
                          Text('${Random().nextInt(10)}'),
                        ],
                      ),
                    ));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    final assignment = snapshot.data!;

                    return ListTile(
                      textColor: AppColors.secondaryColor,
                      iconColor: AppColors.secondaryColor,
                      leading: CachedNetworkImage(
                        imageUrl: assignment.imageUrl!,
                        width: 50,
                        height: 50,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover)),
                        ),
                      ),
                      title: Text(assignment.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star),
                          SizedBox(
                            width: 50,
                            child: FormBuilderDropdown(
                                name: 'stars',
                                dropdownColor: AppColors.mainColor,
                                style:
                                    TextStyle(color: AppColors.secondaryColor),
                                decoration: InputDecoration(
                                  fillColor: AppColors.mainColor,
                                  labelStyle: TextStyle(
                                      color: AppColors.secondaryColor),
                                  enabledBorder: null,
                                ),
                                initialValue: assignmentItem.rating,
                                onChanged: (value) {
                                  courseProgressBloc.add(
                                      CourseProgressAssignmentStarChangeEvent(
                                          courseId: state.course.id,
                                          name: assignmentItem.name,
                                          rating: value as int));
                                },
                                items: [
                                  DropdownMenuItem(
                                    alignment: Alignment.center,
                                    child: Text('0',
                                        style: TextStyle(
                                            color: AppColors.secondaryColor)),
                                    value: 0,
                                  ),
                                  DropdownMenuItem(
                                    alignment: Alignment.center,
                                    child: Text('1'),
                                    value: 1,
                                  ),
                                  DropdownMenuItem(
                                    alignment: Alignment.center,
                                    child: Text('2'),
                                    value: 2,
                                  ),
                                  DropdownMenuItem(
                                    alignment: Alignment.center,
                                    child: Text('3'),
                                    value: 3,
                                  ),
                                  DropdownMenuItem(
                                    alignment: Alignment.center,
                                    child: Text('4'),
                                    value: 4,
                                  ),
                                  DropdownMenuItem(
                                    alignment: Alignment.center,
                                    child: Text('5'),
                                    value: 5,
                                  ),
                                ]),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Center(
                      child: Text('No data'),
                    );
                  }
                });
          },
        )
      ],
    );
  }

  Expanded overview(CourseProgressSuccessState state) {
    return Expanded(
        flex: 3,
        child: Container(
            height: 300,
            decoration: BoxDecoration(
              color: AppColors.mainColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    textColor: AppColors.secondaryColor,
                    iconColor: AppColors.secondaryColor,
                    title: Text(
                        'The total stars could be owned: ${state.course.sum()[1]}'),
                    subtitle: Text('students can be earn star below:'),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       color: AppColors.secondaryColor,
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     child: ListTile(
                  //       textColor: AppColors.mainColor,
                  //       iconColor: AppColors.mainColor,
                  //       trailing: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           Icon(Icons.star),
                  //           Text('${state.course.sum()[0]}'),
                  //         ],
                  //       ),
                  //       title: Text('Course Resources'),
                  //       leading: Icon(Icons.folder),
                  //       subtitle: Text(
                  //           'Resources for the course: ${state.course.resourceUrls.length}'),
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        textColor: AppColors.mainColor,
                        iconColor: AppColors.mainColor,
                        title: Text('Course Assignments'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star),
                            Text('${state.course.sum()[1]}'),
                          ],
                        ),
                        leading: Icon(Icons.assignment),
                        subtitle: Text(
                            'Assignments for the course : ${state.assignments.length}'),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }

  Expanded cover() {
    return Expanded(
      flex: 1,
      child: Container(
        height: 300,
        child: CachedNetworkImage(
          imageUrl: widget.courseModel.imageUrl,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image:
                    DecorationImage(image: imageProvider, fit: BoxFit.cover)),
          ),
        ),
      ),
    );
  }
}

int sumStarsForUrls(Map<String, int> stars) {
  return stars.entries
      .where((entry) => isUrl(entry.key)) //
      .map((entry) => entry.value)
      .fold(0, (previousValue, element) => previousValue + element);
}

bool isUrl(String s) {
  return s.startsWith('http://') || s.startsWith('https://');
}

int sumValuesExcludingHttps(Map<String, int> stars) {
  return stars.entries
      .where((entry) => notStartsWithHttps(entry.key))
      .map((entry) => entry.value)
      .fold(0, (previousValue, element) => previousValue + element);
}

bool notStartsWithHttps(String s) {
  return !s.startsWith('https');
}

Future<FullMetadata?> getMetadataFromDownloadURL(String downloadURL) async {
  try {
    final ref = FirebaseStorage.instance.refFromURL(downloadURL);

    final metadata = await ref.getMetadata();

    return metadata;
  } catch (e) {
    print('Error occurred while getting metadata: $e');

    return null;
  }
}
