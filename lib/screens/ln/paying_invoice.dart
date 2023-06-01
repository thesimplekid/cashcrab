import 'package:cashcrab/bridge_definitions.dart';
import 'package:flutter/material.dart';

import 'package:cashcrab/shared/models/invoice.dart';
import 'package:cashcrab/bridge_generated.dart';

class PayingInvoice extends StatefulWidget {
  final String invoice;
  final int amount;
  final String? mint;
  final RustImpl api;
  final Function payInvoice;

  const PayingInvoice({
    super.key,
    required this.api,
    required this.invoice,
    this.mint,
    required this.amount,
    required this.payInvoice,
  });

  @override
  PayingInvoiceState createState() => PayingInvoiceState();
}

class PayingInvoiceState extends State<PayingInvoice> {
  final receiveController = TextEditingController();

  Invoice? invoice;
  LNTransaction? lnt;

  bool paying = true;

  @override
  void initState() {
    super.initState();
    // Start listening to changes.
    receiveController.addListener(_decodeInvoice);
    payInvoice();
  }

  Future<void> payInvoice() async {
    LNTransaction? ln =
        await widget.payInvoice(widget.invoice, widget.mint, widget.amount);
    setState(() {
      paying = false;
      lnt = ln;
    });
  }

  Future<void> _decodeInvoice() async {
    if (receiveController.text.isNotEmpty) {
      String encodedInvoice = receiveController.text;
      final data = await widget.api.decodeInvoice(invoice: encodedInvoice);
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
    paying = false;
    receiveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (paying) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Paying Invoice"),
        ),
        body: const Column(
          children: [
            SizedBox(height: 10),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    } else {
      Column column;

      if (lnt != null) {
        if (lnt!.status == TransactionStatus.Sent) {
          column = const Column(children: [
            Icon(
              Icons.check_circle,
              size: 100.0,
              color: Colors.green,
            ),
            SizedBox(height: 5),
            Text(
              "Sucessfully Paid",
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ]);
        } else if (lnt!.status == TransactionStatus.Expired) {
          column = const Column(children: [
            Icon(
              Icons.check_circle,
              size: 100.0,
              color: Colors.green,
            ),
            SizedBox(height: 5),
            Text(
              "Invoice Expired",
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ]);
        } else {
          column = const Column(children: [
            Icon(
              Icons.error,
              size: 100.0,
              color: Colors.red,
            ),
            SizedBox(height: 5),
            Text(
              "Payment Failed",
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ]);
        }
      } else {
        column = const Column(children: []);
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text("Paid Invoice"),
        ),
        body: Center(
          child: Column(
            children: [
              Flexible(child: column),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("Home"),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    }
  }
}
