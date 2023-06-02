import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:cashcrab/bridge_generated.dart';
import 'package:cashcrab/screens/ln/confirm_pay_invoice.dart';

class PayInvoice extends StatefulWidget {
  final String? activeMint;
  final Map<String, int> mints;
  final RustImpl api;
  final Function payInvoice;

  const PayInvoice({
    super.key,
    required this.activeMint,
    required this.api,
    required this.mints,
    required this.payInvoice,
  });

  @override
  PayInvoiceState createState() => PayInvoiceState();
}

class PayInvoiceState extends State<PayInvoice> {
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
          ],
        ),
      ),
    );
  }
}
