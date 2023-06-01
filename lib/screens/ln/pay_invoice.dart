import 'package:cashcrab/screens/ln/paying_invoice.dart';
import 'package:flutter/material.dart';

import 'package:cashcrab/shared/models/invoice.dart';
import 'package:cashcrab/bridge_generated.dart';

class PayInvoice extends StatefulWidget {
  final String? activeMint;
  final Map<String, int> mints;
  final RustImpl cashu;
  final Function payInvoice;

  const PayInvoice({
    super.key,
    required this.activeMint,
    required this.cashu,
    required this.mints,
    required this.payInvoice,
  });

  @override
  PayInvoiceState createState() => PayInvoiceState();
}

class PayInvoiceState extends State<PayInvoice> {
  final receiveController = TextEditingController();

  Invoice? invoice;

  @override
  void initState() {
    super.initState();
    // Start listening to changes.
    receiveController.addListener(_decodeInvoice);
  }

  Future<void> _decodeInvoice() async {
    if (receiveController.text.isNotEmpty) {
      String encodedInvoice = receiveController.text;
      final data = await widget.cashu.decodeInvoice(invoice: encodedInvoice);
      Invoice newInvoice = Invoice(
        amount: data.amount,
        invoice: encodedInvoice,
        hash: data.hash,
        mintUrl: null,
        memo: data.memo,
      );

      setState(() {
        invoice = newInvoice;
      });
    }
  }

  @override
  void dispose() {
    receiveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.bolt), Text('Pay Invoice')]),
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
                  if (invoice?.mintUrl != null)
                    Text('Mint: ${invoice!.mintUrl}'),
                  Text('${invoice!.amount.toString()} sats'),
                  ElevatedButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PayingInvoice(
                              invoice: invoice!.invoice!,
                              amount: invoice!.amount,
                              api: widget.cashu,
                              payInvoice: widget.payInvoice),
                        ),
                      );
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
