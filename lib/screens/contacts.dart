import 'package:cashcrab/screens/add_contact.dart';
import 'package:cashcrab/screens/messages.dart';
import 'package:flutter/material.dart';
import 'package:cashcrab/bridge_generated.dart';
import 'package:cashcrab/bridge_definitions.dart';

class Contacts extends StatefulWidget {
  final RustImpl api;
  final List<Contact> contacts;
  final Function addContact;
  final Function receiveToken;
  final Function sendToken;
  final Function createInvoice;
  final Function payInvoice;
  final String? activeMint;
  final Map<String, int> mints;

  const Contacts(
      {super.key,
      required this.activeMint,
      required this.mints,
      required this.receiveToken,
      required this.sendToken,
      required this.createInvoice,
      required this.payInvoice,
      required this.api,
      required this.contacts,
      required this.addContact});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  List<Message> messages = List.empty(growable: true);
  _ContactsState();

  @override
  void initState() {
    super.initState();
  }

  Future<void> getMessages(String pubkey) async {
    List<Message> gotMessages = await widget.api.getMessages(pubkey: pubkey);

    setState(() {
      messages = gotMessages;
    });
  }

  String truncateText(String text) {
    if (text.length <= 10) {
      return text; // No truncation needed
    } else {
      return "${text.substring(0, 10)} ...";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SingleChildScrollView(
              child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.contacts.length,
            itemBuilder: (BuildContext context, int index) {
              Contact contact = widget.contacts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Messages(
                        activeMint: widget.activeMint,
                        createInvoice: widget.createInvoice,
                        sendToken: widget.sendToken,
                        api: widget.api,
                        receiveToken: widget.receiveToken,
                        payInvoice: widget.payInvoice,
                        peerPubkey: contact.npub,
                        peerName: contact.name,
                        mints: widget.mints,
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact.name ?? "null",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(truncateText(contact.npub)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.purple,
                      height: 1,
                    ),
                  ],
                ),
              );
            },
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add contact screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddContact(
                addContact: widget.addContact,
              ),
            ),
          );
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
