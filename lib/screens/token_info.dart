import 'package:cashcrab/bridge_definitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TokenInfo extends StatefulWidget {
  final int amount;
  final String? mintUrl;
  final CashuTransaction? cashuTransaction;
  final Function? send;
  final Function? decodeToken;

  const TokenInfo(
      {super.key,
      required this.amount,
      required this.mintUrl,
      this.send,
      this.decodeToken,
      this.cashuTransaction});

  @override
  TokenInfoState createState() => TokenInfoState();
}

class TokenInfoState extends State<TokenInfo> {
  CashuTransaction? displayToken;

  void _createToken() async {
    if (widget.send != null && widget.decodeToken != null) {
      Transaction? result = await widget.send!(widget.amount);

      setState(() {
        displayToken = result?.field0 as CashuTransaction;
      });
    } // TODO: else modal error
  }

  @override
  void initState() {
    super.initState();
    if (widget.cashuTransaction == null) {
      _createToken();
    } else {
      displayToken = widget.cashuTransaction;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (displayToken == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Creating Token"),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Token"),
        ),
        body: Column(
          children: [
            Column(
              children: [
                Column(
                  children: [
                    QrImageView(
                        data: displayToken!.token,
                        version: QrVersions.auto,
                        size: 400.0,
                        backgroundColor: Colors.white),
                    Text("Mint: ${displayToken!.mint}"),
                    Wrap(
                      children: [
                        Text(
                          "Token amount: ${displayToken!.amount.toString()}",
                        ),
                      ],
                    ), // Wrap
                  ],
                ),
                TextButton(
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: displayToken!.token));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                        ),
                      );
                    }
                  },
                  child: const Text('Copy'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}
