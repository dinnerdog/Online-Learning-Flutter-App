import 'package:cloud_firestore/cloud_firestore.dart';



class ChatMemberModel{
  final DateTime lastRead;

  
  

  ChatMemberModel({required this.lastRead});

  factory ChatMemberModel.fromFirestore(Map<String, dynamic> data) {
      try{
        return ChatMemberModel(
          lastRead: (data['lastRead'] as Timestamp).toDate(),
         
        );
      } catch (e) {
        print(e.toString());
        return ChatMemberModel(
          lastRead: (data['lastRead'] as Timestamp).toDate(),
      
        );
      }
  


}
  Map<String, dynamic> toMap() => {
        'lastRead': lastRead,
        
      };
  }




class ChatroomModel {
  final String id;
  final String title;
  final String? lastMessage;
  final DateTime? lastMessageTime;



  ChatroomModel(
      {required this.id, required this.title, this.lastMessage, this.lastMessageTime});

  factory ChatroomModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
      try {
        return ChatroomModel(
          id: doc.id,
          title: data['title'],
          lastMessage: data['lastMessage'] ?? null,
          lastMessageTime: data['lastMessageTime'] != null  ? (data['lastMessageTime'] as Timestamp).toDate() : null,
         
        );
      } catch (e) {
        print('Error: $e');
        return ChatroomModel(
          id: doc.id,
          title: data['title'],
          lastMessage: data['lastMessage'],
          lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
         
        );
      }
  }

   Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime,
      };


}

class MessageModel {
  final String? id;
  final String chatroomId;
  final String text;
  final String senderId;
  final DateTime time;
  List<String> imageUrls;
  List<String> readBy;

  MessageModel(
      {this.id,
      required this.chatroomId,
      required this.text,
      required this.senderId,
      required this.time,
      required this.readBy,
      required this.imageUrls
    
      
      });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return MessageModel(
      id: doc.id,
      chatroomId: data['chatroomId'],
      senderId: data['senderId'],
      text: data['text'],
      time: (data['time'] as Timestamp).toDate(),
      readBy: List<String>.from(data['readBy'] ?? []), imageUrls: List<String>.from(data['imageUrls'] ?? [])
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'chatroomId': chatroomId,
        'senderId': senderId,
        'text': text,
        'time': time,
        'readBy': readBy,
        'imageUrls': imageUrls
      };

}
