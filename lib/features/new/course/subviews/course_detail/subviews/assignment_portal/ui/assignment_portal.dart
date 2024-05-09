

import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/data/model/assignment_user_model.dart';
import 'package:test1/features/new/course/subviews/course_detail/subviews/assignment_portal/bloc/assignment_portal_bloc.dart';
import 'package:test1/global/common/toast.dart';
import 'package:test1/main.dart';

class AssignmentPortal extends StatefulWidget {
  final AssignmentUserModel assignmentUserModel;
  const AssignmentPortal({super.key, required this.assignmentUserModel});

  @override
  State<AssignmentPortal> createState() => _AssignmentPortalState();
}

class _AssignmentPortalState extends State<AssignmentPortal> {
  late Future<List<Reference>> filesFuture;

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
    AssignmentPortalBloc assignmentPortalBloc = AssignmentPortalBloc();

    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Assignment'),
        backgroundColor: AppColors.mainColor,
        foregroundColor: AppColors.secondaryColor,
    
      ),
      body: BlocConsumer<AssignmentPortalBloc, AssignmentPortalState>(
        bloc: assignmentPortalBloc,
        listener: (context, state) {
          if (state is AssignmentPortalFileUploadedState) {
            showToast(message: 'File Uploaded Successfully');
            refreshFiles();
          } else if (state is AssignmentPortalError) {
            showToast(message: state.error);
          }
          print(state.runtimeType);
        },
        builder: (context, state) {
          if (state is AssignmentPortalFileUploading) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Uploading Files...'),
                  LinearProgressIndicator(
                    value: state.progress,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: double.maxFinite,
                  child: Card.outlined(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('Upload Assignment Files',

                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(
                              'You can upload multiple files at once. The maximum file size is 10MB.'),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.maxFinite,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Card.filled(
                          child: TextButton(
                            onPressed: () async {
                              final result = await FilePicker.platform
                                  .pickFiles(
                                      allowMultiple: true, type: FileType.any);

                              if (result != null) {
                                List<File> files = result.paths
                                    .map((path) => File(path!))
                                    .toList();
                                assignmentPortalBloc
                                    .add(AssignmentPortalFilePicked(files));
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file),
                                Text('Upload File'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card.filled(
                          child: TextButton(
                            onPressed: () async {
                              final result = await FilePicker.platform
                                  .pickFiles(
                                      allowMultiple: true,
                                      type: FileType.image);

                              if (result != null) {
                                List<File> files = result.paths
                                    .map((path) => File(path!))
                                    .toList();
                                assignmentPortalBloc
                                    .add(AssignmentPortalFilePicked(files));
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image),
                                Text('Upload Image'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state is AssignmentPortalFilePickedState) ...[
                  ListView(
                    padding: EdgeInsets.all(8),
                    shrinkWrap: true,
                    children: state.files
                        .map((file) => Container(
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)),
                              child: ListTile(
                                visualDensity: VisualDensity.compact,
                                title: Text(file.path
                                    .substring(file.path.lastIndexOf('/') + 1)),
                                subtitle: Text(
                                    'Size: ${formatBytes(file.lengthSync())}'),
                              ),
                            ))
                        .toList(),
                  ),
                  Container(
                    width: double.maxFinite,
                    child: Card.filled(
                      child: TextButton(
                        onPressed: () async {
                          assignmentPortalBloc.add(AssignmentPortalFileUploaded(
                              state.files, widget.assignmentUserModel));
                        },
                        child: Text('Upload File'),
                      ),
                    ),
                  ),
                ],
                if (state is AssignmentPortalInitial) ...[
                  Container(
                    width: double.maxFinite,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: Colors.white70,
                    ),
                    child: Center(
                      child: Text('No files selected'),
                    ),
                  )
                ],
                SizedBox(
                  height: 20,
                ),
                Text('The files you have uploaded:',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
                          crossAxisCount: 4,
                          crossAxisSpacing: 4.0,
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
                  },
                ),

                 TextButton.icon(
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondaryColor,
                  backgroundColor: AppColors.accentColor),
              onPressed: () {
                assignmentPortalBloc.add(AssignmentPortalSubmit(assignmentUserModel: widget.assignmentUserModel));
                showToast(message: 'Assignment Submitted');
                Navigator.pop(context);
              },
              icon: Icon(Icons.upload_file),
              label: Text('submit assignment')),
              ],
            ),
          );
        },
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
                    child: Text(ref.name, overflow: TextOverflow.ellipsis),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await ref.delete();
                      refreshFiles();
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
              icon: Icon(Icons.delete),
              onPressed: () async {
                await ref.delete();
                refreshFiles();
              },
            ),
          ],
        ),
        footer: Text(
            'Size: ${formatBytes(metadata.size!)} \nUploaded: ${metadata.timeCreated}'),
      );
    }
  }
}

String formatBytes(int bytes, {int decimals = 2}) {
  if (bytes <= 0) return "0 Bytes";
  const suffixes = ["Bytes", "KB", "MB", "GB", "TB"];
  int i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
}

Future<List<Reference>> listFiles(String path) async {
  final storageRef = FirebaseStorage.instance.ref(path);
  final result = await storageRef.listAll();

  return result.items;
}
