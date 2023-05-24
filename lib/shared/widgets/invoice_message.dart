import 'package:cashcrab/bridge_definitions.dart';
import 'package:flutter/material.dart';

class InvoiceMessageWidget extends StatelessWidget {
  final Direction direction;
  final int amount;
  final int time;
  final String bolt11;
  final InvoiceStatus status;
  final String mint;
  final Function payInvoice;

  const InvoiceMessageWidget(this.direction, this.amount, this.time,
      this.bolt11, this.status, this.mint, this.payInvoice,
      {super.key});

  @override
  Widget build(BuildContext context) {
    Color bubbleColor;
    if (direction == Direction.Sent) {
      bubbleColor = Colors.purple;
    } else {
      bubbleColor = Colors.grey;
    }

    return Scaffold(
      body: Row(
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
                    const Text("Lightning Invoice"),
                    Text("Amount: $amount"),
                    // TODO: Check if paid
                    ElevatedButton(
                      onPressed: () async {
                        payInvoice(bolt11, mint, amount);
                      },
                      // TODO: Check if paid
                      child: const Text('Pay Invoice'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
