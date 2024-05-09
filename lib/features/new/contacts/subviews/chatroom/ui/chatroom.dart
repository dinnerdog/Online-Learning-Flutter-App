import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:test1/data/model/chat_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/user_repository.dart';
import 'package:test1/features/new/contacts/bloc/contacts_bloc.dart';
import 'package:test1/features/new/contacts/subviews/chatroom/bloc/chatroom_bloc.dart';
import 'package:test1/features/new/contacts/subviews/chatroom/ui/message_tile.dart';
import 'package:test1/global/common/toast.dart';
import 'package:test1/main.dart';

class Chatroom extends StatefulWidget {
  final String anotherUserId;
  final String currentUserId;
  final ContactsBloc? contactsBloc;

  const Chatroom(
      {super.key, required this.anotherUserId, required this.currentUserId,  this.contactsBloc});

  @override
  _ChatroomState createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  ChatroomBloc chatroomBloc = ChatroomBloc();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String chatroomId;

  @override
  void initState() {
    super.initState();
    chatroomBloc.add(ChatroomSubscriptionRequested(
        anotherUserId: widget.anotherUserId,
        currentUserId: widget.currentUserId));
    chatroomId = (widget.currentUserId.compareTo(widget.anotherUserId) < 0)
        ? "${widget.currentUserId}${widget.anotherUserId}"
        : "${widget.anotherUserId}${widget.currentUserId}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {

            widget.contactsBloc?.add(ContactsInitialEvent());
            print('back');
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.secondaryColor,
        backgroundColor: AppColors.mainColor,
        title: null,
      ),
      body: StreamBuilder<List<UserModel?>>(
          stream: UserRepository().getUsersByIdsStream(
              [widget.anotherUserId, widget.currentUserId]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return defaultPage();
            }

            return BlocConsumer<ChatroomBloc, ChatroomState>(
              bloc: chatroomBloc,
              listenWhen: (previous, current) => current is ChatroomActionState,
              buildWhen: (previous, current) => current is! ChatroomActionState,
              listener: (context, state) {
                if (state is ChatroomClickUploadImageActionState) {
                  _showUploadingDialog(context, state.imageUrls, chatroomId,
                      widget.currentUserId, chatroomBloc);
                }
              },
              builder: (context, state) {
                chatroomBloc.add(ChatroomUpdatedLastReadEvent(
                    anotherUserId: widget.anotherUserId,
                    currentUserId: widget.currentUserId));

                switch (state.runtimeType) {
                  case ChatroomSuccessState:
                    final messages = (state as ChatroomSuccessState).messages;
                    final anotherUser = snapshot.data!.firstWhere(
                            (element) => element!.id == widget.anotherUserId)
                        as UserModel;

                    final currentUser = snapshot.data!.firstWhere(
                            (element) => element!.id == widget.currentUserId)
                        as UserModel;

                    return Column(
                      children: [
                        InfomationSilder(anotherUser: anotherUser),
                        if (state is ChatroomClickUploadImageActionState)
                          Expanded(
                            child: Text('Messages'),
                          ),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: messages.length,
                            reverse: true,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return MessageTile(
                                message: messages[index],
                                anotherUser: anotherUser,
                                currentUser: currentUser,
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  style: TextStyle(color: AppColors.mainColor),
                                  controller: _controller,
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.mainColor,
                                          width: 2.0),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    suffixIconColor: AppColors.mainColor,
                                    focusColor: AppColors.mainColor,
                                    hoverColor: AppColors.mainColor,
                                    iconColor: AppColors.mainColor,
                                    hintText: 'Enter a message',
                                    hintStyle:
                                        TextStyle(color: AppColors.accentColor),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.0),
                              IconButton(
                                color: AppColors.mainColor,
                                icon: Icon(Icons.image),
                                onPressed: () async {
                                  final result = await FilePicker.platform
                                      .pickFiles(
                                          allowMultiple: true,
                                          type: FileType.image);

                                  if (result != null) {
                                    List<File> files = result.paths
                                        .map((path) => File(path!))
                                        .toList();

                                    var sum = 0;

                                    for (File file in files) {
                                      final fileSize = await file.length();

                                      sum += fileSize;
                                    }

                                    if (sum > 10000000) {
                                      showToast(
                                          message:
                                              'File size is too large， please select a file less than 10MB');
                                      return;
                                    }

                                    chatroomBloc.add(ChatroomClickAddImageEvent(
                                        imageUrls: files
                                            .map((file) => file.path)
                                            .toList()));
                                  }
                                },
                              ),
                              IconButton(
                                color: AppColors.mainColor,
                                icon: Icon(Icons.send),
                                onPressed: () {
                                  if (_controller.text.isNotEmpty) {
                                    setState(() {
                                      chatroomBloc.add(ChatroomClickSendEvent(
                                          chatroomId,
                                          MessageModel(
                                              chatroomId: chatroomId,
                                              text: _controller.text,
                                              senderId: widget.currentUserId,
                                              time: DateTime.now(),
                                              readBy: [widget.currentUserId],
                                              imageUrls: [])));
                                      _controller.clear();

                                      Future.delayed(
                                          Duration(milliseconds: 100), () {
                                        if (_scrollController.hasClients) {
                                          _scrollController.animateTo(
                                            _scrollController
                                                .position.minScrollExtent,
                                            duration:
                                                Duration(milliseconds: 300),
                                            curve: Curves.easeOut,
                                          );
                                        }
                                      });
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                  default:
                    return defaultPage();
                }
              },
            );
          }),
    );
  }
}

class InfomationSilder extends StatefulWidget {
  const InfomationSilder({
    super.key,
    required this.anotherUser,
  });

  final UserModel anotherUser;

  @override
  State<InfomationSilder> createState() => _InfomationSilderState();
}

class _InfomationSilderState extends State<InfomationSilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _AnimationController;
  bool isOpen = true;

  @override
  void initState() {
    super.initState();
    _AnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _AnimationController.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() {
      if (isOpen) {
        _AnimationController.reverse();
      } else {
        _AnimationController.forward();
      }
      isOpen = !isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: EdgeInsets.all(20),
      width: double.maxFinite,
      height: isOpen ? 300 : 70,
      color: AppColors.mainColor,
      duration: Duration(milliseconds: 300),
      child: SingleChildScrollView(
        reverse: true,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Hero(
                  tag: widget.anotherUser.id,
                  child: AnotherUserAvatar(anotherUser: widget.anotherUser),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.anotherUser.name,
                      style: TextStyle(
                        color: AppColors.secondaryColor,
                        fontSize: 32,
                      ),
                    ),
                    Text(
                      widget.anotherUser.email,
                      style: TextStyle(
                        color: AppColors.secondaryColor,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      widget.anotherUser.role.name,
                      style: TextStyle(
                        color: AppColors.secondaryColor,
                        fontSize: 15,
                      ),
                    )
                  ],
                )
              ],
            ),
            GestureDetector(
              onTap: toggle,
              child: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  color: AppColors.secondaryColor,
                  size: 32,
                  progress: _AnimationController),
            )
          ],
        ),
      ),
    );
  }
}

