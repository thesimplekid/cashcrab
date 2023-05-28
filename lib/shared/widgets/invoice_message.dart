import 'package:cashcrab/bridge_definitions.dart';
import 'package:flutter/material.dart';

class InvoiceMessageWidget extends StatelessWidget {
  final Direction direction;
  final LNTransaction? transaction;
  final Function payInvoice;

  const InvoiceMessageWidget(this.direction, this.transaction, this.payInvoice,
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
                  const Text("Lightning Invoice"),
                  Text("Amount: ${transaction?.amount}"),
                  // TODO: Check if paid
                  ElevatedButton(
                    onPressed: () async {
                      payInvoice(transaction?.bolt11, transaction?.mint,
                          transaction?.amount);
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
    );
  }
}
