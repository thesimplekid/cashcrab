import 'package:flutter/material.dart';
import 'package:cashcrab/bridge_generated.dart';

import '../shared/models/invoice.dart';

class PayInvoice extends StatefulWidget {
  final String? activeMint;
  final Map<String, int> mints;
  final RustImpl cashu;
  final Function setProofs;
  final Function setInvoices;

  const PayInvoice(
      {super.key,
      required this.activeMint,
      required this.cashu,
      required this.mints,
      required this.setProofs,
      required this.setInvoices});

  @override
  PayInvoiceState createState() => PayInvoiceState();
}

class PayInvoiceState extends State<PayInvoice> {
  final receiveController = TextEditingController();

  Invoice? invoice;
  late String _mint;

  @override
  void initState() {
    super.initState();
    if (widget.activeMint == null) {
      _mint = widget.mints.keys.toList()[0];
    } else {
      _mint = widget.activeMint!;
    }

    // Start listening to changes.
    receiveController.addListener(_decodeInvoice);
  }

  Future<void> _decodeInvoice() async {
    String encodedInvoice = receiveController.text;
    final data = await widget.cashu.decodeInvoice(invoice: encodedInvoice);
    Invoice newInvoice = Invoice(
      amount: data.amount,
      invoice: encodedInvoice,
      hash: data.hash,
      mintUrl: _mint,
      memo: data.memo,
    );

    setState(() {
      invoice = newInvoice;
    });
  }

  void payInvoice() async {
    await widget.cashu
        .melt(amount: invoice!.amount, invoice: invoice!.invoice!, mint: _mint);
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
        title: Row(children: const [Icon(Icons.bolt), Text('Pay Invoice')]),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'bolt11 invoice',
              ),
              onChanged: (value) async {
                await _decodeInvoice();
              },
              controller: receiveController,
            ),
            if (invoice != null)
              Column(
                children: [
                  Text('Mint: ${invoice!.mintUrl}'),
                  Text('${invoice!.amount.toString()} sats'),
                  ElevatedButton(
                    onPressed: () {
                      payInvoice();
                    },
                    child: const Text('Pay'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
