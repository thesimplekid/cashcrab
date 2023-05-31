import 'package:flutter/material.dart';

class AddContact extends StatefulWidget {
  final Function addContact;

  const AddContact({super.key, required this.addContact});

  @override
  AddContactState createState() => AddContactState();
}

class AddContactState extends State<AddContact> {
  final addContactController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    // addContactController.addListener(_addContact);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    addContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Contact'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              "Add Contact",
              style: TextStyle(fontSize: 20),
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Paste npub',
              ),
              controller: addContactController,
            ),
            TextButton(
              onPressed: () async {
                if (context.mounted) {
                  String pubkey = addContactController.text;
                  widget.addContact(pubkey).then((_) {
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  });
                }
              },
              child: const Text("Add Contact"),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
