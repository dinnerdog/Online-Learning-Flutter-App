import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget buildBadge(String badgeName, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: GridTile(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/app_images/badge.svg',
            ),
            Text(
              badgeName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }