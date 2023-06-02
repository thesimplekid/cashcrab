import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:cashcrab/bridge_definitions.dart';
import 'package:cashcrab/bridge_generated.dart';
import 'package:cashcrab/screens/cashu/create_token.dart';
import 'package:cashcrab/screens/ln/confirm_pay_invoice.dart';

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

  Future<void> _decodeInvoice(String encodedInvoice) async {
    // TODO: Try catach
    final data = await widget.api.decodeInvoice(encodedInvoice: encodedInvoice);
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmPayInvoice(
              invoice: data,
              api: widget.api,
              activeMint: widget.activeMint,
              payInvoice: widget.payInvoice),
        ),
      );
    }
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
              "Scan Lightning Invoice",
              style: TextStyle(fontSize: 20),
            ),
            Flexible(
              child: MobileScanner(
                fit: BoxFit.contain,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    debugPrint('Barcode found! ${barcode.rawValue}');
                    if (barcode.rawValue != null) {
                      _decodeInvoice(barcode.rawValue!);
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 3),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 70),
              ),
              onPressed: () async {
                ClipboardData? clipboardData =
                    await Clipboard.getData('text/plain');
                if (clipboardData != null && clipboardData.text != null) {
                  await _decodeInvoice(clipboardData.text!);
                }
              },
              child: const Text(
                'Paste from Clipboard',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 3),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 70),
              ),
              onPressed: () {
                // TODO: Alert dialog id balance not enough
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateCashuToken(
                      send: widget.send,
                      activeMint: widget.activeMint,
                      activeBalance: widget.activeBalance,
                      decodeToken: widget.decodeToken,
                      api: widget.api,
                      payInvoice: widget.payInvoice,
                      wallets: widget.wallets,
                    ),
                  ),
                );
              },
              child: const Text(
                'Create Token',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
