import 'package:cashcrab/bridge_definitions.dart';
import 'package:cashcrab/bridge_generated.dart';
import 'package:flutter/material.dart';

// Settings
class AddContacts extends StatefulWidget {
  final RustImpl api;
  final String userPubkey;
  final Function loadContacts;
  final Function addContact;

  const AddContacts({
    super.key,
    required this.api,
    required this.userPubkey,
    required this.loadContacts,
    required this.addContact,
  });

  @override
  State<AddContacts> createState() => _AddContactsState();
}

class _AddContactsState extends State<AddContacts> {
  List<Contact> pubContacts = [];
  List<Contact> contacts = [];

  _AddContactsState();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Fetch contacts of entered pub key
  Future<void> _loadAppContacts() async {
    List<Contact> appContacts = await widget.api.getContacts();

    setState(() {
      contacts = appContacts;
    });
  }

  // Fetch contacts of entered pub key
  Future<void> _loadContacts() async {
    List<Contact> c = await widget.api.fetchContacts(pubkey: widget.userPubkey);
    List<Contact> apContacts = await widget.api.getContacts();

    setState(() {
      pubContacts = c;
      contacts = apContacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nostr Settings")),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              itemCount: pubContacts.length,
              itemBuilder: (BuildContext context, int index) {
                bool inContacts = contacts.any(
                    (contact) => contact.pubkey == pubContacts[index].pubkey);

                return GestureDetector(
                  onTap: () async {},
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
                                  pubContacts[index].name ?? "",
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(fontSize: 15.0),
                                  maxLines: 1,
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (!inContacts) {
                                    await widget
                                        .addContact(pubContacts[index].pubkey);
                                    _loadAppContacts();
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(0.0),
                                  child: Icon(
                                    inContacts ? Icons.check : Icons.add,
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
