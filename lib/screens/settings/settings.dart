import 'package:cashcrab/screens/settings/keys.dart';
import 'package:flutter/material.dart';

import 'package:cashcrab/bridge_definitions.dart';
import 'package:cashcrab/bridge_generated.dart';
import 'package:cashcrab/screens/settings/mints.dart';
import 'package:cashcrab/screens/settings/relays.dart';
import 'package:cashcrab/shared/colors.dart';

// Settings
class Settings extends StatefulWidget {
  final RustImpl api;
  final List<Contact> contacts;
  final Function addMint;
  final Function removeMint;
  final Function setActiveMint;
  final Function loadContacts;
  final Function addContact;
  final Function nostrLogOut;
  final String? activeMint;
  final Map<String, int> mints;

  const Settings(
      {super.key,
      required this.api,
      required this.contacts,
      required this.addMint,
      required this.removeMint,
      required this.setActiveMint,
      required this.activeMint,
      required this.nostrLogOut,
      required this.loadContacts,
      required this.addContact,
      required this.mints});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final pubkeyController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    List<String> mints = widget.mints.keys.toList();
    mints
        .sort((a, b) => (widget.mints[b] ?? 0).compareTo(widget.mints[a] ?? 0));

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Cashu",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: purpleColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Mints(
                        api: widget.api,
                        addMint: widget.addMint,
                        removeMint: widget.removeMint,
                        setActiveMint: widget.setActiveMint,
                        activeMint: widget.activeMint,
                        mints: widget.mints,
                      ),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.balance),
                        SizedBox(width: 8),
                        Text(
                          "Mints",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Nostr",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: purpleColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Relays(
                        api: widget.api,
                      ),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cell_tower),
                        SizedBox(width: 8),
                        Text(
                          "Relays",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: purpleColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Keys(
                        api: widget.api,
                      ),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.key),
                        SizedBox(width: 8),
                        Text(
                          "Keys",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: purpleColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () async {
                  bool confirmed = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Log Out?'),
                        content: const Text(
                            'Have you saved your private key securely securely? It will be erased.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false); // User canceled
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true); // User confirmed
                            },
                            child: const Text('Log Out'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmed == true) {
                    await widget.nostrLogOut();
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text(
                          "Log Out",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
