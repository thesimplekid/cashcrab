import 'package:cashcrab/screens/settings/mint_info.dart';
import 'package:cashcrab/shared/widgets/mint_drop_down.dart';
import 'package:cashcrab/shared/widgets/numeric_input.dart';
import 'package:flutter/material.dart';

import 'package:cashcrab/bridge_generated.dart';
import 'package:cashcrab/shared/colors.dart';
import 'package:cashcrab/shared/widgets/add_mint.dart';

// Mints
class Mints extends StatefulWidget {
  final RustImpl api;
  final Function addMint;
  final Function removeMint;
  final Function setActiveMint;
  final Function mintSwap;
  final String? activeMint;
  final Map<String, int> mints;

  const Mints(
      {super.key,
      required this.api,
      required this.addMint,
      required this.removeMint,
      required this.setActiveMint,
      required this.mintSwap,
      required this.activeMint,
      required this.mints});

  @override
  State<Mints> createState() => _MintsState();
}

class _MintsState extends State<Mints> {
  final TextEditingController newRelayController = TextEditingController();

  String? fromMint;
  String? toMint;
  int amount = 0;

  _MintsState();
  @override
  void initState() {
    print(widget.mints);
    super.initState();
  }

  @override
  void dispose() {
    newRelayController.dispose();
    super.dispose();
  }

  void setFromMint(String mint) {
    setState(() {
      fromMint = mint;
    });
  }

  void setToMint(String mint) {
    setState(() {
      toMint = mint;
    });
  }

  void setSwapAmount(String value) {
    final swapAmount = int.tryParse(value);
    if (swapAmount != null && swapAmount > 0) {
      setState(() {
        amount = swapAmount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> mints = widget.mints.keys.toList();
    mints
        .sort((a, b) => (widget.mints[b] ?? 0).compareTo(widget.mints[a] ?? 0));

    return Scaffold(
      appBar: AppBar(title: const Text("Cashu Mints")),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Set mainAxisSize to MainAxisSize.min
          children: [
            SizedBox(
              height: 100.0,
              child: AddMintForm(
                addMint: widget.addMint,
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                itemCount: widget.mints.length,
                itemBuilder: (BuildContext context, int index) {
                  int balance = widget.mints[mints[index]] ?? 0;
                  return GestureDetector(
                    onTap: () {
                      print("Pressed");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MintInfoScreen(
                            api: widget.api,
                            mint: mints[index],
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                mints[index],
                                textAlign: TextAlign.left,
                                style: const TextStyle(fontSize: 14.0),
                                maxLines: 1,
                              ),
                              const Spacer(),
                              Container(
                                margin: const EdgeInsets.all(0.0),
                                child: balance == 0
                                    ? IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {},
                                      )
                                    : Text("${balance.toString()} sats"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 3),
            const Text("Mint Swap"),
            const Text("Swap fund from one mint to another"),
            MintDropdownButton(
                mints: mints, setMint: setFromMint, activeMint: fromMint),
            const SizedBox(height: 3),
            MintDropdownButton(
              mints: mints,
              setMint: setToMint,
              activeMint: toMint,
            ),
            NumericInput(
              onValueChanged: setSwapAmount,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 70),
              ),
              onPressed: () async {
                await widget.mintSwap(fromMint, toMint, amount);
              },
              child: const Text(
                'Swap',
                style: TextStyle(fontSize: 20),
              ),
            ), // Send button
          ],
        ),
      ),
    );
  }
}

class AddMintForm extends StatefulWidget {
  final Function addMint;
  const AddMintForm({super.key, required this.addMint});

  @override
  State<AddMintForm> createState() => _AddMintFormState();
}

class _AddMintFormState extends State<AddMintForm> {
  final addMintController = TextEditingController();

  _AddMintFormState();

  @override
  void initState() {
    super.initState();

    addMintController.addListener(() => {});
  }

  @override
  void dispose() {
    addMintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Add new mint',
                ),
                controller: addMintController,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: ElevatedButton(
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(purpleColor)),
                  onPressed: () {
                    // Check if its a valid url at least
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AddMintDialog(
                          "Do you trust this mint?",
                          "A Mint does not know your activity, but it does control the funds",
                          addMintController.text,
                          widget.addMint,
                          addMintController),
                    );
                  },
                  child: const Icon(Icons.add),
                ), // Elevated Button
              ), // Positioned
            ]) // Stack
          ],
        ), // Column
      ),
    );
  } // Widget Build
}
