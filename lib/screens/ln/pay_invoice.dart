import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:cashcrab/screens/ln/paying_invoice.dart';
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
  Invoice? invoice;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _decodeInvoice(String encodedInvoice) async {
    // TODO: Try catach
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

  @override
  void dispose() {
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
            Flexible(
              child: MobileScanner(
                fit: BoxFit.contain,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  // final Uint8List? image = capture.image;
                  for (final barcode in barcodes) {
                    debugPrint('Barcode found! ${barcode.rawValue}');
                    if (barcode.rawValue != null) {
                      _decodeInvoice(barcode.rawValue!);
                    }
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                ClipboardData? clipboardData =
                    await Clipboard.getData('text/plain');
                if (clipboardData != null && clipboardData.text != null) {
                  await _decodeInvoice(clipboardData.text!);
                }
              },
              child: const Text('Paste from Clipboard'),
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
