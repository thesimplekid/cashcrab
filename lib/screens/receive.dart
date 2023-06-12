import 'package:flutter/material.dart';

import 'package:cashcrab/bridge_generated.dart';
import 'package:cashcrab/screens/ln/invoice_info.dart';
import 'package:cashcrab/screens/cashu/receive_token.dart';

class Receive extends StatefulWidget {
  final Function decodeToken;
  final Function receiveToken;
  final Function addMint;
  final Function createInvoice;
  final Map<String, int> mints;
  final RustImpl cashu;
  final String? activeWallet;

  const Receive(
      {super.key,
      required this.decodeToken,
      required this.activeWallet,
      required this.receiveToken,
      required this.mints,
      required this.addMint,
      required this.cashu,
      required this.createInvoice});

  @override
  ReceiveState createState() => ReceiveState();
}

class ReceiveState extends State<Receive> {
  // int amountToSend = 0;
  late TextEditingController _controller;
  bool _isPlaceholderVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '');
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    super.dispose();
    _controller.dispose;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive'),
      ),
      body: Center(
        child: SizedBox(
          child: Column(
            children: [
              Flexible(
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
              const SizedBox(height: 3),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 70),
                ),
                onPressed: () {
                  String value = _controller.text;

                  if (value.isNotEmpty) {
                    final amountToSend = int.tryParse(value);
                    if (amountToSend != null && amountToSend > 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InvoiceInfoScreen(
                            mintUrl: widget.activeWallet,
                            amount: amountToSend,
                            createInvoice: widget.createInvoice,
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'Create Invoice',
                  style: TextStyle(fontSize: 20),
                ),
              ), // Send button
              const SizedBox(height: 3),
              if (_controller.text.isEmpty)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 70),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceiveToken(
                          cashu: widget.cashu,
                          mints: widget.mints,
                          createInvoice: widget.createInvoice,
                          decodeToken: widget.decodeToken,
                          activeWallet: widget.activeWallet,
                          addMint: widget.addMint,
                          receiveToken: widget.receiveToken,
                        ),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Receive Token',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 3),
            ],
          ),
        ),
      ),
    );
  }
}
