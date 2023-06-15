import 'package:cashcrab/shared/colors.dart';
import 'package:flutter/material.dart';

import 'package:cashcrab/bridge_generated.dart';

// Backup
class Backup extends StatefulWidget {
  final RustImpl api;
  final Function restoreTokens;

  const Backup({super.key, required this.api, required this.restoreTokens});

  @override
  State<Backup> createState() => _BackupState();
}

class _BackupState extends State<Backup> {
  _BackupState();
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
      appBar: AppBar(title: const Text("Backup")),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Back up tokens as an encrypted nostr message"),
            const Text(
                "Ensure you have backed up your nostr private key, or you will not be able to restore"),
            SizedBox(
              width: double.infinity,
              child: Material(
                color: purpleColor,
                borderRadius: BorderRadius.circular(8.0),
                child: InkWell(
                  onTap: () async {
                    await widget.api.backupMints();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: const Center(
                      child: Text(
                        'Backup',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Restore tokens from nostr backup"),
            SizedBox(
              width: double.infinity,
              child: Material(
                color: purpleColor,
                borderRadius: BorderRadius.circular(8.0),
                child: InkWell(
                  onTap: () async {
                    await widget.restoreTokens();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: const Center(
                      child: Text(
                        'Restore',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
