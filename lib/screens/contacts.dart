import 'package:cashcrab/screens/add_contact.dart';
import 'package:cashcrab/screens/messages.dart';
import 'package:cashcrab/shared/colors.dart';
import 'package:cashcrab/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:cashcrab/bridge_generated.dart';
import 'package:cashcrab/bridge_definitions.dart';

class Contacts extends StatefulWidget {
  final RustImpl api;
  final List<Contact> contacts;
  final Function addContact;
  final Function removeContact;
  final Function receiveToken;
  final Function sendToken;
  final Function createInvoice;
  final Function payInvoice;
  final String? activeMint;
  final int activeMintBalance;
  final Map<String, int> mints;

  const Contacts(
      {super.key,
      required this.activeMint,
      required this.activeMintBalance,
      required this.mints,
      required this.removeContact,
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
  Conversation? conversation;
  _ContactsState();

  @override
  void initState() {
    super.initState();
  }

  Future<void> getMessages(String pubkey) async {
    Conversation conversation =
        await widget.api.getConversation(pubkey: pubkey);

    setState(() {
      conversation = conversation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: widget.contacts.length,
            itemBuilder: (BuildContext context, int index) {
              Contact contact = widget.contacts[index];
              return GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Remove contact"),
                        content: const Text(
                            "Are you sure you want to delete this contact and messages?"),
                        actions: [
                          ElevatedButton(
                            child: const Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                          ),
                          ElevatedButton(
                            child: const Text("Remove"),
                            onPressed: () {
                              widget.removeContact(contact.pubkey);
                              Navigator.pop(context); // Close the dialog
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
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
                        activeMintBalance: widget.activeMintBalance,
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
                    Divider(
                      color: purpleColor,
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
        backgroundColor: purpleColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
