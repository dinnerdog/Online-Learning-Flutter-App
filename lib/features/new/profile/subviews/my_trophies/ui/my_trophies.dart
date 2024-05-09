import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:test1/data/model/course_user_model.dart';
import 'package:test1/data/model/incentives_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/global/common/build_badge.dart';
import 'package:test1/global/common/toast.dart';
import 'package:test1/global/extension/date_time.dart';
import 'package:test1/main.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class MyTrophies extends StatefulWidget {
  final List<CourseUserModel> courseUsers;
  final IncentiveModel incentiveModel;
  final UserModel user;

  const MyTrophies(
      {super.key,
      required this.courseUsers,
      required this.incentiveModel,
      required this.user});

  @override
  State<MyTrophies> createState() => _MyTrophiesState();
}

class _MyTrophiesState extends State<MyTrophies> {
  late final starCount;
  GlobalKey repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    starCount = widget.courseUsers.isEmpty
        ? 0
        : widget.courseUsers
            .map((e) => e.earnedStars
                .map((e) => e.rating)
                .reduce((value, element) => value + element))
            .reduce((value, element) => value + element);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> captureAndSaveImage() async {
      RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 5.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = (await getApplicationDocumentsDirectory()).path;
      File imgFile = File('$directory/screenshot.png');
      await imgFile.writeAsBytes(pngBytes);

      final result = await ImageGallerySaver.saveImage(pngBytes);
      print(result);
    }

    return Scaffold(
      backgroundColor: AppColors.mainColor.withOpacity(0.5),
      appBar: AppBar(
        title: Text('My Trophies'),
        foregroundColor: AppColors.secondaryColor,
        backgroundColor: AppColors.mainColor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _showLoadingDialog(context);
          await captureAndSaveImage();
          showToast(message: 'Saved to gallery successfully!');
          Navigator.pop(context);
        },
        child: Icon(Icons.save),
      ),
      body: RepaintBoundary(
        key: repaintBoundaryKey,
        child: Stack(
          children: [
            Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  'assets/app_images/welcome1.png',
                  fit: BoxFit.cover,
                )),
            Container(
              height: MediaQuery.of(context).size.height,
              color: AppColors.mainColor.withOpacity(0.5),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: Icon(
                          Icons.star,
                          color: AppColors.mainColor,
                        ),
                        subtitle: Text(
                          'All the glory you have earned so far',
                          style: TextStyle(color: AppColors.mainColor),
                        ),
                        title: Text(
                          'The trophies wall',
                          style: TextStyle(color: AppColors.mainColor),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 300,
                      decoration: BoxDecoration(
                          color: AppColors.mainColor,
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.all(30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              flex: 1,
                              child: CachedNetworkImage(
                                imageUrl: widget.user.avatarUrl!,
                                fit: BoxFit.cover,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              )),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: AppColors.secondaryColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ListTile(
                                          dense: true,
                                          leading: CircleAvatar(
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                    widget.user.avatarUrl!),
                                          ),
                                          title: Text(
                                            widget.user.name,
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: AppColors.mainColor),
                                          ),
                                          trailing: Icon(
                                            Icons.verified,
                                            color: AppColors.mainColor,
                                          )),
                                      Text(
                                        'Birthday: ${widget.user.birthday.formalizeOnly()}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: AppColors.mainColor),
                                      ),
                                      Text(
                                        '${widget.user.role.name} of kind hearts',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: AppColors.mainColor),
                                      ),
                                      Text(
                                        'Owning 🎖️ ${widget.incentiveModel.badges.length}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: AppColors.mainColor),
                                      ),
                                      Text(
                                        'Owning 🌟 ${starCount}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: AppColors.mainColor),
                                      ),
                                      Text(
                                        'Owning 🎓 ${widget.incentiveModel.certificates.length}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: AppColors.mainColor),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Image.asset(
                                'assets/app_images/welcome1.png',
                                fit: BoxFit.cover,
                              ))
                        ],
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        height: 300,
                        width: MediaQuery.of(context).size.width,
                        child: Stack(
                          children: List.generate(starCount, (i) {
                            double badgeWidth = 100;
                            double badgeHeight = 100;

                            double containerWidth =
                                MediaQuery.of(context).size.width;
                            double containerHeight = 300;

                            double left =
                                getRandomPosition(containerWidth, badgeWidth);
                            double top =
                                getRandomPosition(containerHeight, badgeHeight);

                            return Positioned(
                              left: left,
                              top: top,
                              child: Container(
                                width: badgeWidth,
                                height: badgeHeight,
                                child: SvgPicture.asset(
                                    'assets/app_images/star.svg'),
                              ),
                            );
                          }),
                        ),
                      ),
                      Container(
                        height: 300,
                        width: MediaQuery.of(context).size.width,
                        child: Stack(
                          children: List.generate(
                              widget.incentiveModel.badges.length, (i) {
                            double badgeWidth = 100;
                            double badgeHeight = 100;

                            double containerWidth =
                                MediaQuery.of(context).size.width;
                            double containerHeight = 300;

                            double left =
                                getRandomPosition(containerWidth, badgeWidth);
                            double top =
                                getRandomPosition(containerHeight, badgeHeight);

                            return Positioned(
                              left: left,
                              top: top,
                              child: Container(
                                width: badgeWidth,
                                height: badgeHeight,
                                child: buildBadge(
                                    widget.incentiveModel.badges[i].badgeName),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.incentiveModel.certificates.length,
                        itemBuilder: (context, index) => Container(
                          height: 200,
                          width: 200,
                          child: Stack(
                            children: [
                              SvgPicture.asset(
                                  'assets/app_images/certificate.svg'),
                                Text(
                                ''' ${ widget.incentiveModel.certificates[index].certificateName}
                                    ${widget.incentiveModel.certificates[index].dateEarned.formalizeOnly()}''',
                                style: TextStyle(
                                    color: Colors.white),
                              ),
                            
                            ],
                          ),
                        )),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
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

Random random = Random();

double getRandomPosition(double max, double size) {
  return random.nextDouble() * (max - size);
}
