import 'package:cashcrab/shared/colors.dart';
import 'package:flutter/material.dart';

import 'package:cashcrab/bridge_generated.dart';
import 'package:cashcrab/bridge_definitions.dart';

// MintInfo
class MintInfoScreen extends StatefulWidget {
  final RustImpl api;
  final String mint;

  const MintInfoScreen({super.key, required this.api, required this.mint});

  @override
  State<MintInfoScreen> createState() => _MintInfoScreenState();
}

class _MintInfoScreenState extends State<MintInfoScreen> {
  MintInformation? mintInfo;

  _MintInfoScreenState();
  @override
  void initState() {
    super.initState();
    getMintInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getMintInfo() async {
    MintInformation? info =
        await widget.api.getMintInformation(mint: widget.mint);

    if (info != null) {
      setState(() {
        mintInfo = info;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? versionText;
    if (mintInfo != null) {
      versionText = "${mintInfo!.version}";
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mint Information"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (mintInfo != null)
              Column(
                children: [
                  InfoRowWidget(
                    title: "Mint Name",
                    info: mintInfo!.name,
                  ),
                  Divider(
                    color: purpleColor,
                    height: 1,
                  ),
                  InfoRowWidget(
                    title: "Mint Public Key",
                    info: mintInfo!.pubkey,
                  ),
                  Divider(
                    color: purpleColor,
                    height: 1,
                  ),
                  InfoRowWidget(
                    title: "Description",
                    info: mintInfo!.description,
                  ),
                  Divider(
                    color: purpleColor,
                    height: 1,
                  ),
                  InfoRowWidget(
                    title: "Version",
                    info: versionText,
                  ),
                  Divider(
                    color: purpleColor,
                    height: 1,
                  ),
                  InfoRowWidget(
                    title: "Msg of the Day",
                    info: mintInfo!.motd,
                  ),
                  Divider(
                    color: purpleColor,
                    height: 1,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class InfoRowWidget extends StatelessWidget {
  final String title;
  final String? info;

  const InfoRowWidget({super.key, required this.title, required this.info});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
            ),
          ),
          const Text(": "),
          Text(
            info ?? "Not Set",
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
