import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/components/loading_indicator.dart';

import 'svg_icon.dart';

class CachedCircleAvatar extends StatelessWidget {
  const CachedCircleAvatar({
    super.key,
    required this.imageUrl,
    this.isOnline = false,
    this.radius = 16,
    this.borderColor,
    this.backgroundColor,
    this.iconSize,
    this.borderWidth = 2.0,
    this.padding = 2,
    this.isGroup = false,
    this.isBroadcast = false,
  });

  // Variables
  final String imageUrl;
  final bool isGroup, isBroadcast, isOnline;
  final double radius;
  final Color? borderColor, backgroundColor;
  final double borderWidth;
  final double padding;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    // Vars
    late dynamic image;
    final Color? bgColor = backgroundColor ?? Colors.grey[350];
    final Widget broadcastIcon = SvgIcon('assets/icons/broadcast.svg',
        width: iconSize ?? 25, height: iconSize ?? 25, color: Colors.white);

    if (imageUrl.isEmpty) {
      image = CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: isGroup && isBroadcast
            ? broadcastIcon
            : Icon(isGroup ? IconlyBold.user3 : IconlyBold.profile,
                color: Colors.white, size: iconSize ?? 25),
      );
    } else {
      // Get network image
      image = CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: imageUrl,
        imageBuilder: (_, ImageProvider image) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: image,
            backgroundColor: bgColor,
            onBackgroundImageError: (_, __) => debugPrint('image not found'),
          );
        },
        placeholder: (context, url) => CircleAvatar(
          radius: radius,
          backgroundColor: bgColor,
          child: const LoadingIndicator(size: 10),
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: radius,
          backgroundColor: bgColor,
          child: Icon(IconlyBold.profile,
              color: Colors.white, size: iconSize ?? 20),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor ?? Colors.transparent,
              width: borderWidth,
            ),
          ),
          padding: EdgeInsets.all(padding),
          child: image,
        ),
        // Show online indicator
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              height: 18,
              width: 18,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
