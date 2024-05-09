import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:test1/data/model/assignment_user_model.dart';
import 'package:test1/data/model/incentives_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/assignment_repository.dart';
import 'package:test1/data/repo/course_repository.dart';
import 'package:test1/data/repo/user_repository.dart';
import 'package:test1/features/new/course/subviews/course_detail/subviews/assignment_completion_detail/subview/assignment_review/bloc/assignment_review_bloc.dart';
import 'package:test1/global/common/build_badge.dart';
import 'package:test1/global/common/toast.dart';
import 'package:test1/main.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentReview extends StatefulWidget {
  final AssignmentUserModel assignmentUserModel;
  const AssignmentReview({super.key, required this.assignmentUserModel});

  @override
  State<AssignmentReview> createState() => _AssignmentReviewState();
}

class _AssignmentReviewState extends State<AssignmentReview> {
  late Future<List<Reference>> filesFuture;
  List<BadgeModel> badges = [];
    String review = '';
 int grade = 0;


  String? downloadUrl;

  @override
  void initState() {
    super.initState();
    

    filesFuture = listFiles(
        'assignments/${widget.assignmentUserModel.courseId}/${widget.assignmentUserModel.assignmentId}/${widget.assignmentUserModel.userId}');
  }

  void refreshFiles() {
    setState(() {
      filesFuture = listFiles(
          'assignments/${widget.assignmentUserModel.courseId}/${widget.assignmentUserModel.assignmentId}/${widget.assignmentUserModel.userId}');
    });
  }




  @override
  Widget build(BuildContext context) {
    AssignmentReviewBloc assignmentReviewBloc = AssignmentReviewBloc();

    return Scaffold(
      appBar: AppBar(
        title: Text('Assignment Review'),
      ),
      body: BlocConsumer<AssignmentReviewBloc, AssignmentReviewState>(
        bloc: assignmentReviewBloc,
        listenWhen: (previous, current) =>
            current is! AssignmentReviewActionState,
        buildWhen: (previous, current) =>
            current is! AssignmentReviewActionState,
        listener: (context, state) {

          print(state);
       
          if (state is SubmittedReview)
          {
            showToast(message: 'Review submitted successfully');
            Navigator.pop(context);
            Navigator.pop(context);
          }
        
        },
        builder: (context, state) {

          if (state is AssignmentReviewSuccess)
          return SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  children: [
                    userInfo(),
                    assignmentInfo(state, context, assignmentReviewBloc),
                    fileInfo(),
                    badgeInfo(context, state, assignmentReviewBloc),
                    reviewInfo(state, context, assignmentReviewBloc),
                    submitButton(state, assignmentReviewBloc)
                  ],
                ),
              ],
            ),
          );

          else return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Row submitButton(AssignmentReviewState state, AssignmentReviewBloc assignmentReviewBloc) {
    return Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.pink,
                          ),

