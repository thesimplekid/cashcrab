import 'package:flutter/material.dart';

import 'package:cashcrab/bridge_definitions.dart';
import 'package:cashcrab/bridge_generated.dart';
import 'package:cashcrab/shared/colors.dart';

// Settings
class AddContacts extends StatefulWidget {
  final RustImpl api;
  final String userPubkey;
  final String? username;
  final Function loadContacts;
  final Function addContact;

  const AddContacts({
    super.key,
    required this.api,
    required this.userPubkey,
    required this.username,
    required this.loadContacts,
    required this.addContact,
  });

  @override
  State<AddContacts> createState() => _AddContactsState();
}

class _AddContactsState extends State<AddContacts> {
  List<Contact> pubContacts = [];
  List<Contact> contacts = [];

  bool _isMounted = false;
  _AddContactsState();

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
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

    if (_isMounted) {
      setState(() {
        pubContacts = c;
        contacts = apContacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String barTitle;

    if (widget.username != null) {
      barTitle = "${widget.username}'s contacts";
    } else {
      barTitle = "Contacts";
    }

    return Scaffold(
      appBar: AppBar(title: Text(barTitle)),
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
                                    color: purpleColor,
                                    size: 30.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: purpleColor,
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
