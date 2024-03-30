import 'package:flutter/material.dart';
import 'package:video_editor/video_editor.dart';

class TrimSliderTab extends StatelessWidget {
  const TrimSliderTab(this.controller, {super.key});

  // Params
  final VideoEditorController controller;

  @override
  Widget build(BuildContext context) {
    // Vars
    const double height = 60;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([
            controller,
            controller.video,
          ]),
          builder: (_, __) {
            final duration = controller.videoDuration.inSeconds;
            final pos = controller.trimPosition * duration;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: height / 4),
              child: Row(children: [
                Text(_formatter(Duration(seconds: pos.toInt()))),
                const Expanded(child: SizedBox()),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(_formatter(controller.startTrim)),
                  const SizedBox(width: 10),
                  Text(_formatter(controller.endTrim)),
                ]),
              ]),
            );
          },
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(vertical: height / 4),
          child: TrimSlider(
            controller: controller,
            height: height,
            horizontalMargin: height / 4,
            child: TrimTimeline(
              controller: controller,
              padding: const EdgeInsets.only(top: 10),
            ),
          ),
        )
      ],
    );
  }

  String _formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");
}
