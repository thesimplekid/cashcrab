import 'package:flutter/material.dart';

import 'package:cashcrab/bridge_generated.dart';
import 'package:cashcrab/bridge_definitions.dart';
import 'package:cashcrab/screens/contacts/add_contacts.dart';
import 'package:cashcrab/shared/utils.dart';

class Profile extends StatefulWidget {
  final RustImpl api;
  final Contact contact;
  final String imagePath;
  final Function loadContacts;
  final Function addContact;

  const Profile(
      {super.key,
      required this.contact,
      required this.imagePath,
      required this.api,
      required this.loadContacts,
      required this.addContact});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  _ProfileState();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(widget.imagePath),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.contact.name ?? "null",
                  style: const TextStyle(
                    fontSize: 24.0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(truncateText(widget.contact.npub)),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddContacts(
                          api: widget.api,
                          username: widget.contact.name,
                          userPubkey: widget.contact.pubkey,
                          loadContacts: widget.loadContacts,
                          addContact: widget.addContact,
                        ),
                      ),
                    );
                  },
                  child: const Text("View Friends"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
