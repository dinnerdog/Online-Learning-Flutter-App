import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/data/model/assignment_model.dart';
import 'package:test1/data/model/assignment_user_model.dart';
import 'package:test1/data/model/course_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/assignment_user_repository.dart';
import 'package:test1/data/repo/user_repository.dart';
import 'package:test1/features/new/course/subviews/course_detail/subviews/assignment_completion_detail/bloc/assignment_completion_bloc.dart';
import 'package:test1/features/new/course/subviews/course_detail/subviews/assignment_completion_detail/subview/assignment_review/ui/assignment_review.dart';
import 'package:test1/main.dart';

class AssignmentCompletion extends StatefulWidget {
  final AssignmentModel assignmentModel;
  final CourseModel courseModel;
  const AssignmentCompletion(
      {super.key, required this.assignmentModel, required this.courseModel});

  @override
  State<AssignmentCompletion> createState() => _AssignmentCompletionState();
}

class _AssignmentCompletionState extends State<AssignmentCompletion> {
  @override
  Widget build(BuildContext context) {
    AssignmentCompletionBloc assignmentCompletionBloc =
        AssignmentCompletionBloc();
    return BlocListener<AssignmentCompletionBloc, AssignmentCompletionState>(
      listener: (context, state) {
        if (state is DeleteAssignmentSuccessState) {
          Navigator.pop(context);
        }
      },
      bloc: assignmentCompletionBloc,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.mainColor,
          foregroundColor: AppColors.secondaryColor,
          title: Text(
            widget.assignmentModel.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            TextButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              onPressed: () async {
                assignmentCompletionBloc.add(deleteAssignmentEvent(
                    assignmentId: widget.assignmentModel.id,
                    courseId: widget.courseModel.id));
              },
              label: Text('delete assignment'),
              icon: Icon(Icons.delete),
            ),
            SizedBox(width: 10),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildSubmittedGroup(
                  widget.assignmentModel.id, widget.assignmentModel),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildSubmittedGroup(
    String assignmentId, AssignmentModel assignmentModel) {
  return StreamBuilder<List<AssignmentUserModel>>(
    stream: AssignmentUserRepository().getAssignmentSubmissions(assignmentId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text("Error: ${snapshot.error}");
      } else if (snapshot.hasData) {
        final assignments = snapshot.data!;
          final submittedAssignments = assignments.where((assignment) => assignment.isSubmitted).toList();
        final notSubmittedAssignments = assignments.where((assignment) => !assignment.isSubmitted).toList();

        return Column(
          children: [
            Card.outlined(
              color: AppColors.mainColor,
              child: ListTile(
                textColor: AppColors.secondaryColor,
                iconColor: AppColors.secondaryColor,
                visualDensity: VisualDensity.comfortable,
                leading: Icon(Icons.person),
                title: Text('The total assignment:'),
                subtitle: Text(assignments.length.toString()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 350,
                decoration: BoxDecoration(
                  color: AppColors.mainColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          ListTile(
                            iconColor: AppColors.secondaryColor,
                            textColor: AppColors.secondaryColor,
                            title: Text('Graded vs Ungraded'),
                            subtitle: Text('Based on the score'),
                            leading: Icon(Icons.assignment),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.secondaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 250,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        color: Colors.yellow,
                                        value: assignments
                                            .where((element) =>
                                                element.isSubmitted &&
                                                element.score == 0)
                                            .length
                                            .toDouble(),
                                        title:
                                            'Ungraded: ${assignments.where((element) => element.isSubmitted && element.score == 0).length}',
                                        titleStyle:
                                            TextStyle(color: Colors.white),
                                        radius: 100,
                                      ),
                                      PieChartSectionData(
                                        color: Colors.green,
                                        value: assignments
                                            .where((element) =>
                                                element.isSubmitted &&
                                                element.score != 0)
                                            .length
                                            .toDouble(),
                                        title:
                                            'Graded: ${assignments.where((element) => element.isSubmitted && element.score != 0).length}',
                                        titleStyle:
                                            TextStyle(color: Colors.white),
                                        radius: 100,
                                      ),
                                      PieChartSectionData(
                                        color: Colors.red,
                                        value: assignments
                                            .where((element) =>
                                                !element.isSubmitted)
                                            .length
                                            .toDouble(),
                                        title:
                                            'Not Submitted: ${assignments.where((element) => !element.isSubmitted).length}',
                                        titleStyle:
                                            TextStyle(color: Colors.white),
                                        radius: 100,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          ListTile(
                            iconColor: AppColors.secondaryColor,
                            textColor: AppColors.secondaryColor,
                            title: Text('On Time vs Late'),
                            subtitle: Text('Based on the deadline'),
                            leading: Icon(Icons.date_range),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 250,
                              decoration: BoxDecoration(
                                color: AppColors.secondaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        color: Colors.green,
                                        value: assignments
                                            .where((element) =>
                                                element.isSubmitted &&
                                                element.submittedDate == null &&
                                                element.submittedDate!.isBefore(
                                                    assignmentModel.deadLine))
                                            .length
                                            .toDouble(),
                                        title:
                                            'On Time: ${assignments.where((element) => element.isSubmitted && element.submittedDate == null && element.submittedDate!.isBefore(assignmentModel.deadLine)).length}',
                                        titleStyle:
                                            TextStyle(color: Colors.white),
                                        radius: 100,
                                      ),
                                      PieChartSectionData(
                                        color: Colors.red,
                                        value: assignments
                                            .where((element) =>
                                                element.submittedDate == null ||
                                                element.submittedDate!.isAfter(
                                                    assignmentModel.deadLine))
                                            .length
                                            .toDouble(),
                                        title:
                                            'Late: ${assignments.where((element) => element.submittedDate == null || element.submittedDate!.isAfter(assignmentModel.deadLine)).length}',
                                        titleStyle:
                                            TextStyle(color: Colors.white),
                                        radius: 100,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

             Container(
              color: AppColors.mainColor,
              
              child: ListTile(
                textColor: AppColors.secondaryColor,
                title: Text('Submitted'),
              ),
            ),

            
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: submittedAssignments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AssignmentReview(
                        assignmentUserModel: submittedAssignments[index],
                      ),
                    ));
                  },
                  title: Container(
                    child: StreamBuilder<UserModel?>(
                      stream: UserRepository()
                          .getUserByIdStream((submittedAssignments[index].userId)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else if (snapshot.hasData) {
                          final user = snapshot.data!;
                          return Row(children: [
                            CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                user.avatarUrl!,
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.name),
                                Text(user.email),
                              ],
                            ),
                          ]);
                        } else {
                          return const Text('No user found');
                        }
                      },
                    ),
                  ),
                  enabled: submittedAssignments[index].isSubmitted,
                  trailing: submittedAssignments[index].isSubmitted
                      ? submittedAssignments[index].score == 0
                          ? Text(
                              'Not Graded',
                              style: TextStyle(color: Colors.amber),
                            )
                          : Text(
                              'Graded',
                              style: TextStyle(color: Colors.green),
                            )
                      : Text(
                          'Not Submitted',
                          style: TextStyle(color: Colors.red),
                        ),
                );
              },
            ),

            Container(
              color: AppColors.mainColor,
              
              child: ListTile(
                textColor: AppColors.secondaryColor,
                title: Text('Not Submitted'),
              ),
            ),


                ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: notSubmittedAssignments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AssignmentReview(
                        assignmentUserModel: notSubmittedAssignments[index],
                      ),
                    ));
                  },
                  title: Container(
                    child: StreamBuilder<UserModel?>(
                      stream: UserRepository()
                          .getUserByIdStream((notSubmittedAssignments[index].userId)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else if (snapshot.hasData) {
                          final user = snapshot.data!;
                          return Row(children: [
                            CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                user.avatarUrl!,
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.name),
                                Text(user.email),
                              ],
                            ),
                          ]);
                        } else {
                          return const Text('No user found');
                        }
                      },
                    ),
                  ),
                  enabled: notSubmittedAssignments[index].isSubmitted,
                  trailing: notSubmittedAssignments[index].isSubmitted
                      ? notSubmittedAssignments[index].score == 0
                          ? Text(
                              'Not Graded',
                              style: TextStyle(color: Colors.amber),
                            )
                          : Text(
                              'Graded',
                              style: TextStyle(color: Colors.green),
                            )
                      : Text(
                          'Not Submitted',
                          style: TextStyle(color: Colors.red),
                        ),
                );
              },
            ),

          ],
        );
      } else {
        return const Text('No submitted users found');
      }
    },
  );
}
