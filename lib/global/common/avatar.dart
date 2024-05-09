import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Avatar extends StatefulWidget {
  final avatarUrl;
  final double width;
  final double height;
  const Avatar({super.key, required this.avatarUrl, required this.width, required this.height});

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 0.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // 阴影颜色
              spreadRadius: 1, // 阴影扩散程度
              blurRadius: 2, // 阴影模糊程度
              offset: Offset(0, 3), // 阴影的偏移
            ),
          ],
          shape: BoxShape.circle,
          color: Colors.white),
      child: ClipOval(
        child: Container(
            width: widget.width,
            height:  widget.height,
            child: CachedNetworkImage(
              imageUrl: widget.avatarUrl ?? '',
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.person),
              fit: BoxFit.fitHeight,
            )),
      ),
    );
  }
}
