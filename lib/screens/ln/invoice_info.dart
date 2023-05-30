import 'package:cashcrab/bridge_definitions.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:qr_flutter/qr_flutter.dart';

class InvoiceInfoScreen extends StatefulWidget {
  final int amount;
  final String? mintUrl;
  final LNTransaction? invoice;
  final Function? createInvoice;

  const InvoiceInfoScreen(
      {super.key,
      required this.amount,
      required this.mintUrl,
      this.createInvoice,
      this.invoice});

  @override
  InvoiceInfoState createState() => InvoiceInfoState();
}

class InvoiceInfoState extends State<InvoiceInfoScreen> {
  LNTransaction? displayInvoice;

  void _createInvoice() async {
    if (widget.createInvoice != null) {
      LNTransaction createdTransaction =
          await widget.createInvoice!(widget.amount, widget.mintUrl);

      setState(() {
        displayInvoice = createdTransaction;
      });
    } // TODO: Else modela error
  }

  @override
  void initState() {
    super.initState();
    if (widget.invoice == null) {
      _createInvoice();
    } else {
      displayInvoice = widget.invoice;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (displayInvoice == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Creating Invoice"),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Invoice"),
        ),
        body: Column(
          children: [
            Flexible(
              child: Column(
                children: [
                  QrImageView(
                    data: displayInvoice!.bolt11.toUpperCase(),
                    version: QrVersions.auto,
                    size: 400.0,
                    backgroundColor: Colors.white,
                  ),
                  Text("Mint: ${displayInvoice!.mint}"),
                  Wrap(
                    children: [
                      Text(
                          "Invoice amount: ${displayInvoice!.amount.toString()}"),
                    ],
                  ), // Wrap
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                await Clipboard.setData(
                    ClipboardData(text: displayInvoice!.bolt11));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                    ),
                  );
                }
              },
              child: const Text('Copy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
