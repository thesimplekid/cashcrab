import 'package:cashcrab/bridge_definitions.dart';
import 'package:cashcrab/bridge_generated.dart';
import 'package:flutter/material.dart';

// Settings
class AddContacts extends StatefulWidget {
  final RustImpl api;
  final String userPubkey;
  const AddContacts({super.key, required this.api, required this.userPubkey});

  @override
  State<AddContacts> createState() => _AddContactsState();
}

class _AddContactsState extends State<AddContacts> {
  List<Contact> contacts = [];

  _AddContactsState();

  @override
  void initState() {
    super.initState();
    _loadRelays();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadRelays() async {
    List<Contact> c = await widget.api.fetchContacts(pubkey: widget.userPubkey);

    setState(() {
      contacts = c;
    });
  }

  Future<void> _addContact(String pubkey) async {
    await widget.api.addContact(pubkey: pubkey);
    _loadRelays();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nostr Settings")),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    _addContact(contacts[index].pubkey);
                  },
                  child: Container(
                    height: 45.0,
                    decoration: const BoxDecoration(),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding:
                              const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        topRight: Radius.circular(10.0))),
                                child: Text(
                                  contacts[index].name ?? "",
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(fontSize: 15.0),
                                  maxLines: 1,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _addContact(contacts[index].pubkey);
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(0.0),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.purple,
                                    size: 30.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          color: Colors.purple,
                          height: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: 100.0,
          )
        ],
      ),
    );
  }
}
