import 'package:flutter/material.dart';

import 'package:cashcrab/bridge_definitions.dart';
import 'package:cashcrab/shared/widgets/numeric_input.dart';
import 'package:cashcrab/screens/token_info.dart';
import 'package:cashcrab/screens/ln/pay_invoice.dart';
import 'package:cashcrab/bridge_generated.dart';

class Send extends StatefulWidget {
  final Function send;
  final int activeBalance;
  final Function decodeToken;
  final Function payInvoice;
  final String? activeMint;
  final RustImpl api;
  final Map<String, int> wallets;

  const Send(
      {super.key,
      required this.send,
      required this.activeBalance,
      required this.decodeToken,
      required this.payInvoice,
      required this.activeMint,
      required this.api,
      required this.wallets});

  @override
  SendState createState() => SendState();
}

class SendState extends State<Send> {
  final receiveController = TextEditingController();

  TokenData? tokenData;
  int amountToSend = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              "Send ECash",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 100,
              child: NumericInput(
                onValueChanged: (String value) {
                  if (value.isNotEmpty) {
                    amountToSend = int.tryParse(value) ?? amountToSend;
                  }
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 70),
              ),
              onPressed: () {
                // TODO: Alert dialog id balance not enough
                if (amountToSend <= widget.activeBalance && amountToSend > 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TokenInfo(
                        amount: amountToSend,
                        mintUrl: widget.activeMint,
                        send: widget.send,
                        decodeToken: widget.decodeToken,
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                'Create Token',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 50),
            Flexible(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 70),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PayInvoice(
                        activeMint: widget.activeMint,
                        payInvoice: widget.payInvoice,
                        api: widget.api,
                        mints: widget.wallets,
                      ),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt),
                    Text(
                      'Pay via Lightning',
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
