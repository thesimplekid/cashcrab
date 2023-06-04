import 'package:flutter/material.dart';

import 'package:cashcrab/bridge_definitions.dart';
import 'package:cashcrab/shared/colors.dart';

class TextMessageWidget extends StatelessWidget {
  final Direction direction;
  final int time;
  final String content;

  const TextMessageWidget(this.time, this.content, this.direction, {super.key});

  @override
  Widget build(BuildContext context) {
    Color bubbleColor;
    if (direction == Direction.Sent) {
      bubbleColor = purpleColor;
    } else {
      bubbleColor = Colors.grey;
    }

    return Row(
      mainAxisAlignment: direction == Direction.Sent
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (direction == Direction.Sent) const Spacer(),
        Stack(
          alignment: direction == Direction.Sent
              ? Alignment.centerRight
              : Alignment.centerLeft,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  softWrap: true,
                ),
              ),
            ),
          ],
        ),
        if (direction == Direction.Received) const Spacer(),
      ],
    );
  }
}
