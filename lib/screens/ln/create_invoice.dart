import 'package:cashcrab/screens/ln/invoice_info.dart';
import 'package:cashcrab/shared/widgets/mint_drop_down.dart';
import 'package:cashcrab/shared/widgets/numeric_input.dart';
import 'package:flutter/material.dart';

import 'package:cashcrab/bridge_definitions.dart';
import 'package:cashcrab/bridge_generated.dart';

class CreateInvoice extends StatefulWidget {
  final RustImpl cashu;
  final Map<String, int> mints;
  final String activeMint;
  final Function createInvoice;

  const CreateInvoice({
    super.key,
    required this.cashu,
    required this.mints,
    required this.activeMint,
    required this.createInvoice,
  });

  @override
  CreateInvoiceState createState() => CreateInvoiceState();
}

class CreateInvoiceState extends State<CreateInvoice> {
  final receiveController = TextEditingController();

  TokenData? tokenData;
  int amountToSend = 0;
  late String mint;

  @override
  void initState() {
    super.initState();
    setState(() {
      mint = widget.activeMint;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    receiveController.dispose();
    super.dispose();
  }

  void setMint(String mintUrl) {
    setState(() {
      mint = mintUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Invoice'),
      ),
      body: Center(
        child: Column(
          children: [
            MintDropdownButton(
                key: UniqueKey(),
                mints: widget.mints.keys.toList(),
                activeMint: mint,
                setMint: setMint),
            SizedBox(
              height: 100,
              child: NumericInput(
                onValueChanged: (String value) {
                  if (value.isNotEmpty) {
                    amountToSend = int.tryParse(value) ?? amountToSend;
                  }
                },
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InvoiceInfoScreen(
                      mintUrl: widget.activeMint,
                      amount: amountToSend,
                      createInvoice: widget.createInvoice,
                    ),
                  ),
                );
              },
              child: const Text('Create Invoice'),
            ), // Send button
          ],
        ), // Receive form
      ),
    );
  }
}
