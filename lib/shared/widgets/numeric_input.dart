import 'package:flutter/material.dart';

class NumericInput extends StatefulWidget {
  final Function(String) onValueChanged;

  const NumericInput({super.key, required this.onValueChanged});

  @override
  NumericInputState createState() => NumericInputState();
}

class NumericInputState extends State<NumericInput> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      widget.onValueChanged(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Amount (sats)',
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
