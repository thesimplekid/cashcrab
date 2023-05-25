import 'package:cashcrab/bridge_definitions.dart';
import 'package:flutter/material.dart';

class ContactRowWidget extends StatelessWidget {
  final Contact contact;

  const ContactRowWidget(this.contact, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(contact.name ?? ""),
                  // TODO: Check if spendable
                  ElevatedButton(
                    onPressed: () async {
                      // receiveToken(token);
                    },
                    child: const Text('Redeam'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
