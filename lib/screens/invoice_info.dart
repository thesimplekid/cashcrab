import 'package:cashcrab/bridge_definitions.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:cashcrab/bridge_generated.dart';
import '../shared/models/invoice.dart';
import '../shared/models/transaction.dart';

class InvoiceInfoScreen extends StatefulWidget {
  final int amount;
  final String mintUrl;
  final Invoice? invoice;
  final List<LightningTransaction> invoices;
  final List<LightningTransaction> pendingInvoices;
  final RustImpl cashu;
  final Function setInvoices;

  const InvoiceInfoScreen(
      {super.key,
      required this.amount,
      required this.mintUrl,
      required this.invoices,
      required this.pendingInvoices,
      required this.cashu,
      required this.setInvoices,
      this.invoice});

  @override
  InvoiceInfoState createState() => InvoiceInfoState();
}

class InvoiceInfoState extends State<InvoiceInfoScreen> {
  Invoice? displayInvoice;

  void _createInvoice() async {
    // TODO: Make a type for this
    RequestMintInfo result = await widget.cashu
        .requestMint(amount: widget.amount, mintUrl: widget.mintUrl);
    Invoice newInvoice = Invoice(
        invoice: result.pr,
        hash: result.hash,
        amount: widget.amount,
        mintUrl: widget.mintUrl);

    LightningTransaction newTransaction = LightningTransaction(
        status: TransactionStatus.pending,
        time: DateTime.now(),
        mintUrl: widget.mintUrl,
        amount: widget.amount,
        invoice: newInvoice);

    setState(() {
      widget.pendingInvoices.add(newTransaction);
      displayInvoice = newInvoice;
    });

    await widget.setInvoices(widget.pendingInvoices, widget.invoices);
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
                      child: Text(displayInvoice!.invoice!),
                    ),
                  ),
                  Text("Mint: ${displayInvoice!.mintUrl}"),
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
                    ClipboardData(text: displayInvoice!.invoice));
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
