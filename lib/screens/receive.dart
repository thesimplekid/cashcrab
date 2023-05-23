import 'package:cashcrab/bridge_definitions.dart';
import 'package:flutter/material.dart';
import 'package:cashcrab/bridge_generated.dart';

import '../shared/widgets/add_mint.dart';
import '../screens/create_invoice.dart';

class ReceviceToken extends StatefulWidget {
  final Function decodeToken;
  final Function receiveToken;
  final Function addMint;
  final Function createInvoice;
  final Map<String, int> mints;
  final RustImpl cashu;
  final String? activeWallet;

  const ReceviceToken(
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

class ReceiveTokenState extends State<ReceviceToken> {
  final receiveController = TextEditingController();

  TokenData? tokenData;

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    receiveController.addListener(_decodeToken);
  }

  Future<void> _decodeToken() async {
    String tokenText = receiveController.text;
    TokenData? newTokenData = await widget.decodeToken(tokenText);
    if (newTokenData != null) {
      setState(() {
        tokenData = newTokenData;
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
              "Receive ECash",
              style: TextStyle(fontSize: 20),
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Paste Token',
              ),
              onChanged: (value) async {
                if (value.length > 10) {
                  await _decodeToken();
                }
              },
              controller: receiveController,
            ),
            const SizedBox(
              height: 50,
            ),
            if (tokenData == null)
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 70),
                    ),
                    onPressed: () {
                      if (widget.activeWallet != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateInvoice(
                              cashu: widget.cashu,
                              mints: widget.mints,
                              activeMint: widget.activeWallet!,
                              createInvoice: widget.createInvoice,
                            ),
                          ),
                        );
                      }
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.bolt),
                          Text(
                            'Receive via Lighting',
                            style: TextStyle(fontSize: 20),
                          ),
                        ]),
                  ),
                ],
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
                          Navigator.of(context).pop();
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
