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
  final String? activeMint;
  final Map<String, int> mints;

  const Mints(
      {super.key,
      required this.api,
      required this.addMint,
      required this.removeMint,
      required this.setActiveMint,
      required this.activeMint,
      required this.mints});

  @override
  State<Mints> createState() => _MintsState();
}

class _MintsState extends State<Mints> {
  final TextEditingController newRelayController = TextEditingController();

  _MintsState();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    newRelayController.dispose();
    super.dispose();
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
                  return CheckboxListTile(
                    value: widget.activeMint == mints[index],
                    onChanged: (bool? value) {
                      if (value != null && value) {
                        widget.setActiveMint(mints[index]);
                      }
                    },
                    title: Text(
                      mints[index],
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontSize: 14.0),
                      maxLines: 1,
                    ),
                    secondary: GestureDetector(
                      onTap: () {},
                      child: Container(
                        margin: const EdgeInsets.all(0.0),
                        child: balance == 0
                            ? IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {},
                              )
                            : Text("${balance.toString()} sats"),
                      ),
                    ),
                  );
                },
              ),
            ),
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
