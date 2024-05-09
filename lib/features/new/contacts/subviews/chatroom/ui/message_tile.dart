import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:test1/data/model/chat_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/user_repository.dart';
import 'package:test1/global/common/toast.dart';
import 'package:test1/global/extension/date_time.dart';
import 'package:test1/main.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageTile extends StatelessWidget {
  final MessageModel message;
  final UserModel anotherUser;
  final UserModel currentUser;

  const MessageTile({
    super.key,
    required this.message,
    required this.anotherUser,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.senderId == currentUser.id;
    final bool isRead = message.readBy.contains(currentUser.id);
    final bool isImage = message.imageUrls.isNotEmpty;


    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isMe
                  ? [AppColors.mainColor, AppColors.mainColor.withOpacity(0.9)]
                  : [
                      Color.fromARGB(26, 93, 79, 79),
                      Color.fromARGB(26, 165, 129, 129)
                    ],
            ),
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23))
                : BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(23)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CachedNetworkImage(
                    imageUrl:
                        isMe ? currentUser.avatarUrl! : anotherUser.avatarUrl!,
                    fadeInDuration: Duration(milliseconds: 0),
                    imageBuilder: (context, imageProvider) => Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.person,
                      size: 20,
                      color: AppColors.secondaryColor,
                    ),
                    placeholder: (context, url) => Icon(
                      Icons.person,
                      size: 20,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    isMe ? 'You' : anotherUser.name,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              isImage
                  ? SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: Container(
                        width: 300,
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),

                          
                          shrinkWrap: true,
                          itemCount: message.imageUrls.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                _showDetailImageDialog(
                                    context, message.imageUrls[index]);
                              },
                              child: CachedNetworkImage(
                                imageUrl: message.imageUrls[index],
                                fit: BoxFit.cover,
                                fadeInDuration: Duration(milliseconds: 0),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                  size: 20,
                                  color: AppColors.secondaryColor,
                                ),
                                placeholder: (context, url) => Icon(
                                  Icons.image,
                                  size: 20,
                                  color: AppColors.secondaryColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : Text(
                      message.text,
                      style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
                    ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  message.time.informalTime(),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDetailImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context), 
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(imageUrl),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(), 
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, color: AppColors.secondaryColor),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    foregroundColor: AppColors.mainColor,
                  ),
                  icon: Icon(Icons.download, color: AppColors.accentColor),
                  label:
                      Text('Download', style: TextStyle(color: AppColors.accentColor)),
                  onPressed: () async {
                    final uri = Uri.parse(imageUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      showToast(message: 'Could not launch $imageUrl');
                    }
                  },
                  
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
