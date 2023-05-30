import 'package:cashcrab/bridge_definitions.dart';
import 'package:cashcrab/bridge_generated.dart';
import 'package:cashcrab/shared/utils.dart';
import 'package:flutter/material.dart';

class ContactPayment extends StatefulWidget {
  final String peerPubkey;
  final String? peerName;
  final int activeBalance;
  final String activeMint;
  final RustImpl api;
  // final Map<String, int> mints;
  final Function send;
  final Function sendToken;
  final Function createInvoice;

  const ContactPayment(
      {super.key,
      required this.peerPubkey,
      required this.peerName,
      required this.activeBalance,
      required this.activeMint,
      required this.api,
      // required this.mints,
      required this.send,
      required this.sendToken,
      required this.createInvoice});

  @override
  State<ContactPayment> createState() => _ContactPaymentState();
}

class _ContactPaymentState extends State<ContactPayment> {
  _ContactPaymentState();
  int amountToSend = 0;
  late TextEditingController _controller;
  bool _isPlaceholderVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '');
  }

  Future<Message> createSendMessage(int amount) async {
    Transaction transaction = await widget.sendToken(amount);

    CashuTransaction cTransaction = transaction.field0 as CashuTransaction;

    return Message.token(
        direction: Direction.Sent,
        time: cTransaction.time,
        transactionId: cTransaction.id!);
  }

  Future<Message> createRequestMessage(int amount) async {
    LNTransaction transaction =
        await widget.createInvoice(amount, widget.activeMint);

    return Message.invoice(
        direction: Direction.Sent,
        time: transaction.time,
        transactionId: transaction.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerName ?? truncateText(widget.peerPubkey)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            child: Column(
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Balance: ${widget.activeBalance} sats",
                        style: const TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ), // Balance Container
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.home),
                Flexible(
                  child: Text(
                    widget.activeMint,
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Align(
                          alignment: Alignment.center,
                          child: TextField(
                            controller: _controller,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            showCursor: false,
                            onChanged: (value) {
                              setState(() {
                                _isPlaceholderVisible = value.isEmpty;
                              });

                              if (_isPlaceholderVisible) {
                                _controller.text = '0';
                              }
                            },
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              hintText: _isPlaceholderVisible ? '0' : '',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text("sats")
                ],
              ),
            ),
          ),
          Row(
            children: [
              Flexible(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 70),
                  ),
                  onPressed: () async {
                    String value = _controller.text;

                    if (value.isNotEmpty) {
                      final parsedValue = int.tryParse(value);
                      if (parsedValue != null && parsedValue > 0) {
                        Message msg = await createRequestMessage(parsedValue);

                        await widget.send(msg);

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    }
                  },
                  child: const Text('Request'),
                ),
              ),
              Flexible(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 70),
                  ),
                  onPressed: () async {
                    String value = _controller.text;

                    if (value.isNotEmpty) {
                      final parsedValue = int.tryParse(value);
                      if (parsedValue != null && parsedValue > 0) {
                        Message msg = await createSendMessage(parsedValue);

                        await widget.send(msg);

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    }
                  },
                  child: const Text('Send'),
                ),
              ),
            ], // Button row children
          ), // Button Row
        ], // body children
      ), // Body column
    );
  } // Build widget
}
