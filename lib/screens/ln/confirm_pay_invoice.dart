import 'package:cashcrab/bridge_definitions.dart';
import 'package:flutter/material.dart';

import 'package:cashcrab/screens/ln/paying_invoice.dart';
import 'package:cashcrab/bridge_generated.dart';

class ConfirmPayInvoice extends StatefulWidget {
  final InvoiceInfo invoice;
  final String? activeMint;
  // final Map<String, int> mints;
  final RustImpl api;
  final Function payInvoice;

  const ConfirmPayInvoice({
    super.key,
    required this.invoice,
    required this.activeMint,
    required this.api,
    // required this.mints,
    required this.payInvoice,
  });

  @override
  ConfirmPayInvoiceState createState() => ConfirmPayInvoiceState();
}

class ConfirmPayInvoiceState extends State<ConfirmPayInvoice> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.bolt)]),
      ),
      body: Center(
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Text(
                    '${widget.invoice.amount.toString()} sats',
                    style: const TextStyle(fontSize: 30),
                  ),
                  const SizedBox(height: 5),
                  if (widget.invoice.memo != null)
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text(
                        "Description: ",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        '${widget.invoice.memo}',
                        style: const TextStyle(fontSize: 20),
                      )
                    ]),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PayingInvoice(
                              invoice: widget.invoice.bolt11,
                              amount: widget.invoice.amount,
                              api: widget.api,
                              payInvoice: widget.payInvoice),
                        ),
                      );
                    },
                    child: const Text('Pay'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
