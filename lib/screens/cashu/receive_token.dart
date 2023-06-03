import 'package:flutter/material.dart';

import 'package:cashcrab/bridge_definitions.dart';
import 'package:cashcrab/shared/widgets/add_mint.dart';
import 'package:cashcrab/bridge_generated.dart';
import 'package:flutter/services.dart';

class ReceiveToken extends StatefulWidget {
  final Function decodeToken;
  final Function receiveToken;
  final Function addMint;
  final Function createInvoice;
  final Map<String, int> mints;
  final RustImpl cashu;
  final String? activeWallet;

  const ReceiveToken(
      {super.key,
      required this.decodeToken,
      required this.activeWallet,
      required this.receiveToken,
      required this.mints,
      required this.addMint,
      required this.cashu,
      required this.createInvoice});

  @override
  ReceiveTokenState createState() => ReceiveTokenState();
}

class ReceiveTokenState extends State<ReceiveToken> {
  final receiveController = TextEditingController();

  TokenData? tokenData;
  bool showTokenText = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _decodeToken(String tokenText) async {
    TokenData? newTokenData = await widget.decodeToken(tokenText);
    if (newTokenData != null) {
      setState(() {
        tokenData = newTokenData;
        showTokenText = false;
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    receiveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              "Receive",
              style: TextStyle(fontSize: 20),
            ),
            if (showTokenText)
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Paste Token',
                ),
                onChanged: (value) async {
                  if (value.length > 10) {
                    String tokenText = receiveController.text;
                    await _decodeToken(tokenText);
                  }
                },
                controller: receiveController,
              ),
            const SizedBox(height: 3),
            if (showTokenText)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 70),
                ),
                onPressed: () async {
                  ClipboardData? clipboardData =
                      await Clipboard.getData('text/plain');
                  if (clipboardData != null && clipboardData.text != null) {
                    await _decodeToken(clipboardData.text!);
                  }
                },
                child: const Text(
                  'Paste from Clipboard',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            const SizedBox(
              height: 50,
            ),
            if (tokenData != null)
              Column(
                children: [
                  Text('Mint:  ${tokenData!.mint}'),
                  Text("${tokenData!.amount.toString()} sats"),
                  ElevatedButton(
                    onPressed: () {
                      // Check token is valid

                      if (tokenData != null) {
                        // Check if mint is trusted
                        if (!widget.mints.containsKey(tokenData!.mint)) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => AddMintDialog(
                                "Do you trust this mint?",
                                "A Mint does not know your activity, but it does control the funds",
                                tokenData!.mint,
                                widget.addMint,
                                null),
                          );
                        } else {
                          widget.receiveToken(tokenData?.encodedToken);
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }
                      }
                    },
                    child: const Text('Redeam'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