class AnotherUserAvatar extends StatelessWidget {
  const AnotherUserAvatar({
    super.key,
    required this.anotherUser,
  });

  final UserModel anotherUser;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: anotherUser.avatarUrl ?? '',
      fit: BoxFit.cover,
      fadeInDuration: Duration(milliseconds: 10),
      fadeOutDuration: Duration(milliseconds: 10),
      placeholder: (context, url) => Skeletonizer(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      imageBuilder: (context, imageProvider) {
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}

Widget defaultPage() {
  return Center(
    child: CircularProgressIndicator(
      color: AppColors.mainColor,
    ),
  );
}

void _showUploadingDialog(BuildContext context, List<String> imageUrls,
    String chatroomId, String currentUserId, ChatroomBloc chatroomBloc) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => UploadingDialog(
        chatroomBloc: chatroomBloc,
        imageUrls: imageUrls,
        chatroomId: chatroomId,
        currentUserId: currentUserId),
  );
}

class UploadingDialog extends StatefulWidget {
  final List<String> imageUrls;
  final String chatroomId;
  final String currentUserId;
  final ChatroomBloc chatroomBloc;

  const UploadingDialog(
      {Key? key,
      required this.imageUrls,
      required this.chatroomId,
      required this.currentUserId,
      required this.chatroomBloc})
      : super(key: key);

  @override
  _UploadingDialogState createState() => _UploadingDialogState();
}

class _UploadingDialogState extends State<UploadingDialog> {
  List<double> _progressList = [];

  @override
  void initState() {
    super.initState();
    _progressList = List.generate(widget.imageUrls.length, (index) => 0.0);
    _startUploading();
  }

  void _startUploading() async {
    List<String> urls = [];
    for (int i = 0; i < widget.imageUrls.length; i++) {
      await uploadFile(
          widget.imageUrls[i], widget.chatroomId, widget.currentUserId,
          (double progress) {
        setState(() {
          _progressList[i] = progress;
        });
      }, (String url) {
        urls.add(url);

        if (urls.length == widget.imageUrls.length) {
          widget.chatroomBloc.add(ChatroomClickSendImageEvent(
              widget.chatroomId,
              MessageModel(
                  chatroomId: widget.chatroomId,
                  text: '',
                  senderId: widget.currentUserId,
                  time: DateTime.now(),
                  readBy: [widget.currentUserId],
                  imageUrls: urls)));
        }
      });
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Container(
          width: 300,
          height: 300,
          child: Column(
            children: [
              Text('Uploading ${widget.imageUrls.length} app_images...',
                  style: TextStyle(fontSize: 20, color: AppColors.mainColor)),
              Expanded(
                child: GridView.builder(
                  itemCount: widget.imageUrls.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      width: 150,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.file(
                            File(widget.imageUrls[index]),
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                          CircularProgressIndicator(
                            value: _progressList[index],
                            backgroundColor: Colors.black.withOpacity(0.5),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Text(
                              '${(_progressList[index] * 100).toStringAsFixed(0)}%',
                              style: TextStyle(color: AppColors.mainColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> uploadFile(
    String filePath,
    String chatroomId,
    String currentUserId,
    Function(double) onProgress,
    Function(String) onCompleted) async {
  File file = File(filePath);
  String destination =
      'chatroom_files/$chatroomId/${file.uri.pathSegments.last}';

  try {
    UploadTask task = FirebaseStorage.instance.ref(destination).putFile(
          file,
          SettableMetadata(customMetadata: {'uploaded_by': currentUserId}),
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
