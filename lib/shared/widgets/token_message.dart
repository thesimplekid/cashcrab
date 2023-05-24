import 'package:cashcrab/bridge_definitions.dart';
import 'package:flutter/material.dart';

class TokenMessageWidget extends StatelessWidget {
  final Direction direction;
  final int amount;
  final String mint;
  final String token;
  final Function receiveToken;

  const TokenMessageWidget(
      this.amount, this.token, this.mint, this.receiveToken, this.direction,
      {super.key});

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
          child: Row(
            children: [
              Column(
                children: [
                  const Text("Cashu Token"),
                  Text("Amount: $amount"),
                  Text("Mint: $mint"),
                  // TODO: Check if spendable
                  ElevatedButton(
                    onPressed: () async {
                      receiveToken(token);
                    },
                    child: const Text('Redeam'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
