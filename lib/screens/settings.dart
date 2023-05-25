import 'package:cashcrab/bridge_generated.dart';
import 'package:cashcrab/main.dart';
import 'package:cashcrab/screens/add_contact.dart';
import 'package:cashcrab/screens/add_contacts.dart';
import 'package:cashcrab/screens/nostr_settings.dart';
import 'package:flutter/material.dart';

import '../shared/widgets/add_mint.dart';

// Settings
class Settings extends StatefulWidget {
  final RustImpl api;
  final Function addMint;
  final Function removeMint;
  final Function setActiveMint;
  final Function fetchContacts;
  final String? activeMint;
  final Map<String, int> mints;

  const Settings(
      {super.key,
      required this.api,
      required this.addMint,
      required this.removeMint,
      required this.setActiveMint,
      required this.activeMint,
      required this.fetchContacts,
      required this.mints});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final pubkeyController = TextEditingController();
  final TextEditingController newRelayController = TextEditingController();

  _SettingsState();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pubkeyController.dispose();
    super.dispose();
  }

  Future<void> _fetchContacts() async {
    String pubkey = pubkeyController.text;
    await widget.fetchContacts(pubkey);
  }

  @override
  Widget build(BuildContext context) {
    List<String> mints = widget.mints.keys.toList();
    mints
        .sort((a, b) => (widget.mints[b] ?? 0).compareTo(widget.mints[a] ?? 0));
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 100.0,
            child: AddMintForm(
              addMint: widget.addMint,
            ),
          ),
          Flexible(
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
                    onTap: () {
                      if (balance == 0) {
                        widget.removeMint(mints[index]);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(0.0),
                      child: balance == 0
                          ? const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 30.0,
                            )
                          : Text("${balance.toString()} sats"),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(
            color: Colors.purple,
            height: 1,
          ),
          const Text("Follow contacts from pubkey"),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Paste npub',
            ),
            controller: pubkeyController,
          ),
          TextButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddContacts(
                    api: widget.api,
                    userPubkey: pubkeyController.text,
                  ),
                ),
              );
            },
            child: const Text("Fetch Contacts"),
          ),
          const SizedBox(
            height: 100.0,
          ),
          const Divider(
            color: Colors.purple,
            height: 1,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NostrSettings(
                      api: widget.api,
                    ),
                  ),
                );
              },
              child: const Text("Nostr Settings"),
            ),
          ),
        ],
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
                          MaterialStateProperty.all<Color>(Colors.purple)),
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
