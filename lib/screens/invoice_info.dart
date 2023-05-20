import 'package:cashcrab/bridge_definitions.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:cashcrab/bridge_generated.dart';
import '../shared/models/invoice.dart';

class InvoiceInfoScreen extends StatefulWidget {
  final int amount;
  final String mintUrl;
  final LNTransaction? invoice;
  final RustImpl cashu;
  final Function createInvoice;

  const InvoiceInfoScreen(
      {super.key,
      required this.amount,
      required this.mintUrl,
      required this.cashu,
      required this.createInvoice,
      this.invoice});

  @override
  InvoiceInfoState createState() => InvoiceInfoState();
}

class InvoiceInfoState extends State<InvoiceInfoScreen> {
  LNTransaction? displayInvoice;

  void _createInvoice() async {
    // TODO: Make a type for this

    LNTransaction createdTransaction =
        await widget.createInvoice(widget.amount, widget.mintUrl);

    setState(() {
      // TODO:
      // 1 widget.pendingInvoices.add(newTransaction);
      displayInvoice = createdTransaction;
    });
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
            SizedBox(
              height: 400,
              child: Column(
                children: [
                  SizedBox(
                    height: 300,
                    child: SingleChildScrollView(
                      child: Text(displayInvoice!.bolt11),
                    ),
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
