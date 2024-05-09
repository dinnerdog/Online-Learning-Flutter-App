import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:test1/data/model/course_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/course_repository.dart';
import 'package:test1/data/repo/course_user_repository.dart';
import 'package:test1/global/common/toast.dart';
import 'package:test1/main.dart';
import 'package:url_launcher/url_launcher.dart';

class AssginmentResources extends StatefulWidget {
  final CourseModel courseModel;
  final UserModel userModel;

  const AssginmentResources(
      {super.key, required this.courseModel, required this.userModel});

  @override
  State<AssginmentResources> createState() => _AssginmentResourcesState();
}

class _AssginmentResourcesState extends State<AssginmentResources> {
  late Future<List<Reference>> filesFuture;
  List<FileAndDescription> fileAndDescriptions = [];
  List<String> resourceUrls = [];

  bool _isPickingFile = false;
  bool _isUploadingFile = false;

  @override
  void initState() {
    super.initState();

    filesFuture =
        resourcesListFiles('course_resources/${widget.courseModel.id}');
  }

  void refreshFiles() {
    setState(() {
      filesFuture =
          resourcesListFiles('course_resources/${widget.courseModel.id}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        title: Text('Assignment Resources'),
        foregroundColor: AppColors.secondaryColor,
        backgroundColor: AppColors.mainColor,
        actions: [
          if (widget.userModel.role == Role.teacher ||
              widget.userModel.role == Role.admin)
            TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondaryColor,
                  backgroundColor: AppColors.accentColor,
                ),
                onPressed: () async {
                  if (_isPickingFile) return;

                  try {
                    final result = await FilePicker.platform
                        .pickFiles(allowMultiple: true, type: FileType.media);

                    if (result != null) {
                      for (var file in result.files) {
                        var newFile = FileAndDescription(File(file.path!), '');
                        setState(() {
                          fileAndDescriptions.add(newFile);
                        });
                      }
                    }
                  } catch (e) {
                    print(e);
                  } finally {
                    setState(() {
                      _isPickingFile = false;
                    });
                  }
                },
                icon: Icon(Icons.upload_file),
                label: Text('Upload Media')),
          SizedBox(
            width: 10,
          ),
          if (widget.userModel.role == Role.teacher ||
              widget.userModel.role == Role.admin)
            TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondaryColor,
                  backgroundColor: AppColors.accentColor,
                ),
                onPressed: () async {
                  if (_isPickingFile) return;

                  try {
                    final result = await FilePicker.platform
                        .pickFiles(allowMultiple: true, type: FileType.any);

                    if (result != null) {
                      for (var file in result.files) {
                        var newFile = FileAndDescription(File(file.path!), '');
                        setState(() {
                          fileAndDescriptions.add(newFile);
                        });
                      }
                    }
                  } catch (e) {
                    print(e);
                  } finally {
                    setState(() {
                      _isPickingFile = false;
                    });
                  }
                },
                icon: Icon(Icons.upload_file),
                label: Text('Upload Files')),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: Container(
        color: AppColors.secondaryColor,
        child: SingleChildScrollView(
          child: Column(
            children: [uploadBar(), fileHeader(), fileContent()],
          ),
        ),
      ),
    );
  }

  Widget _buildFileItem(
      FullMetadata metadata, Reference ref, CourseModel course) {
    bool isImage = metadata.contentType?.startsWith('image/') ?? false;
    bool isVideo = metadata.contentType?.startsWith('video/') ?? false;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: FutureBuilder<dynamic>(
          future: ref.getDownloadURL(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return skeletonizerItem(context);
            } else if (snapshot.hasError) {
              return Icon(Icons.error);
            } else {
              if (isImage || isVideo)
                return GestureDetector(
                    onTap: () async {
                      // isFirstClick(snapshot.data, course.id, widget.userModel.id);
                      final url = snapshot.data;
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {


                        await launchUrl(uri);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            imageField(context, isImage, snapshot, ref),
                            imageInfo(context, ref, metadata),
                          ],
                        ),
                      ],
                    ));

              return fileField(snapshot, context, ref, metadata, course);
            }
          },
        ),
      ),
    );
  }

  Padding fileField(AsyncSnapshot<dynamic> snapshot, BuildContext context,
      Reference ref, FullMetadata metadata, CourseModel course) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.mainColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: GestureDetector(
              onTap: () async {
                  // isFirstClick(snapshot.data, course.id, widget.userModel.id);
                final url = snapshot.data;
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Stack(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: MediaQuery.of(context).size.width * 0.2,
                              child: Icon(
                                Icons.download,
                                color: AppColors.secondaryColor,
                                size: 50,
                              ),
                            ),
                            if (widget.userModel.role == Role.teacher ||
                                widget.userModel.role == Role.admin)
                              IconButton(
                                  icon: Icon(Icons.cancel),
                                  onPressed: () async {
                                    _showLoadingDialog(context);
                                    try {
                                      await ref.delete();
                                      await CourseRepository().deleteStars(
                                          course.id, snapshot.data);

                                      await CourseRepository()
                                          .deleteCourseResource(
                                              course.id, snapshot.data);
                                      refreshFiles();
                                    } catch (e) {
                                      print(e);
                                    }
                                    Navigator.of(context).pop();
                                  })
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: MediaQuery.of(context).size.width * 0.2,
                          decoration: BoxDecoration(
                            color: AppColors.mainColor,
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(10),
                                topRight: Radius.circular(10)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8, left: 8),
                                child: Text(
                                  ref.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: AppColors.secondaryColor),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  'Size: ${formatBytes(metadata.size!)}  Uploaded: ${metadata.timeCreated}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: AppColors.secondaryColor),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        color: AppColors.secondaryColor),
                                    child: ListView(
                                      children: [
                                        ListTile(
                                          dense: true,
                                          leading: Icon(
                                            Icons.description,
                                            color: AppColors.mainColor,
                                          ),
                                          title: Text(
                                            'Description',
                                            style: TextStyle(
                                                color: AppColors.mainColor),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            metadata.customMetadata![
                                                        'description'] ==
                                                    ''
                                                ? 'This file has no description.'
                                                : metadata.customMetadata![
                                                    'description']!,
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(
                                                color: AppColors.mainColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )),
        ));
  }

  Expanded imageInfo(
      BuildContext context, Reference ref, FullMetadata metadata) {
    return Expanded(
      flex: 3,
      child: Container(
        height: MediaQuery.of(context).size.width * 0.2,
        decoration: BoxDecoration(
          color: AppColors.mainColor,
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: Text(
                ref.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(color: AppColors.secondaryColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'Size: ${formatBytes(metadata.size!)}  Uploaded: ${metadata.timeCreated}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(color: AppColors.secondaryColor),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: AppColors.secondaryColor),
                  child: ListView(
                    children: [
                      ListTile(
                        dense: true,
                        leading:
                            Icon(Icons.description, color: AppColors.mainColor),
                        title: Text(
                          'Description',
                          style: TextStyle(color: AppColors.mainColor),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          metadata.customMetadata!['description'] == ''
                              ? 'This file has no description.'
                              : metadata.customMetadata!['description']!,
                          overflow: TextOverflow.visible,
                          style: TextStyle(color: AppColors.mainColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Expanded imageField(BuildContext context, bool isImage,
      AsyncSnapshot<dynamic> snapshot, Reference ref) {
    return Expanded(
      flex: 1,
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.width * 0.2,
            child: isImage
                ? CachedNetworkImage(
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            topLeft: Radius.circular(10)),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    imageUrl: snapshot.data,
                    fit: BoxFit.cover,
                  )
                : Icon(Icons.video_collection),
          ),
          if (widget.userModel.role == Role.teacher ||
              widget.userModel.role == Role.admin)
            IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () async {
                  _showLoadingDialog(context);
                  try {
                    await ref.delete();
                    await CourseRepository()
                        .deleteStars(widget.courseModel.id, snapshot.data);

                    await CourseRepository().deleteCourseResource(
                        widget.courseModel.id, snapshot.data);
                    refreshFiles();
                  } catch (e) {
                    print(e);
                  }

                  Navigator.of(context).pop();
                })
        ],
      ),
    );
  }

  Widget fileContent() {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Center(
          child: FutureBuilder<List<Reference>>(
            future: filesFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Center(
                  child: Container(
                    width: 200,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.mainColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'No files found',
                        style: TextStyle(color: AppColors.secondaryColor),
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return skeletonizerItem(context);
              } else if (snapshot.hasError) {
                return Icon(Icons.error);
              } else if (snapshot.hasData) {
                final List<Reference> files = snapshot.data!;
                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<FullMetadata>(
                      future: files[index].getMetadata(),
                      builder: (context, metadataSnapshot) {
                        if (metadataSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return skeletonizerItem(context);
                        } else if (metadataSnapshot.hasError) {
                          return Icon(Icons.error);
                        } else {
                          return _buildFileItem(metadataSnapshot.data!,
                              files[index], widget.courseModel);
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
        ),
      ],
    );
  }

  AnimatedContainer uploadBar() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: fileAndDescriptions.isNotEmpty ? 260 : 0,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  textColor: AppColors.secondaryColor,
                  iconColor: AppColors.secondaryColor,
                  title: Text('Selected Files (${fileAndDescriptions.length})'),
                  subtitle: Text('Click on a file to remove it'),
                  leading: Icon(Icons.file_copy),
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: fileAndDescriptions.length,
                itemBuilder: (context, index) {
                  final fileAndDescription = fileAndDescriptions[index];
                  return Container(
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.mainColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  child: Text(
                                    fileAndDescription.file.path
                                        .split('/')
                                        .last,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: AppColors.secondaryColor),
                                  ),
                                ),
                                _isUploadingFile
                                    ? SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.1,
                                        child: LinearProgressIndicator(
                                          minHeight: 10,
                                          value: fileAndDescription.progress,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.accentColor),
                                          backgroundColor:
                                              AppColors.secondaryColor,
                                        ),
                                      )
                                    : TextButton.icon(
                                        style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          backgroundColor: fileAndDescription
                                                  .description.isEmpty
                                              ? AppColors.accentColor
                                              : AppColors.secondaryColor,
                                          foregroundColor: fileAndDescription
                                                  .description.isEmpty
                                              ? AppColors.secondaryColor
                                              : AppColors.accentColor,
                                        ),
                                        onPressed: () async {
                                          var description =
                                              await _showEditDescriptionDialog(
                                                  context, fileAndDescription);

                                          if (description != null) {
                                            setState(() {
                                              fileAndDescriptions[index] =
                                                  FileAndDescription(
                                                      fileAndDescription.file,
                                                      description);
                                            });
                                          }
                                        },
                                        icon: fileAndDescription
                                                .description.isEmpty
                                            ? Icon(Icons.add)
                                            : Icon(Icons.edit),
                                        label: fileAndDescription
                                                .description.isEmpty
                                            ? Text('Add Description')
                                            : Text('Edit Description'))
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          color: AppColors.secondaryColor,
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              fileAndDescriptions.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ButtonBar(
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.accentColor,
                    foregroundColor: AppColors.secondaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      fileAndDescriptions.clear();
                    });
                  },
                  icon: Icon(Icons.delete),
                  label: Text('Clear All'),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.accentColor,
                    foregroundColor: AppColors.secondaryColor,
                  ),
                  onPressed: () async {
                    showToast(
                        message:
                            'Uploading Files, please do not close the app');
                    setState(() {
                      _isUploadingFile = true;
                    });

                    for (var fileAndDescription in fileAndDescriptions) {
                      await uploadFile(
                        fileAndDescription.file,
                        'course_resources/${widget.courseModel.id}/${fileAndDescription.file.path.split('/').last}',
                        widget.userModel,
                        fileAndDescription.description,
                        (progress) {
                          setState(() {
                            fileAndDescription.progress = progress;
                          });
                        },
                        (url) async {
                          setState(() {
                            resourceUrls.add(url);
                          });
                          if (resourceUrls.length ==
                              fileAndDescriptions.length) {
                            try {
                              _showLoadingDialog(context);

                              for (var url in resourceUrls) {
                                await CourseRepository().configureStars(
                                    widget.courseModel.id,
                                    StarRating(name: url, rating: 3));


                              await CourseUserRepository().distributeStars( 
                                widget.courseModel.id,
                                    StarRating(name: url, rating: 0));
                              }

                              await CourseRepository().appendCourseResources(
                                  widget.courseModel.id, resourceUrls);
                              setState(() {
                                resourceUrls.clear();
                                fileAndDescriptions.clear();
                              });

                              refreshFiles();
                              showToast(message: 'Files uploaded successfully');
                            } catch (e) {
                              print(e);
                            }
                            finally {
                              Navigator.of(context).pop();
                            }
                          }
                        },
                      );
                    }

                    setState(() {
                      _isUploadingFile = false;
                    });
                  },
                  icon: Icon(Icons.upload_file),
                  label: Text('Upload'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class fileHeader extends StatelessWidget {
  const fileHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.accentColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          textColor: AppColors.secondaryColor,
          iconColor: AppColors.secondaryColor,
          title: Text('Resources'),
          subtitle: Text('Click on a file to download it'),
          leading: Icon(Icons.file_copy),
        ),
      ),
    );
  }
}

Future<List<Reference>> resourcesListFiles(String path) async {
  final storageRef = FirebaseStorage.instance.ref(path);
  final result = await storageRef.listAll();

  return result.items;
}

Future<void> uploadFile(
    File file,
    String destinationPath,
    UserModel user,
    String description,
    Function(double) onProgress,
    Function(String) onCompleted) async {
  try {
    UploadTask task = FirebaseStorage.instance.ref(destinationPath).putFile(
          file,
          SettableMetadata(
            customMetadata: {
              'uploaded_by': user.name,
              'uploaded_at': DateTime.now().toIso8601String(),
              'description': description,
            },
          ),
        );

    task.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress =
          snapshot.bytesTransferred.toDouble() / snapshot.totalBytes.toDouble();
      if (progress.isNaN || progress.isInfinite) {
        progress = 0.0;
      }

      onProgress(progress);
    });

    await task.whenComplete(() {
      task.snapshot.ref.getDownloadURL().then((value) {
        onCompleted(value);
      });
    });
  } on FirebaseException catch (e) {
    print(e);
  }
}

class FileAndDescription {
  final File file;
  final String description;
  double progress = 0.0;

  FileAndDescription(this.file, this.description);
}

Future<String?> _showEditDescriptionDialog(
    BuildContext context, FileAndDescription fileAndDescription) async {
  final TextEditingController controller =
      TextEditingController(text: fileAndDescription.description);

  final String? result = await showDialog<String?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.mainColor,
        iconColor: AppColors.mainColor,
        titleTextStyle: TextStyle(color: AppColors.secondaryColor),
        contentTextStyle: TextStyle(color: AppColors.mainColor),
        title: Text('Edit Description'),
        content: TextField(
          controller: controller,
          maxLines: 20,
          maxLength: 2000,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondaryColor)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondaryColor)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondaryColor)),
            counterStyle: TextStyle(color: AppColors.secondaryColor),
            labelStyle: TextStyle(color: AppColors.secondaryColor),
            hintText: 'Enter a description',
          ),
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.accentColor,
              foregroundColor: AppColors.secondaryColor,
            ),
            icon: Icon(Icons.cancel),
            onPressed: () => Navigator.of(context).pop(),
            label: Text('Cancel'),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.accentColor,
              foregroundColor: AppColors.secondaryColor,
            ),
            icon: Icon(Icons.save),
            onPressed: () => Navigator.of(context).pop(controller.text),
            label: Text('Save'),
          ),
        ],
      );
    },
  );

  return result;
}

String formatBytes(int bytes, {int decimals = 2}) {
  if (bytes <= 0) return "0 Bytes";
  const suffixes = ["Bytes", "KB", "MB", "GB", "TB"];
  int i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
}

Widget skeletonizerItem(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Skeletonizer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.width * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: MediaQuery.of(context).size.width * 0.2,
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(BoneMock.fullName),
                        const SizedBox(height: 8),
                        Text(BoneMock.longParagraph),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
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
            Text("Loading...", style: TextStyle(color: AppColors.mainColor)),
          ],
        ),
      );
    },
  );
}



// Future<bool> isFirstClick(String resourceUrl, String  courseId, String userId ) async {

//   final prefs = await SharedPreferences.getInstance();


//   bool isFirstClick = prefs.getBool('$resourceUrl$courseId$userId') ?? true;

//   if (isFirstClick) {
//     print('First click');

   
//     await CourseUserRepository().updateStar( courseId, userId, StarRating(name: resourceUrl, rating: 0));
//     await prefs.setBool('$resourceUrl$courseId$userId', false);
//   }

//   return isFirstClick;
// }