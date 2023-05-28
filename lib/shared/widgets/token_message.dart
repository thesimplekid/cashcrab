import 'package:cashcrab/bridge_definitions.dart';
import 'package:flutter/material.dart';

class TokenMessageWidget extends StatelessWidget {
  final Direction direction;
  final CashuTransaction? transaction;
  final Function receiveToken;

  const TokenMessageWidget(this.receiveToken, this.direction, this.transaction,
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
                  Text("Amount: ${transaction?.amount}"),
                  Text("Mint: ${transaction?.mint}"),
                  // TODO: Check if spendable
                  ElevatedButton(
                    onPressed: () async {
                      receiveToken(transaction?.token);
                    },
                    child: Text(transaction?.status == TransactionStatus.Pending
                        ? 'Redeem'
                        : 'Claimed'),
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
