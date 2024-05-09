import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:test1/data/model/chat_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/global/extension/date_time.dart';
import 'package:test1/main.dart';

class ContactTile extends StatelessWidget {
  final String myId;
  final UserModel userModel;
  final ChatMemberModel? chatMemberModel;
  final ChatroomModel? chatroomModel;

  const ContactTile(
      {super.key,
      required this.userModel,
      required this.chatMemberModel,
      required this.chatroomModel,
      required this.myId});

  @override
  Widget build(BuildContext context) {
    final bool isMe = myId == userModel.id;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isMe
            ? AppColors.accentColor.withOpacity(0.1)
            : AppColors.secondaryColor,
      ),
      child: ListTile(
        textColor: AppColors.mainColor,
        enabled: !isMe,
        leading: Container(
          width: 50,
          height: 50,
          child: Hero(
            tag: userModel.id,
            child: CachedNetworkImage(
              imageUrl: userModel.avatarUrl ?? '',
              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 0),
              placeholder: (context, url) => Skeletonizer(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              imageBuilder: (context, imageProvider) {
                bool isRead = true;
            
                if (chatMemberModel != null &&
                    chatroomModel!.lastMessageTime != null &&
                    chatMemberModel!.lastRead
                        .isBefore(chatroomModel!.lastMessageTime!)) {
                  isRead = false;
                }
            
                if (!isRead) {
                  return Badge(
                    textColor: AppColors.secondaryColor,
                    backgroundColor: AppColors.accentColor,
                    largeSize: 32,
                    smallSize: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                  );
                }
            
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image:
                        DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
        ),
        trailing: SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe)
                Badge(
                  isLabelVisible: chatMemberModel != null &&
                      chatroomModel!.lastMessageTime != null &&
                      chatMemberModel!.lastRead
                          .isBefore(chatroomModel!.lastMessageTime!),
                  label: Text('Unread Message'),
                  textColor: AppColors.secondaryColor,
                  backgroundColor: AppColors.accentColor,
                ),
              if (!isMe)
                Text(
                  chatroomModel?.lastMessageTime?.informalTime() ?? '',
                  style: TextStyle(color: AppColors.mainColor, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              if (!isMe)
                Text(
                  chatroomModel?.lastMessage ?? '',
                  maxLines: 1,
                  style: TextStyle(color: AppColors.mainColor, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        title: Text(isMe ? 'This is Me' : userModel.name,
            style: TextStyle(
                color: isMe ? AppColors.accentColor : AppColors.mainColor,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        subtitle: Text(isMe ? 'Me' : userModel.role.name),
      ),
    );
  }
}
