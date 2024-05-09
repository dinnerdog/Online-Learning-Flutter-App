// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:test1/main.dart';

class ImagePickerUploader extends StatefulWidget {
  final String category;

  final String? initialImageUrl;
  final Function(String) onUrlUploaded;

  ImagePickerUploader(
      {Key? key,
      required this.category,
      required this.onUrlUploaded,
      this.initialImageUrl})
      : super(key: key);

  @override
  _ImagePickerUploaderState createState() => _ImagePickerUploaderState();
}

class _ImagePickerUploaderState extends State<ImagePickerUploader> {
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;
  @override
  void initState() {
    ;
    super.initState();
    _imageUrl = widget.initialImageUrl;
    // _loadInitialImageUrl();
  }

  _ImagePickerUploaderState();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // _uploadImage(File(image.path));
      _imageUrl = image.path;
   
      widget.onUrlUploaded(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
  
    return _imageUrl != null && _imageUrl!.isNotEmpty
        ?
        //diesplay image locally
        Container(
            width: double.maxFinite,
            height: double.maxFinite,
            decoration: BoxDecoration(
              color: AppColors.mainColor,
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                if (_imageUrl!.startsWith('http://') ||
                    _imageUrl!.startsWith('https://'))
                  CachedNetworkImage(
               
                    progressIndicatorBuilder:(context, url, progress) {
                      return CircularProgressIndicator(value: progress.progress, color: AppColors.mainColor, backgroundColor: AppColors.secondaryColor,);
                      
                    },
                    width: double.infinity,
                    height: double.infinity,
                    imageUrl: _imageUrl!,
                    fit: BoxFit.cover,
                  )
                else
                  Image.file(
                    File(_imageUrl!),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                TextButton.icon(
                 
                  icon:
                      Icon(Icons.add_a_photo, color: AppColors.secondaryColor),
                  onPressed: _pickImage,
                  label: Text(
                    'Change Image',
                    style: TextStyle(color: AppColors.secondaryColor),
                  ),

                ),
              ],
            ),
          )
        : GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                color: AppColors.mainColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(

                child: ListTile(
                   
                  title: Text('Add Image',
                      style: TextStyle(color: AppColors.secondaryColor)),
   
                  leading:
                      Icon(Icons.add_a_photo, color: AppColors.secondaryColor),
                trailing: 
                Icon(
                  Icons.ads_click,
                  color: AppColors.secondaryColor,
                  size: 16,
                )
                ),
              ),
            ),
          );
  }
}
