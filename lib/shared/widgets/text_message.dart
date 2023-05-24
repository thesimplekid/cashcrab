import 'package:cashcrab/bridge_definitions.dart';
import 'package:flutter/material.dart';

class TextMessageWidget extends StatelessWidget {
  final Direction direction;
  final int time;
  final String content;

  const TextMessageWidget(this.time, this.content, this.direction, {super.key});

  @override
  Widget build(BuildContext context) {
    Color bubbleColor;
    if (direction == Direction.Sent) {
      bubbleColor = Colors.purple;
    } else {
      bubbleColor = Colors.grey;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (direction == Direction.Sent) const Spacer(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(10),
          ),
          constraints: const BoxConstraints(maxWidth: 200), // Set maximum width
          child: Row(
            children: [
              Flexible(
                // Add Flexible widget to wrap text
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