                          onPressed: () async {
                            if (grade == 0 || review == '') {
                              showToast(
                                  message:
                                      'Please fill in the grade and review');
                              return;
                            } 

                            _showLoadingDialog(context);
                            assignmentReviewBloc.add(

                                FinishGrading(assignmentUserModel: widget.assignmentUserModel, review: review, grade: grade, badges: badges)
                            );
                              
                          },
                          icon: Icon(Icons.check_sharp),
                          label: Text('finish the grade and review'),
                        ),
                      ),
                    ],
                  );
  }

  Card reviewInfo(AssignmentReviewState state, BuildContext context, AssignmentReviewBloc assignmentReviewBloc) {
    return Card.filled(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text.rich(
                            TextSpan(
                              text: 'Review',
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                                TextSpan(
                                  text: ':',
                                  style: TextStyle(color: Colors.black),
                                )
                              ],
                            ),
                          ),
                          
                          subtitle: Text(
                              'Comments given by the teacher for this assignment.'),
                        ),
                        if (widget.assignmentUserModel.review != '')
                          Card.outlined(
                            child: ListTile(
                              title: Text('Review: '),
                              subtitle:
                                  Text(widget.assignmentUserModel.review!),
                            ),
                          )
                        else
                          Card.outlined(
                            child: review != ''
                                ? ListTile(
                                    title: Text('Review: '),
                                    subtitle: Text(review),
                                    trailing: IconButton(
                                      onPressed: () {
                                        showEditReviewDialog(
                                            context, assignmentReviewBloc, state, review, (String review) {
                                              setState(() {
                                                this.review = review;
                                              }
                                              );
                                            });
                                      },
                                      icon: Icon(Icons.edit),
                                    ),
                                  )
                                : ListTile(
                                    title: Text('Review: '),
                                    subtitle: Text('No review given'),
                                    trailing: IconButton(
                                      onPressed: () {
                                        showEditReviewDialog(
                                            context, assignmentReviewBloc, state, review, (String review) {
                                              setState(() {
                                                this.review = review;
                                              });
                                            }
                                        );
                                      },
                                      icon: Icon(Icons.add),
                                    ),
                                  ),
                          ),
                      ],
                    ),
                  );
  }

  Card badgeInfo(BuildContext context, AssignmentReviewState state, AssignmentReviewBloc assignmentReviewBloc) {
    return Card.filled(
                    child: _buildIncentiveItem(
                        context, state, assignmentReviewBloc),
                  );
  }

  Card fileInfo() {
    return Card.filled(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('Files:'),
                          subtitle: Text(
                              'Files submitted by the student for this assignment'),
                        ),
                        FutureBuilder<List<Reference>>(
                            future: filesFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Icon(Icons.error);
                              } else if (snapshot.hasData) {
                                final List<Reference> files = snapshot.data!;
                                return GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
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
                                        if (metadataSnapshot
                                                .connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (metadataSnapshot
                                            .hasError) {
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
                                                metadataSnapshot.data!,
                                                files[index]),
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

  Row assignmentInfo(AssignmentReviewState state, BuildContext context, AssignmentReviewBloc assignmentReviewBloc) {
    return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Card.filled(
                            child: ListTile(
                          title: Text('Submitted Date: '),
                          trailing: Text(DateFormat('yyyy-MM-dd HH:mm:ss')
                              .format(
                                  widget.assignmentUserModel.submittedDate ??
                                      DateTime.now())),
                        )),
                      ),
                      Expanded(
                          child: Card.filled(
                        child: ListTile(
                          
                          title: Text.rich(
                            TextSpan(
                              text: 'Grade',
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),

                                ),
                                TextSpan(
                                  text: ':',
                                  style: TextStyle(color: Colors.black),
                                )
                                
                              ],
                            ),
                          
                          ),
                          trailing: widget.assignmentUserModel.score != 0
                              ? Text(
                                  widget.assignmentUserModel.score.toString())
                              : grade != 0
                                  ? TextButton.icon(
                                      onPressed: () {
                                          showEditGradeDialog(
                                            context, assignmentReviewBloc, (int grade) {
                                              setState(() {
                                                this.grade = grade;
                                              });
                                            });

                                      }
                                      ,
                                      icon: Icon(Icons.edit),
                                      label: Text(grade.toString()))
                                  : IconButton(
                                      onPressed: () {
                                        showEditGradeDialog(
                                            context, assignmentReviewBloc, (int grade) {
                                              setState(() {
                                                this.grade = grade;
                                              });
                                            }
                                        );
                                      },
                                      icon: Icon(Icons.add)),
                        ),
                      ))
                    ],
                  );
  }

  StreamBuilder<UserModel?> userInfo() {
    return StreamBuilder<UserModel?>(
                    stream: UserRepository()
                        .getUserByIdStream(widget.assignmentUserModel.userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Icon(Icons.error);
                      } else if (snapshot.hasData) {
                        return Card.filled(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  snapshot.data!.avatarUrl!),
                            ),
                            title: Text(snapshot.data!.name),
                            subtitle: Text(snapshot.data!.email),
                          ),
                        );
                      } else {
                        return Text('No user found');
                      }
                    },
                  );
  }

  Widget _buildIncentiveItem(BuildContext context, AssignmentReviewState state,
      AssignmentReviewBloc assignmentReviewBloc) {
    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          title: Text('Badges:'),
          subtitle: Text(
              'Give badges to this student if they have done well in the assignment!'),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.yellow[200]!.withOpacity(0.5),
                Colors.orange[400]!.withOpacity(0.5),
              ],
            ),
          ),
          child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              shrinkWrap: true,
              children: [
                GestureDetector(
                  onTap: () {
                    showEditBadgeDialog(context, assignmentReviewBloc);
                  },
                  child: GridTile(
                    child: Stack(alignment: Alignment.center, children: [
                      SvgPicture.asset(
                        'assets/app_images/badge.svg',
                        colorFilter: ColorFilter.mode(
                            Colors.grey.withOpacity(0.5), BlendMode.srcATop),
                      ),
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 50,
                      )
                    ]),
                  ),
                ),

                ...badges
                    .map((badge) => buildBadge(badge.badgeName))
                    .toList(),
              ]),
        ),
      ],
    );
  }

  Widget _buildFileItem(FullMetadata metadata, Reference ref) {
    // 假设我们根据MIME类型判断文件是否为图片或视频
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
                    child: Text(ref.name, overflow: TextOverflow.ellipsis),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.download),
                    onPressed: () async {
                      final url = await ref.getDownloadURL();
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                ],
              ),
              child: CachedNetworkImage(
                 progressIndicatorBuilder:(context, url, progress) {
                      return CircularProgressIndicator(value: progress.progress, color: AppColors.mainColor, backgroundColor: AppColors.secondaryColor,);
                      
                    },
                imageUrl: snapshot.data,
                fit: BoxFit.cover,
             
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              footer: Text(
                  'Size: ${formatBytes(metadata.size!)} \nUploaded: ${metadata.timeCreated}'),
            );
          }
        },
      );
    } else {
      // 对于其他类型的文件，我们显示上传日期和大小
      return GridTile(
        child: Icon(Icons.insert_drive_file),
        header: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(ref.name, overflow: TextOverflow.ellipsis),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.download),
              onPressed: () async {
                final url = await ref.getDownloadURL(); // 获取文件的下载URL
                final uri = Uri.parse(url); // 将字符串URL转换为Uri对象
                if (await canLaunchUrl(uri)) {
                  // 使用canLaunchUrl检查Uri
                  await launchUrl(uri); // 使用launchUrl启动Uri
                } else {
                  throw 'Could not launch $url';
                }
                // refreshFiles();
              },
            ),
          ],
        ),
        footer: Text(
            'Size: ${formatBytes(metadata.size!)} \nUploaded: ${metadata.timeCreated}'),
      );
    }

    // Widget build and other methods...
  }

  String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return "0 Bytes";
    const suffixes = ["Bytes", "KB", "MB", "GB", "TB"];
    int i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  Future<List<Reference>> listFiles(String path) async {
    final storageRef = FirebaseStorage.instance.ref(path);
    final result = await storageRef.listAll();

    return result.items;
  }

  Future<void> showEditBadgeDialog(
      BuildContext context, AssignmentReviewBloc assignmentReviewBloc) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => AlertDialog(
        title: Text('Edit Badge'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              GridTile(
                child: Row(
                  children: [
                    SvgPicture.asset('assets/app_images/badge.svg', width: 250),
                    SizedBox(width: 10),
                    Card(
                      elevation: 2.0,
                      child: Container(
                        height: 250,
                        width: 250,
                        padding: const EdgeInsets.all(8.0),
                        child: GridTile(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card.filled(
                                child: Container(
                                    width: double.maxFinite,
                                    child: Text('How to create a badge?')),
                              ),
                              SizedBox(height: 10),
                              Text('1. Give a name to the badge'),
                              Text('2. Describe the badge'),
                              Text('3. Save the badge'),
                              Text('4. Assign the badge to students'),
                            ],
                          ),
                          footer: Text(
                              '* Please keep the badge name within 10 characters'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: StreamBuilder(
                        stream: CourseRepository()
                            .courseStream(widget.assignmentUserModel.courseId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else if (snapshot.hasData) {
                            final course = snapshot.data!;
                            return Card.filled(
                              child: ListTile(
                                title: Text('Course: '),
                                subtitle: Text(course.name),
                              ),
                            );
                          } else {
                            return const Text('No course found');
                          }
                        }),
                  ),
                  Expanded(
                      child: StreamBuilder(
                          stream: AssignmentRepository()
                              .getAssignmentByIdStream(
                                  widget.assignmentUserModel.courseId,
                                  widget.assignmentUserModel.assignmentId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            } else if (snapshot.hasData) {
                              final assignment = snapshot.data!;
                              return Card.filled(
                                child: ListTile(
                                  title: Text('Assignment: '),
                                  subtitle: Text(assignment.name),
                                ),
                              );
                            } else {
                              return const Text('No assignment found');
                            }
                          }))
                ],
              ),
              TextField(
                maxLength: 10,
                controller: nameController,
                decoration: InputDecoration(labelText: "Badge Name"),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Badge Description"),
              ),
            ],
          ),
        ),
        actions:[
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              if (nameController.text.isEmpty ||
                  descriptionController.text.isEmpty) {
                showToast(message: 'Please fill in all fields');
                return;
              }

              final badge = BadgeModel(
                  badgeId: '',
                  userId: widget.assignmentUserModel.userId,
                  courseId: widget.assignmentUserModel.courseId,
                  assignmentId: widget.assignmentUserModel.assignmentId,
                  dateEarned: DateTime.now(),
                  badgeName: nameController.text,
                  badgeDescription: descriptionController.text);

              setState(() {
                badges.add(badge);
              });
   
              Navigator.of(context).pop(); 
            },
          ),
        ],
      ),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    );
  }

  

  void showEditGradeDialog(
      BuildContext context, AssignmentReviewBloc assignmentReviewBloc,  Function(int grade) onGradeChanged){
    TextEditingController gradeController = TextEditingController();
  

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Grade'),
          content: TextField(
            controller: gradeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Enter grade (1-100)"),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                final int? grade = int.tryParse(gradeController.text);
                if (grade != null && grade >= 1 && grade <= 100) {
                 
                  onGradeChanged(grade);
                  Navigator.of(context).pop();
                } else {
                  showToast(
                      message: 'Please enter a valid grade between 1 and 100');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void showEditReviewDialog(
      BuildContext context, AssignmentReviewBloc assignmentReviewBloc, AssignmentReviewState state, String review,
      Function(String review) onReviewChanged
      ) {
    TextEditingController reviewController = TextEditingController();
    reviewController.text =  review;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Review'),
          content: Container(
            width: double.maxFinite,
            height: 100,
            child: TextField(
              
              controller: reviewController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(hintText: "Enter your review"),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                final String review = reviewController.text;
                if (review.isNotEmpty) {
                  onReviewChanged(review);
               
                } else {
                  showToast(message: 'Please enter a review');
                  return;
                }
              
                Navigator.of(context).pop();
             
            
              },
            ),
          ],
        );
      },
    );
  }
}


void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.mainColor),
              ),
              SizedBox(height: 20),
              Text("Saving...", style: TextStyle(color: AppColors.mainColor)),
            ],
          ),
        );
      },
    );
  }