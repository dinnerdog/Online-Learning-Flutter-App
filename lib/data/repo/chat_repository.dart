import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test1/data/model/chat_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/user_repository.dart';

class ChatRepository {
  final chatroomsCollection =
      FirebaseFirestore.instance.collection('chatrooms');

  Stream<List<ChatroomModel>> getChatrooms() {
    return chatroomsCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ChatroomModel.fromFirestore(doc)).toList());
  }


 Stream<List<UserModel>> getChatRoomMembers(String chatRoomId) {

    return chatroomsCollection.doc(chatRoomId).snapshots().switchMap((chatRoomSnapshot) {
      List<String> memberIds = List.from(chatRoomSnapshot.data()?['chatMembers'] ?? []);
      
      if (memberIds.isEmpty) {
        return Stream.value([]);
      }

      List<Stream<UserModel>> memberStreams = memberIds.map((id) {
        return FirebaseFirestore.instance.collection('users').doc(id).snapshots().map((snapshot) => UserModel.fromFirestore(snapshot));
      }).toList();

      return CombineLatestStream.list(memberStreams);
    });
  }




  Future<void> sendMessage(String chatroomId, MessageModel message) async {
    final bool isImage = message.imageUrls.isNotEmpty;

    try {
      await chatroomsCollection
          .doc(chatroomId)
          .collection('messages')
          .add(message.toMap());

      await chatroomsCollection
          .doc(chatroomId)
          .update({
        'lastMessage':  isImage ? '[Image Resources]' : message.text,
        'lastMessageTime': message.time,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateLastRead(String chatroomId, String userId) async {
    try {
      await chatroomsCollection
          .doc(chatroomId)
          .collection('chat_members')
          .doc(userId)
          .update({
        'lastRead': DateTime.now(),
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Stream<ChatMemberModel?> getChatMemberStream(
      String uid1, String uid2) {

            String chatroomId =
        (uid1.compareTo(uid2) < 0) ? "$uid1$uid2" : "$uid2$uid1";

    try {
      return chatroomsCollection
          .doc(chatroomId)
          .collection('chat_members')
          .doc(uid1)
          .snapshots()
          .map((snapshot) {
        return ChatMemberModel.fromFirestore(
            snapshot.data() as Map<String, dynamic>);
      });
    } catch (e) {
      print(e.toString());
      return Stream.empty();
    }
  }

  Stream<ChatroomModel?> getChatroomStream(String uid1, String uid2) {
    String chatroomId =
        (uid1.compareTo(uid2) < 0) ? "$uid1$uid2" : "$uid2$uid1";

    return chatroomsCollection.doc(chatroomId).snapshots().map((snapshot) {
      return ChatroomModel.fromFirestore(snapshot);
    });
  }

  Stream<List<MessageModel>> getChatroomMessagesStream(String chatroomId) {
    return chatroomsCollection
        .doc(chatroomId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  Future<String> createOrJoinChatroom(String uid1, String uid2) async {
    String chatroomId =
        (uid1.compareTo(uid2) < 0) ? "$uid1$uid2" : "$uid2$uid1";

    try {
      final chatroomDoc = await chatroomsCollection.doc(chatroomId).get();

      if (!chatroomDoc.exists) {
        await chatroomsCollection.doc(chatroomId).set({
          'id': chatroomId,
          'title': 'test1',
        });

        List<String> userIds = [uid1, uid2];
        for (String userId in userIds) {
          await chatroomsCollection
              .doc(chatroomId)
              .collection('chat_members')
              .doc(userId)
              .set({
            'lastRead': DateTime.now(),
          });
        }

        return chatroomId;
      }

      return chatroomId;
    } catch (e) {
      print(e.toString());
      return '';
    }
  }
}
