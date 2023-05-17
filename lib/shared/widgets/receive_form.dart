import 'package:flutter/material.dart';

class ReceiveForm extends StatefulWidget {
  // final Function receive;
  final Function decodeToken;
  // final Function clearToken;
  // TokenData? decodedToken;
  const ReceiveForm({
    super.key,
    // required this.receive,
    required this.decodeToken,
    // required this.clearToken
  });

  @override
  State<ReceiveForm> createState() => _ReceiveFormState();
}

// Define a corresponding State class.
// This class holds data related to the Form.
class _ReceiveFormState extends State<ReceiveForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final receiveController = TextEditingController();

  _ReceiveFormState();

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    receiveController.addListener(_decodeToken);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    receiveController.dispose();
    super.dispose();
  }

  Future<void> _decodeToken() async {
    String tokenText = receiveController.text;
    await widget.decodeToken(tokenText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Dismiss the keyboard when the user taps outside of the TextField
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: TextField(
          decoration: const InputDecoration(
            labelText: 'Receive Token',
          ),
          onChanged: (value) async {
            await _decodeToken();
          },
          controller: receiveController,
          // TextField properties go here
        ),
      ),
    );
  } // Widget Build
}
