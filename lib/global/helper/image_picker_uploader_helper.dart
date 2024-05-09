
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';


class ImagePickerUploaderHelper {
  
  static Future<String?> uploadImage({
    required String category,
    required String id,
    required String imageUrl,
  }) async {
    try {

       
      print(imageUrl);
      final String fileName = '$category.jpg';
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child(category)
          .child(id)
          .child(fileName);
      final UploadTask uploadTask = ref.putFile(File(imageUrl));
      final TaskSnapshot downloadUrl = (await uploadTask);
      final String url = (await downloadUrl.ref.getDownloadURL());
      return url;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
  

}


  