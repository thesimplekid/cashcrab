import 'package:cashcrab/bridge_definitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TokenInfo extends StatefulWidget {
  final int amount;
  final String? mintUrl;
  final TokenData? tokenData;
  // final Cashu cashu;
  final Function send;
  final Function decodeToken;

  const TokenInfo(
      {super.key,
      required this.amount,
      required this.mintUrl,
      required this.send,
      required this.decodeToken,
      //  required this.cashu,
      this.tokenData});

  @override
  TokenInfoState createState() => TokenInfoState();
}

class TokenInfoState extends State<TokenInfo> {
  TokenData? displayToken;

  void _createToken() async {
    String result = await widget.send(widget.amount);
    TokenData tokenData = await widget.decodeToken(result);

    setState(() {
      displayToken = tokenData;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.tokenData == null) {
      _createToken();
    } else {
      displayToken = widget.tokenData;
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
                SizedBox(
                  height: 400,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 300,
                        child: SingleChildScrollView(
                          child: Text(displayToken!.encodedToken),
                        ),
                      ),
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
                ),
                TextButton(
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: displayToken!.encodedToken));
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
