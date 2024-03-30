import 'package:chat_messenger/helpers/app_helper.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:flutter/material.dart';

class LocationMessage extends StatelessWidget {
  const LocationMessage(this.message, {super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final double latitude = message.location!.latitude;
    final double longitude = message.location!.longitude;

    return GestureDetector(
      onTap: () => AppHelper.openGoogleMaps(latitude, longitude),
      child: Container(
        padding: const EdgeInsets.only(bottom: 15),
        width: MediaQuery.of(context).size.width * 0.55,
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/icons/map_icon.png'),
          ),
        ),
      ),
    );
  }
}
