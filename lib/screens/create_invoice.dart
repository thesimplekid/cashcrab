import 'package:cashcrab/bridge_definitions.dart';
import 'package:flutter/material.dart';

import '../bridge_generated.dart';
import '../shared/widgets/numeric_input.dart';
import '../screens/invoice_info.dart';

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

class MintDropdownButton extends StatefulWidget {
  final List<String> mints;
  final Function setMint;
  final String activeMint;
  const MintDropdownButton(
      {super.key,
      required this.mints,
      required this.activeMint,
      required this.setMint});

  @override
  State<MintDropdownButton> createState() => _MintDropdownButtonState();
}

class _MintDropdownButtonState extends State<MintDropdownButton> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: widget.activeMint,
      icon: const Icon(Icons.arrow_downward),
      elevation: 6,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        if (value != null) {
          widget.setMint(value);
        }
      },
      items: widget.mints.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.90,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
