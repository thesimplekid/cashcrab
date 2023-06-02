import 'package:cashcrab/shared/colors.dart';
import 'package:flutter/material.dart';

import 'package:cashcrab/bridge_generated.dart';
import 'package:cashcrab/bridge_definitions.dart';
import 'package:flutter/services.dart';

// Keys
class Keys extends StatefulWidget {
  final RustImpl api;

  const Keys({super.key, required this.api});

  @override
  State<Keys> createState() => _KeysState();
}

class _KeysState extends State<Keys> {
  String? npub;
  String? nsec;

  _KeysState();
  @override
  void initState() {
    super.initState();
    getKeys();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getKeys() async {
    KeyData? keys = await widget.api.getKeys();

    if (keys != null) {
      setState(() {
        npub = keys.npub;
        nsec = keys.nsec;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Column pubkeyContainer = const Column();
    Column seckeyContainer = const Column();

    if (npub != null) {
      pubkeyContainer = Column(
        children: [
          const Text("Public Key"),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.black,
            ),
            padding: const EdgeInsets.all(8.0),
            child: Text(npub!),
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: purpleColor,
              borderRadius: BorderRadius.circular(8.0),
              child: InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: npub!));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: const Center(
                    child: Text(
                      'Copy',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (nsec != null) {
      seckeyContainer = Column(
        children: [
          const Text("Private Key"),
          const Align(
            alignment: Alignment.center,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.lock), Text('*****************')]),
          ),
          TextButton(
            onPressed: () async {
              bool confirmed = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Nostr Private Key'),
                    content: const Text(
                        'This key gives full access to your nostr account. Do Not Share It'),
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
                        child: const Text('Copy'),
                      ),
                    ],
                  );
                },
              );

              if (confirmed == true) {
                await Clipboard.setData(ClipboardData(text: nsec!));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                    ),
                  );
                }
              }
            },
            child: const Text('Copy'),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Nostr Keys")),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            pubkeyContainer,
            const SizedBox(height: 20),
            seckeyContainer
          ],
        ),
      ),
    );
  }
}
