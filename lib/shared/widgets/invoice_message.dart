import 'package:cashcrab/bridge_definitions.dart';
import 'package:cashcrab/shared/colors.dart';
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
      bubbleColor = purpleColor;
    } else {
      bubbleColor = Colors.grey;
    }

    Color buttonColor;
    String buttonText;

    switch (transaction?.status) {
      case TransactionStatus.Pending:
        buttonColor = messageAction;
        buttonText = "Pay Invoice";
        break;
      case TransactionStatus.Expired:
        buttonColor = expiredColor;
        buttonText = "Expired";

        break;
      default:
        buttonColor = paidColor;
        buttonText = "Paid";
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
                  ElevatedButton(
                    onPressed: () async {
                      payInvoice(transaction?.bolt11, transaction?.mint,
                          transaction?.amount);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(buttonColor),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: Color(0xFFEDDFEF), // Set the desired text color
                      ),
                    ),
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
